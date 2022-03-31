#!/bin/bash
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#

#
# Copyright 2022 Joyent, Inc.
#

set -o errexit
set -o pipefail

# shellcheck disable=SC2154
if [[ -n "$TRACE" ]]; then
    export PS4='[\D{%FT%TZ}] ${BASH_SOURCE}:${LINENO}: ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
    set -o xtrace
fi

function stack_trace
{
    set +o xtrace

    (( cnt = ${#FUNCNAME[@]} ))
    (( i = 0 ))
    while (( i < cnt )); do
        printf '  [%3d] %s\n' "${i}" "${FUNCNAME[i]}"
        if (( i > 0 )); then
            line="${BASH_LINENO[$((i - 1))]}"
        else
            line="${LINENO}"
        fi
        printf '        (file "%s" line %d)\n' "${BASH_SOURCE[i]}" "${line}"
        (( i++ ))
    done
}

function fatal
{
    # Disable error traps from here on:
    set +o xtrace
    set +o errexit
    set +o errtrace
    trap '' ERR

    echo "$(basename "$0"): fatal error: $*" >&2
    stack_trace
    exit 1
}

function trap_err
{
    st=$?
    fatal "exit status ${st} at line ${BASH_LINENO[0]}"
}

set -o errexit
set -o pipefail

shopt -s extglob

#
# Install our error handling trap, so that we can have stack traces on
# failures.  We set "errtrace" so that the ERR trap handler is inherited
# by each function call.
#

trap trap_err ERR
set -o errtrace

function usage
{
    printf 'Create a new Triton Headnode install in Equinix Metal.\n\n'
    printf 'Syntax:\n\n'
    printf '\t%s project -n project_name\n' "$0"
    printf '\t%s headnode -p project_uuid -f facility -P hardware_plan -a answer_file\n\n' "$0"
    printf '\t%s computenode -n <cn name> -p project_uuid -f facility -P hardware_plan\n\n' "$0"
    exit "$1"
}

#############

#
# Global Variables
#

LOG=$(mktemp "${TMPDIR:-/tmp}/triton-eqm.XXXXXX")
prefix_l='28'

config_file=~/.config/equinix/metal.yaml
if [[ -z $METAL_AUTH_TOKEN ]]; then
    if [[ -f ~/.packet-cli.json ]]; then
        PACKET_TOKEN=$(yaml2json "$config_file" | json token)
        export PACKET_TOKEN
    else
        fatal 'PACKET_TOKEN is unset and ~/.packet-cli.json does not exist.'
    fi
fi

# For subnet calculation
prefix_num_ips=(
4294967296
2147483648
1073741824
536870912
268435456
134217728
67108864
33554432
16777216
8388608
4194304
2097152
1048576
524288
262144
131072
65536
32768
16384
8192
4096
2048
1024
512
256
128
64
32
16
8
4
2
1
)

#
# Functions
#

function assign_networks
{
    project_uuid="$1"
    server="$2"

    printf 'Assinging networks...'

    current_network_ports=$(metal server get -o json -i "$server" | json network_ports)
    eth1_id=$(json -a -c 'this.name.match(/eth1/)' id <<< "$current_network_ports")

    virtual_networks=$(metal virtual-network get -p "$project_uuid" -o json | json virtual_networks)
    admin_net=$(json -ac 'this.description.match(/Admin/)' id <<< "$virtual_networks")
    vnids=()
    while IFS='' read -r line; do vnids+=("$line"); done < <(json -a id <<< "$virtual_networks")

    {
        # Remove eth1 from the bond
        call_api "/ports/$eth1_id/disbond" -X POST -d '{"bulk_disable": false}'

        # Add VLANs and set native VLAN.
        for vnid in "${vnids[@]}"; do
            call_api "/ports/$eth1_id/assign" -X POST -d '{"vnid":"'"$vnid"'"}'
        done
        call_api "/ports/$eth1_id/native-vlan" -X POST -d '{"vnid":"'"$admin_net"'"}'
    } >> "$LOG"

    printf 'done.\n'
}

function call_api
{
    endpoint='https://api.equinix.com/metal/v1'
    headers=(
        -H "X-Auth-Token: $PACKET_TOKEN"
        -H  "accept: application/json"
        -H  "Content-Type: application/json"
    )
    query="$1" ; shift
    curl -i -s "${headers[@]}" "${endpoint}${query}" "$@" | json
}

function create_project
{
    local out;
    local proj_u;
    project_name="$1"

    out=$(metal project create --name "$project_name" -o json)
    echo "$out" >> "$LOG"

    proj_u="$( json id <<< "$out")"
    echo "$proj_u"
}

function create_server
{
    local reservation create_json out

    local project_uuid="$1"
    local facility="$2"
    local s_hostname="$3"

    # Defaults for CNs
    local always_ipxe=true
    local ip_addresses=''
    local ipxe_url='https://netboot.smartos.org/triton-cn/triton-cn.ipxe'

    if [[ $s_hostname =~ "headnode" ]]; then
        always_ipxe=false
        ipxe_url='https://netboot.smartos.org/triton-installer/packet.ipxe'
    fi

    # Create an IP reservation
    create_subnet_request "$project_uuid" "$facility" "$s_hostname"
    # Take the first reservation with no assignments.
    reservation=$(call_api "/projects/$project_uuid/ips" | json -H ip_addresses | json -ac 'this.address_family==4 && this.public==true && this.assignments.length==0' id | head -1)

    ip_addresses=$(printf ',
      "public_ipv4_subnet_size": %s,
      "private_ipv4_subnet_size": 31,
      "ip_addresses": [
        {
          "address_family": 4,
          "public": true,
          "cidr": %s,
          "ip_reservations": [
            "%s"
          ]
        },
        {
          "address_family": 4,
          "public": false
        }]' "$prefix_l" "$prefix_l" "$reservation")

    create_json=$( printf '
        {
          "facility": "%s",
          "plan": "%s",
          "hostname": "%s",
          "operating_system": "custom_ipxe",
          "always_pxe": %s,
          "ipxe_script_url": "%s",
          "customdata": %s
          %s
        }' "$facility" "${hardware_plan:-c3.small.x86}" "$s_hostname" \
            "$always_ipxe" "$ipxe_url" "$customdata" "$ip_addresses"
    )

    out=$(call_api "/projects/$project_uuid/devices" -X POST -d "$create_json")
    echo "$out" >> "$LOG"
    json -H id <<< "$out"
}

function create_subnet_request
{
    project_uuid="$1"
    facility="$2"
    hostname="$3"
    metal ip request -f "$facility" -p "$project_uuid" -t public_ipv4 \
        -c "IPs for $hostname" -q 16 >> "$LOG"
}

function create_vlans
{
    project_uuid="$1"
    facility="$2"
    local networks=(
        Admin
        Underlay
    )
    existing_vlans=$(metal virtual-network get -p "$project_uuid" -o json | \
        json virtual_networks | \
        json -a -c 'this.facility="'$facility'"' description)
    for net in "${networks[@]}" ; do
        if ! grep "$net" <<< "$existing_vlans" ; then
            metal virtual-network create -o json -f "$facility" -d "Triton $net" \
                -p "$project_uuid"
        fi
    done >> "$LOG"
}

function do_setup_project
{
    while getopts "n:f:h" options; do
        case $options in
            n) project_name="$OPTARG" ;;
            h) usage 0 ;;
            *) usage 1 ;;
        esac
    done

    if [[ -z $project_name ]]; then
        usage 1
    fi

    project_uuid=$(create_project "$project_name")

    ## Summary
    printf 'Project Name: %s\n' "$project_name"
    printf 'Project UUID: %s\n' "$project_uuid"
}

function do_setup_server
{
    local facility project_uuid s_hostname server

    printf 'Verbose log is %s\n' "$LOG"

    customdata='{}'

    while getopts "a:f:p:P:n:h" options; do
        case $options in
            a) answers_file="$OPTARG";;
            f) facility="$OPTARG" ;;
            p) project_uuid="$OPTARG" ;;
            P) hardware_plan="$OPTARG" ;;
            n) s_hostname="$OPTARG" ;;
            h) usage 0 ;;
            *) usage 1 ;;
        esac
    done

    if [[ -z $project_uuid ]] || [[ -z $facility ]] ; then
        usage 1
    fi

    if [[ $s_hostname == "headnode" ]]; then
        # Make sure Packet hostnames are unique within a single project.
        # This comes into play when there's a multi-facility UFDS replicated
        # cloud.
        s_hostname="headnode-$facility"
    fi

    if [[ $s_hostname =~ "headnode" ]] && [[ -n $answers_file ]]; then
        customdata="$(cat "$answers_file")"
    fi

    # This is an idempotent operation.
    create_vlans "$project_uuid" "$facility"

    printf 'Creating server...'
    server=$(create_server "$project_uuid" "$facility" "$s_hostname")
    if [[ -z $server ]]; then
        # Trigger errexit if we don't have a server UUID
        false
    fi
    printf 'done.\n'

    printf 'Watch server progress:\n\n\t'
    printf 'ssh %s@sos.%s.platformequinix.com\n\n' "$server" "$facility"

    # wait for server
    printf 'Waiting for server to complete provisioning...'
    wait_for_state active
    printf 'done.\n'
    assign_networks "$project_uuid" "$server"
    printf 'Server provisioning complete.\n'
    if ! [[ $s_hostname =~ "headnode" ]]; then
        show_napi_commands "$s_hostname" "$server"
    fi
}

function get_provisionable_ip
{
    local subnet octet
    local which_end="$2"
    local network
    local prefix_l

    IFS=/ read -ra subnet <<< "$1"
    IFS=. read -ra octet <<< "${subnet[0]}"

    prefix_l="${subnet[1]}"
    if (( prefix_l > 29)) || (( prefix_l < 24 )); then
        printf 'Prefix length %s out of range.\n' "${subnet[1]}"
        return 1
    fi

    case "$which_end" in
        start)
            octet[3]=$(( octet[3] + 2 )) ;;
        end)
            octet[3]=$(( octet[3] + ${prefix_num_ips[$prefix_l]} - 2)) ;;
        *)
            printf 'can only get start or end ip\n'
            return 1
            ;;
    esac

    printf '%s.%s.%s.%s\n' "${octet[0]}" "${octet[1]}" "${octet[2]}" \
        "${octet[3]}"
}

function show_napi_commands
{
    local s_hostname="$1"
    local server="$2"
    local ip_addresses network_name nic_tag obj
    local provision_end provision_start
    local network prefix_l

    nic_tag="external_rack_${s_hostname}r"
    network_name="external_rack_${s_hostname}r"

    json_tmpl='{
  "nic_tag": "%s",
  "name": "%s",
  "subnet": "%s/%s",
  "gateway": "%s",
  "provision_start_ip": "%s",
  "provision_end_ip": "%s",
  "vlan_id": 0,
  "resolvers": [
    "8.8.8.8",
    "8.8.4.4"
  ],
  "description": "External for %s"}'

    ip_addresses=$(metal server get -i "$server" -o json | json ip_addresses | \
        json -o jsony-0 -ac 'this.public==true')

    printf 'sdc-napi /nic_tags -X POST -d '
    printf \'
    printf '{"name":"%s"}' "$nic_tag"
    printf \''\n'

    while read -r obj; do
        gateway=$(json gateway <<< "$obj")
        network=$(json network <<< "$obj")
        prefix_l=$(json cidr <<< "$obj")

        provision_start=$(get_provisionable_ip "${network}/${prefix_l}" start)
        provision_end=$(get_provisionable_ip "${network}/${prefix_l}" end)

        # shellcheck disable=SC2059
        json=$(
            printf "$json_tmpl" "$nic_tag" "$network_name" \
                "$network" "$prefix_l" \
                "$gateway" \
                "$provision_start" \
                "$provision_end" \
                "$s_hostname" | json -o json-0
        )

        printf 'sdc-napi /networks -X POST -d '
        printf \'
        printf '%s' "$json"
        printf \''\n'
    done <<< "$ip_addresses"
}

function wait_for_state
{
    desired_state="$1"
    current_state='unknown'

    while [[ $current_state != "$desired_state" ]]; do
        # Show some progress while waiting.
        sleep 5 ; printf '.'
        current_state=$(metal server get -o json -i "$server" | json state)
    done

}

##
## Main
##

while getopts "h" options; do
    case $options in
        h) usage 0 ;;
        *) echo "$OPTARG" ;;
    esac
done

action="$1"

if [[ -z $action ]]; then
    usage 1
fi

shift

case "$action" in
    project)
        do_setup_project "$@" ;;
    headnode)
        do_setup_server -n headnode "$@" ;;
    cn|compute|computenode)
        n="cn$(openssl rand -hex 3)"
        do_setup_server -n "$n" "$@" ;;
    sn)
        hostname="$1"
        uuid="$2"
        show_napi_commands "${hostname:?}" "${uuid:?}"
        ;;
    *)
        usage 1 ;;
esac
