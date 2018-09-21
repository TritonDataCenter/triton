vminfod Troubleshooting
=======================

The first thing is to identify what has gone wrong, and how vminfod may or may
not be involved in that.  This guide is intended to be used after you have done
basic troubleshooting steps on a machine, such as check for failed or degraded
services with `svcs -xv`, and have determined that vminfod is a part (or all) of
the problem.

1. [Application Level Health](#application-level-health)
2. [Service Level Health](#service-level-health)
3. [Frequently Asked Questions](#frequently-asked-questions)
4. [Various Tips](#various-tips)

Application Level Health
------------------------

A common problem that can happen is not with vminfod directly, but with how
tools like `vmadm` or other parts of the provisioning stack rely on vminfod.

### `VminfodEventStream ended prematurely`

If you see a message like:

    VminfodEventStream ended prematurely

This means that the vminfod daemon died (and possibly restarted) while something
had an open connection to it.  The thing to do in this case is to look at the
vminfod log files using `svcs -L vminfod`.  For more information on this see the
[vminfod is down](#vminfod-is-down) section below, since the same debugging
principles apply in this situation.

### `vminfod <func> timeout exceeded`

If you see a message like:

    vminfod watchForChanges timeout exceeded

This means that some part of the stack had a connection open to vminfod, waiting
for a specific vminfod event to be seen that never came.  Often times, an event
was fired from vminfod, but it didn't match the event that was expected.

As an example, the program or code might be waiting for the `ram` value of a VM
to update to `"256"` (a string) but saw an update for `ram` being set to `256`
(a number).

These situations reflect a programmer error.

An example:

    # vmadm update 57a6861d-30bd-41bf-cc8f-a6ce8cfa1145 ram=1024
    first of 1 error: vminfod watchForChanges timeout exceeded

To start debugging this problem, you can look through the vminfod logs for
events that were emitted for that given zone.

    # bunyan -o bunyan -c 'this.ev && this.ev.zonename == "57a6861d-30bd-41bf-cc8f-a6ce8cfa1145"' "$(svcs -L vminfod)" | bunyan -o short

This will show lines like:

    20:37:25.246Z  INFO vminfod: emitting "modify" event (34 VMs total)
    ev: {
      "type": "modify",
      "date": "2018-09-11T20:37:25.246Z",
      "zonename": "57a6861d-30bd-41bf-cc8f-a6ce8cfa1145",
      "uuid": "57a6861d-30bd-41bf-cc8f-a6ce8cfa1145",
      "vm": {
        "zonename": "57a6861d-30bd-41bf-cc8f-a6ce8cfa1145",
        "autoboot": true,
        ...
        "max_physical_memory": 1024,
        "max_locked_memory": 1024,
        "max_swap": 1024,
        "tmpfs": 1024,
      },
      "changes": [
        {
          "prettyPath": "max_physical_memory",
          "path": [
            "max_physical_memory"
          ],
          "action": "changed",
          "oldValue": 256,
          "newValue": 1024
        },
        {
          "prettyPath": "max_locked_memory",
          "path": [
            "max_locked_memory"
          ],
          "action": "changed",
          "oldValue": 256,
          "newValue": 1024
        },
        ...
      ]
    }

(some lines snipped for brevity)

This shows that the vm itself was updated to `1024` ram successfully, but for
some reason `vmadm` wasn't satisfied with this event.  We can then look for any
`vmadm` logs pertaining to this zone that generated an error.

    # cat /var/log/vm/logs/*vmadm.log | grep 57a6861d-30bd-41bf-cc8f-a6ce8cfa1145 | bunyan -l error -o short

Which in our case will return a single log entry:

    23:07:08.260Z ERROR vmadm: vminfod watchForChanges timeout exceeded - unmatched events (req_id=ce9c5715-9b61-e208-f126-acd6785d577c, action=update, vm=57a6861d-30bd-41bf-cc8f-a6ce8cfa1145)
        client: VM.js update (57a6861d-30bd-41bf-cc8f-a6ce8cfa1145)
        --
        changes: [
          {
            "newValue": "1024",
            "path": [
              "max_physical_memory"
            ]
          },
          ...
        ]
        --
        events: [
          {
            "prettyPath": "max_physical_memory",
            "path": [
              "max_physical_memory"
            ],
            "action": "changed",
            "oldValue": 256,
            "newValue": 1024
          },
          ...
        ]

The `changes` array shows what change `vmadm` wanted to see - i.e. the change it
was waiting to see happen from vminfod.  The `events` array shows what change
vminfod actually emitted.  The changes look very similar at first but you can
see that the change `vmadm` wanted to see was a `newValue` of `"1024"` (a
string) and it saw a `newValue` of `1024` (a number).

This represents a bug in the `vmadm` source code (most likely `VM.js` in this
case) and not anything inherently wrong with vminfod.

#### `vmadm` debug logs

If you are in a situation where these logs aren't available, but you can rerun a
failing command (most likely `vmadm`), you can run something like:

    # VMADM_DEBUG_LEVEL=debug vmadm update 57a6861d-30bd-41bf-cc8f-a6ce8cfa1145 ram=1024 2>&1 | bunyan -o short
    ...

Be warned that this will generate a lot of output, but can be really useful to
discover any discrepancies in events seen vs events wanted.  This will output
the same type of logs seen above in the `*vmadm.log` files.

Also, you can run `vmadm events` to see the events live from vminfod for a
specific vm like this:

    # vmadm events 57a6861d-30bd-41bf-cc8f-a6ce8cfa1145
    [23:14:08.182Z] 57a6861d ad34b2bb modify: max_physical_memory changed :: 256 -> 1024
    [23:14:08.182Z] 57a6861d ad34b2bb modify: max_locked_memory changed :: 256 -> 1024
    [23:14:08.182Z] 57a6861d ad34b2bb modify: max_swap changed :: 256 -> 1024
    [23:14:08.182Z] 57a6861d ad34b2bb modify: tmpfs changed :: 256 -> 1024
    [23:14:08.182Z] 57a6861d ad34b2bb modify: last_modified changed :: "2018-09-11T23:13:51.000Z" -> "2018-09-11T23:14:08.000Z"

If you omit the zonename argument then events for all zones on the machine will
be printed.

Service Level Health
--------------------

The first thing to check is if vminfod is running.  This can be done with the
`vminfo` command:

    # vminfo ping
    pong

Based on the output of this command, check the appropriate section below.

### vminfod is down

If `vminfo ping` does not print "pong" (or exit with code 0), then something is
wrong with the daemon itself.  The thing to do now is check the `vminfod`
according to SMF in the global zone.  You can do that with:

    # svcs vminfod
    STATE          STIME    FMRI
    maintenance    20:01:12 svc:/system/smartdc/vminfod:default

And view it's logs with:

    # bunyan -o short "$(svcs -L vminfod)"
    Uncaught SyntaxError: Unexpected identifier
    ...
    connect ECONNREFUSED
    + kill -0 96114
    /usr/vm/smf/system-vminfod: line 40: kill: (96114) - No such process
    + exit 0
    [ Sep  5 20:01:12 Method "start" exited with status 0. ]
    [ Sep  5 20:01:12 Stopping because all processes in service exited. ]
    [ Sep  5 20:01:12 Executing stop method (:kill). ]
    [ Sep  5 20:01:12 Restarting too quickly, changing state to maintenance. ]

In this example, the daemon went into maintenance mode because of a JavaScript
syntax error.

This is a trivial example, but in a real world application this type of error
will be caused by the programmer or the system, and the logs will be the most
telling place to look.

### vminfod is up

If `vminfo ping` prints "pong", then we know the daemon is up and responsive
over the HTTP interface.  The thing to do now is check `vminfo status` and
ensure that the daemon reports it is doing what we expect:

    # vminfo status
    state: running (working)
    pid: 96973
    uptime: 17.095167897s (17.1s)
    rss: 47.25mb
    numVms: 34
    queue
      paused: false
      idle: true
      npending: 0
      nqueued: 0
    fullRefresh
      lastRefresh: 15.506684706s (15.51s)
    eventsListeners: (8 listeners)
      ...

Most of these fields are self explanatory, but things to look out for are:

1. `uptime` - ensure this matches what you expect.  This value should be small if
the daemon was recently started/restarted, otherwise it should be relatively
large.
2. `rss`/`numVms` - the `rss` value will be affected by the `numVms`, but the
daemon tends to stay under 100mb even with 100 or so VMs.
3. `queue` - `queue` should almost always have 0 pending and 0 queued.
4. `lastRefresh` - this value should always be under 10 minutes

If the `rss` is abnormally high then this can indicate a memory leak with the
daemon and that will need to be debugged.

If the `queue` has more than 0 pending or queued and it stays like that for a
while this can indicate a stuck task (vminfod processes all events in a
serializing queue).  A stuck task will be killed after a set time, but you can
get more information with:

    # vminfo status -j | json queue.vasync_queue
    {
      "concurrency": 1,
      "npending": 1,
      "nqueued": 1,
      "pending": {
        "8ca268f5-36de-49f7-da4f-96c32fa6fc86": {
          "description": "handle zone event - zonename: 28b5d092-fe1a-4957-9b50-6f5acffe5b92",
          "created_at": "65474.699048593",
          "started_at": "65474.699440528",
          "created_ago": "0.077925201s (77.93ms)",
          "started_ago": "0.077533266s (77.53ms)",
          "start_latency": "0.000391935s (391.94us)"
        }
      },
      "queued": [
        {
          "description": "handle zone event - zonename: 28b5d092-fe1a-4957-9b50-6f5acffe5b92",
          "created_at": "65474.740122581",
          "created_ago": "0.036851213s (36.85ms)"
        }
      ]
    }


The `pending` value will have information on the current task being processed
and the `queued` array will have every task waiting to run (with information on
how long they have been queued).

In this example, there is a zone sysevent being processed.  It was created
`77.93ms` ago (when the task was pushed onto the queue) and was started
`77.53ms` (when the queue started the task), meaning there was a `391.94us`
latency from when the task was created to when it started.  This is incredibly
small, and in the event of a problem would be in the order of seconds or even
minutes.

There is also a zone sysevent queued that was created `36.85ms` ago.
Things become concerning when these values start getting into the seconds or
even minutes range, indicating that vminfod is taking a long time to do what
should be quick work.  If this happens the logs should be checked to see what
exactly is taking a long time.  You can search for a specific task in the logs
using its UUID:

    # grep 8ca268f5-36de-49f7-da4f-96c32fa6fc86 "$(svcs -L vminfod)" | bunyan -o short
    20:20:26.155Z DEBUG vminfod: no duplicate task found - pushing to vasync queue
        opts: {
          "description": "handle zone event - zonename: 28b5d092-fe1a-4957-9b50-6f5acffe5b92",
          "timeout": 60000,
          "id": "8ca268f5-36de-49f7-da4f-96c32fa6fc86",
          "created_at": [ 65474, 699048593 ]
        }
    20:20:26.156Z DEBUG vminfod: starting task
        task: {
          "description": "handle zone event - zonename: 28b5d092-fe1a-4957-9b50-6f5acffe5b92",
          "timeout": 60000,
          "id": "8ca268f5-36de-49f7-da4f-96c32fa6fc86",
          "created_at": [ 65474, 699048593 ],
          "started_at": [ 65474, 699440528 ]
        }
    20:20:26.238Z DEBUG vminfod: finished task in 0.082484118s (82.48ms)
        task: {
          "description": "handle zone event - zonename: 28b5d092-fe1a-4957-9b50-6f5acffe5b92",
          "timeout": 60000,
          "id": "8ca268f5-36de-49f7-da4f-96c32fa6fc86",
          "created_at": [ 65474, 699048593 ],
          "started_at": [ 65474, 699440528 ],
          "finished_at": [ 65474, 781924646 ]
        }
        --
        delta: [ 0, 82484118 ]

And then, using the timestamps above, any logs in between `starting task` and
`finished task` will help to debug what exactly is happening and why a job
could be taking so long.

Frequently Asked Questions
--------------------------

### Is this machine vminfod-enabled?

There are a couple of ways to check:

    # svcs vminfod
    STATE          STIME    FMRI
    online         20:31:17 svc:/system/smartdc/vminfod:default

Or:

    # vminfo ping
    pong

If vminfod is not on the platform then `svcs` will return an error because the
service doesn't exist, and `vminfo` will give a `command not found` error.

### Does vminfod have different information than `vmadm`?

No.

`vmadm` uses vminfod under-the-hood, so any information printed by `vmadm`
will be gathered from vminfod.

You can test this by running:

    # diff <(vminfo vms | json -ag uuid) <(vmadm lookup)
    #

And noting that there are no differences as reported by `vminfo vms` and `vmadm
lookup`.

If there are differences, that's most likely the result of a race between the
two commands and a third command updating the system, and running it a second or
third time will fix that.  If there are still differences then that is a bug.

### Does vminfod have different information than `vmapi`?

Yes.

Just like it is possible for `vmadm` and `vmapi` to be out of sync, it is
possible for `vminfod` and `vmapi` to be out of sync.  This is not necessarily a
bug with vminfod, and in fact is more likely to be an issue with `vmapi`,
`vm-agent`, or any of the other services used to keep that view of the world
up-to-date.

To fix this issue is the same in the vminfod world as it is in the non-vminfod
world: `GET vmapi /vms/<vm_uuid>?sync=true`.  This can be done on the headnode
with:

    # sdc-vmapi /vms/<vm_uuid>?sync=true
    ... vm json payload ...

### Can vminfod miss an event?

Yes.

vminfod uses sysevents and fs events (event ports) to try to keep an up-to-date
image of the VMs on a system.  Those events are not guaranteed.  In the ZFS
code base for instance, sysevents are constructed and then emitted assuming
everything goes according to plan.  If any part of that fails, the sysevent is
silently discarded and any userland program (like vminfod) will never see an
event.

However, vminfod refreshes its cache every 5 minutes (10 minutes max) and will
fire any "missed" events to its subscribers if there are any differences found
from the full cache refresh.

This means vminfod itself may miss events, but subscribers to vminfod should
not miss any events - it may just take a couple of minutes for them to come.

Various Tips
------------

### Using `vminfo`

`vminfo(1M)` is a command meant to interface with vminfod directly over the HTTP
port.  It's not meant for programmatic use but is perfect for interactive
debugging.

Run `man vminfo` for more usage details.

### Test Sysevents

vminfod uses `sysevent(1M)` to watch sysevents for zones and ZFS on the machine.
If you want to test to ensure vminfod is successfully receiving sysevents in a
relatively safe way (without impacting any customers) you can run:

    # zfs create zones/foobar

While watching the vminfod logs for that event with:

    # tail -f /var/svc/log/system-smartdc-vminfod\:default.log | bunyan -o short -c 'this.obj && this.obj.dsname == "zones/foobar"'
    23:24:35.524Z DEBUG vminfod: handleZpoolEvent: dsname: zones/foobar action: create
        obj: {
          "dsname": "zones/foobar",
          "pool": "zones",
          "timestamp": "2018-09-11T23:24:35.000Z",
          "action": "create",
          "extra": {},
          "extras": ""
        }

You should see a log message pertaining to that dataset being created.  That
means that vminfod is successfully reading sysevents related to ZFS.

### Test Event Streams

To test to ensure the `/events` streaming system is working properly with
vminfod you can run:

    # VMADM_IDENT='Dave Eddy Testing' vmadm events -r
    [23:28:37.610Z] ready

And in another terminal:

    # vminfo status | tail -4

      - VM.js events - vmadm CLI - Dave Eddy Testing - headnode/65332 (/usr/sbin/vmadm)
        dc526af3-ecb1-6e1f-fb21-e1313da6a7d8 created 29.238681116s (29.24s) ago


Notice the `Dave Eddy Testing` line in the `vminfo status` output.  This
ensures that vminfod is taking new requests and processing them appropriately.

### Test FSWatcher

vminfod uses `fswatcher`, a C companion program that uses event ports, to watch
for file changes on the filesystem.  You can ask for the current state of
fswatcher with:

    # vminfo status -f
    state: running (working)
    pid: 12380
    ...
    fswatcher
      running: true
      pid: 12382
      watching: 170
      tryingToWatch: 1
      pendingActions: 0

Under normal circumstances, `fswatcher` should be `running` with `0` pending
actions.  `fswatcher` works by taking commands over stdin, and writing
responses and events over stdout as JSON.  When vminfod writes a command to
`fswatcher` (like a command to watch a file, unwatch a file, get process
status, etc.) it considers that command "pending" until a response is received.
The amount of pending commands should almost always be `0` unless you happen to
run `vminfo status -f` right when a command is executed, in which case it might
be 1 or 2.  Subsequent runs should show that it's been processed, and the value
is again 0.

You can run this command for a more thorough status of `fswatcher`:

    # vminfo status -fj | json fswatcher
    {
      "message_delays": {
        "1": 0,
        "10": 0,
        "100": 0.03,
        "1000": 0.025
      },
      "watching": [
        "/tmp/.sysinfo.json",
        "/etc/zones/e58cffdf-9214-4541-b3d3-e9e11e118dcb.xml",
        "/zones/e58cffdf-9214-4541-b3d3-e9e11e118dcb/lastexited",
        ...
      ],
      "not_yet_watching": [
        "/zones/5df34a2b-0209-62aa-fde4-83013d9c873d/lastexited"
      ],
      "pending_actions": {},
      "watcher_pid": 12382,
      "running": true
    }

- `message_delays` - these are average times it took for a command to be sent
  and a response to be received from the `fswatcher` program (in milliseconds)
  for the last 1, 10, 100, and 1000 messages (averaged).  On this test machine
  it is normal for responses to take microseconds.  If these values are abnormally
  high then it will make sense to look in the logs and try to figure out why
  `fswatcher` is taking so long.
- `watching` - array of files that `fswatcher` is currently watching.
- `not_yet_watching` - event ports can't watch files that don't exist, so
  instead the node wrapper around `fswatcher` is responsible for retrying to
  watch these files so long as the user wants them to be watched.
- `pending_actions` - any actions that are pending.  Just like how the number of
  these should be `0`, it's expected this object will be empty.
- `watcher_pid` - the pid of the C `fswatcher` program.
- `running` - this should always be true.
