#SDC Architecture

Joyent's SmartDataCenter (SDC) is a software system engineered for deploying massively scalable, 
high-performance cloud computing datacenter services, implementing three key end-user accessible 
IaaS datacenter facilities: 

- Secure, multi-tenant, container-based, virtual machines.   
**SmartOS Zones, LX-branded Zones**

- Secure, multi-tenant, type 1 hypervisor-based, guest OS virtual machines,
  within containers.   
**KVM in Zones** - including Linux, Windows, and FreeBSD guest OSes.

- Secure, multi-tenant, durable object store with container-based 
  *in-situ* Map/Reduce Unix compute facility.   
**Manta Object Storage Service**


SDC is implemented with choices based on principles that some may find opinionated. These principles are based 
on Joyent's extensive experience in operating a large public cloud service, and from selling and supporting SDC. 

The open source release of SDC is the seventh version of our cloud software (SDC7). The SDC implementation you see 
today evolved from implementation details and experiments in previous versions. From this history, we can 
articulate some of the key architectural principles in practice.

#SDC High-Level Architecture: Principles

1. Economical use of commodity datacenter server hardware for optimal ROI.
2. Datacenter freedom from third-party license and firmware complications.
3. Enterprise grade filesystems (*ZFS*) as a covenant to prevent data corruption.
4. Maximize performance, minimize latency through network and disk IO traffic segregation.
5. Minimize human intervention for installation and operation.
6. Provide a complete private datacenter installation without public network access.
7. Provide continuous delivery of updates with precise dependency management.
8. Modular design permitting in-place upgrades to new datacenter wide features.
9. API endpoints are always RESTful and running in native containers (*SmartOS Zones*). 
10. Live, in production, trace level observability of all software components (*DTrace*).
11. Postmortem observability and analysis of components and disk devices (*mdb*, coredumps).
12. Remote SDC installations are supportable by Joyent Engineering.

These principles have guided the shape of the system and its implementation choices. Of course cloud services software 
can offer similar or competitive functionality on different architectures. Principle 1 is key. As a long-time competitor 
in the cloud IaaS business, be assured that Joyent's own margins are engineered into every decision. 

When comparing SDC to other cloud services systems architecture, we suggest you consider whether choices made in other 
implementations take into consideration these same principles, and where not, the tradeoffs they imply in terms of ROI, 
TCO, performance, serviceability, utilization and downtime.

This description of SDC architecture covers the implementation choices for the following high-level computing components, 
which are necessarily interconnected. From bottom to top these are:
 
- Hardware and Operating System
- Hardware and Data Storage
- Booting and Operator Interfaces
- SDC Software Implementation   
  - Programming Languages
  - Data Grammars
  - Data Storage
  - Modularity
  - Authentication
- SDC Core Services
- End-User Interfaces
- Cloud Computing Interfaces
- Object Storage Interfaces

##Hardware and Operating System

The architecture of SDC is tightly bound to the host operating system, SmartOS. Features providing support for KVM Zones are 
tightly bound to the base hardware processor, *64-bit Intel® x86 processors with VT-x and EPT virtualization*. SDC's KVM Zones 
are not currently supported on any AMD processors at this time. 

Features providing specific implementation of Zones and the ZFS filesystem used by SDC are only present in the open-source 
SmartOS operating system. SDC requires a base of *Illumos* operating system features, including *ZFS*, *Zones*, *SMF*, and *DTrace*. 
In addition SDC requires SmartOS-specific commands, such as Joyent-branded and KVM Zones management via `vmadm(1m)`, image 
management via `imgadm(1m)`, and SmartOS-specific ZFS filesystem features (e.g. feature flags, throttling) which optimize 
multi-tenant VM operations. SDC is not portable to other Illumos distributions which lack these features. Further removed 
from SDC portability are operating systems which lack the necessary base Illumos feature implementations, including Solaris, 
Apple OSX, FreeBSD, Linux, and Microsoft Windows (*in approximate order of increasing license and engineering difficulty*).

**To reiterate, SDC is architecturally bound to SmartOS and modern Intel® x86 64-bit VT-x/EPT based processors, 
and will not operate with any other operating system or processor.**

Given the base platform OS constraints, note that the KVM type-1 hypervisor implementation in a SmartOS Zone allows SDC to 
serve as *high-performance host for a wide variety of x86 based 32- and 64- bit guest operating systems, including current 
and older versions of Linux, Windows, and FreeBSD, and many others*. 

Fierce competition in the server hardware market has led to commodity pricing of Intel® processor based white-box servers, 
and hence specialization to these servers is congruent with Principle 1. 

##Hardware and Data Storage

SDC uses the ZFS filesystem, a fully mature open-source enterprise-grade filesystem built into SmartOS. All SDC compute 
nodes and head nodes mount local disks only. While remote mount features and services are present in Illumos, SDC does not 
use any of these (e.g. iSCSI or NFS) in its implementation. SDC avoids non-local filesystem services as a means for KVM or 
SmartOS Zones end-users to mount files or images. To the VM end-user, accessible filesystem storage is always local to the 
physical compute node on which the VM is running, thus offering multi-tenant users the highest disk IO bandwidth possible. 
Throttling of this bandwidth ensures fair share access to disk IO between users. This design choice is important because 
it selects performance over convenience features. For example live-migration of running VMs across physical hosts is not 
supported on SDC. Instance migrations on SDC will involve a VM restart, but are aided by ZFS snapshot and data transfer 
features. Further discussion on this choice is provided below.

ZFS directly handles the physical storage of data on disk, and manages aggregations of physical disks by direct interface, 
combining the roles of filesystem and volume management. ZFS copy-on-write provides first class data protection, and eliminates 
lengthy integrity checking (e.g. `fsck`, `chkdisk`) processes or install formatting for large arrays. ZFS minimizes server 
setup time, maximizes data center uptime and ensures user data is never compromised by pathological disk behavior. For SDC, 
the operating system must have direct access to a physical set of disks via a `jbod` mechanism, and bypass any firmware-based 
RAID controllers. This requirement excludes hardware RAID controllers that do not provide a firmware bypass or `jbod` interface. 
Joyent provides a list of recommended servers that are ZFS compatible and that are used in our production SDC environments.

SDC deployments benefit from the configurable performance features of ZFS including:
- *RAIDZ*, RAIDZ-2, RAIDZ-3 or Mirrored storage pools.
- Adaptive Replacement Cache (**ARC**): RAM based primary disk IO cache
- **L2ARC**: SSD disk-based secondary cache
- ZFS Intent Log (**ZIL**) HD or SSD based log for POSIX synchronous writes
- **LZ4** disk compression: Superior in performance and used in production at Joyent

All file storage for the KVM guest OSes is handled by ZFS on local disk, extending the above noted high-reliability, 
data compression and performance benefits to guest operating systems. ZFS send/receive and snapshot features are used 
for transmitting and snapshotting user VM images. SmartOS specific extensions to the filesystem include `hyprlofs(7FS)` 
which is used extensively in Manta for providing read only access to files on object storage for *in-situ* computing Zones.

SDC supported (and much unsupported) ZFS hardware is automatically detected at install time. SDC/SmartOS configures the server 
ZFS disk array automatically based on Joyent's experience in optimizing the above noted features. 

ZFS follows directly from adherence to Principle 3 to avoid data corruption. Our choice of local disk based filesystems 
allows the SDC datacenter to avoid mixing disk IO traffic with network interconnects, maximizing IO performance on each bus 
independently, following Principle 4. Importantly a SmartDataCenter will not suffer pathologies that arise from network IO 
saturation from compute nodes accessing remote disks. Also, there are no single points of failure for datacenter disk mounts. 
The system configurations applied by SDC install algorithms are tolerant to disk failures, and there are no systems in SDC 
where a disk mount point failure can take down more than the local server on which it is based. 
  
ZFS direct control of disk devices via pass-through or `jbod` access meets Principles 2, 10 and 11, in terms of avoiding disk 
control firmware and enjoying the resulting system observability and debuggability. Joyent recommends the use of SAS disks in 
production servers. In addition, eliminating specialized remote mount servers and disk subsystems follows the commodity components 
articulated in Principle 1. Finally as is detailed below, ZFS provides significant performance enhancements for PostgreSQL 
which is used to store the internal database of system state for SDC and Manta.


##Booting and Operator Interfaces

SDC is supplied as a USB-drive based, self-contained image providing booting and installation services automated 
for physical servers comprising head and compute nodes.

To support datacenter operator booting, SDC requires a Serial-Over-Lan (**SOL**) access to the server and 
server support for Intelligent Platform Management Interface (IPMI) via a Baseboard Management Controller (BMC). 
This offers a remote access to manage and observe the boot process.  We recommend remote access via the command-line 
`ipmitool`, which is an open source client for IPMI, and provided by Joyent as a `pkgsrc` package for 
SmartOS, MacOSX and 64-bit Linux clients. 

Note that SDC is not compatible with Intel Active Management Technology (Intel® AMT) as the SOL/KVM implementation 
it provides actively blocks remote client access to servers booting from USB-drives. 

Unsupported or experimental SDC installations may be booted with vga and keyboard console.

The SDC booting interface also provides an option to run FreeDOS on a server. This can simplify field deployments 
of BIOS, management firmware or controller card upgrades, as binary firmware images and flashing tools are almost 
aways based on DOS executables. These can downloaded from the system manufacturer and copied in to the FreeDOS 
subdirectories on the SDC USB-drive.

In addition to the use of the USB-drive as an SDC installation vehicle, the base SmartOS operating system 
runs as a live image in system memory. This means:  

- SmartOS does not take up a boot drive on the server system
- SmartOS version upgrading is performed by server reboot to a new USB platform image 

After configuring an SDC head node, compute nodes boot via iPXE from the head node. The iPXE booting of compute 
nodes is directed to the head node by an SDC USB-drive in each compute node, rather than from LAN card firmware 
which may be difficult to configure or require flash firmware updating. To upgrade the datacenter, only the 
head node needs to have the updated platform image on its USB-drive.

(Something about passwords, SSH and 2fa for headnode root user)

The choices for USB-disk based datacenter installation reflect on the economics of datacenter hosting 
articulated in Principle 1. The SmartOS platform live-image frees up one or two (in case of a mirrored pair) 
drives for end-user VMs and data, drives that would otherwise be used for OS booting. This maximizes server 
hard drive slots, which can all be loaded with large drives. Choice of the SDC USB-disk boot system and SOL 
based remote installation are significant to the overall architecture as the benefits span 
Principles 2, 5, 6, 7, 8, 10 and 12.  

##Software Implementation 

###Programming Languages 

SDC software is implemented in **C** and Joyent's own **Node.js**. 

SmartOS kernel modifications (e.g. KVM support) and some utilities (e.g. `hyperlofs`) are written in C. 
SDC APIs and services make extensive use of Node.js

Node.js is a runtime JavaScript engine built on the Google's portable, high performance, open source 
V8 JavaScript engine. Competition for browser-based JavaScript performance between Google, Mozilla and 
Microsoft has led to JavaScript interpeter optimizations that significantly outperform other runtime 
scripting languages. V8 uses a just-in-time compiler that compiles JavaScript to machine code before 
execution and then continuously optimizes the compiled code. V8 and, by extension, Node.js implement 
the ECMAScript standard as specified in ECMA-262. Node.js uses an event-driven non-blocking IO model 
based on `libuv`, a multi-platform library for asynchronous I/O initially developed for Node.js. The 
`libuv` library also provide non-blocking IO for Rust, R (httuv), Julia, Python (pyuv) and Lua (luvit). 

Node.js benefits from a carefully considered package management system, `npm`, and has a fast growing 
ecosystem of small modular component packages. A number of Joyent Engineers have authored widely used 
Node.js packages including `asn1`, `bunyan`, `ctype`, `daggr`, `dashdash`, `fast`, `http-signature`, 
`json`, `ldapjs`, `restify`, `vasync` and `wf`. When these packages are deployed within a DTrace 
compatible operating system, as is the case of SDC on SmartOS, they are often instrumented with 
probes for DTrace observability. DTrace instrumentation of Node.js allows us to safely inspect 
and monitor Node.js process internals as they are running live in production.

In addition Joyent has built SmartOS mdb debugging modules for postmortem analysis of Node.js 
(and other V8) JavaScript language coredumps with symbol and variable name translation extracted 
posthumously from the Javascript enviroment core file. With mdb, one can root-cause rare failures or 
pathological conditions that arise on long-running services. 

To recap, Node.js is chosen (and in many respects, engineered) by Joyent as the scripting language 
for SDC because of its high-performance, standards-compliant language interpreter (V8), non-blocking IO 
capabilities (libuv), extensive modular package environment (npm), observability (DTrace) and 
postmortem debugging (mdb).  

Joyent's choice of Node.js for SDC code spans Principles 1, 2, 6, 7, 8, 10, 11 and 12.


###SDC Data Grammars 

Data Grammars are structured, formal languages for storing and transmitting data. The 7-layer OSI model 
includes data grammars at both layers 6 (Presentation Layer) and layer 7 (Application Layer).  
Historically, Abstract Syntax Notation 1 Asn.1 originated in 1984, followed by the more familiar 
XML, YAML and JSON.  Data Grammar use in SDC attempts to be consistent, but some historical relics remain.

SDC makes extensive use of **JSON** as a system-wide data grammar. JSON serializers and parsers are 
native to Node.js and offer high-performance IO of structured data. JSON is provided at most, 
if not all, SDC RESTful API endpoints. The state for each of the service APIs in SDC is stored as 
JSON key-value sets (see next section). SDC services log to JSON from Node.js using the `Bunyan` 
package, which also provides a command line tool for log filtering and pretty-printing. Bunyan 
logging is built into the `restify` package, as well as others used in SDC. 

The System Management Facility (SMF) of SmartOS/Illumos manages system daemons, and predates SDC with 
service configuration data specified in XML. If you need to construct an SMF XML manifest for a new 
service, a Node.js JSON based tool, `smfgen`, can be installed from `npm`.  SmartOS `pkgsrc` also includes 
an open source third-party tool for SMF XML manifest generation, called manifold. 

The LDAP system used by SDC employs the Node.js `ldapjs` module, which is used within the Unified 
Foundational Directory Service (ufds). As LDAP directories are specified with Asn.1, `ldapjs` employs 
buffer-based Asn.1 `BER` readers/writers with the `asn1` `npm` module. It is unlikely you will need to 
work directly with Asn.1 encoded data in SDC, as it is converted into JSON for storage and retrieval by ufds.

Advanced Message Queuing Protocol (AMQP) is employed as a fast, guaranteed message delivery system and 
queue within SDC, using RabbitMQ which is third-party open source software packaged in SDC under the MPL 1.1 License.

Extensive use of machine-readable Data Grammars meets Principles 4, 5, 8, 9, 10, 11 and 12.

###SDC Data Storage



----------------

TODO: Continue adding sections. Critical Review Welcome. 

Add image here

Notes:

* Compute Nodes are network booted via DHCP / TFTP from the Headnode.
* Core services may be provisioned on other nodes than the headnode
* All internal communication occurs on the "admin" network

