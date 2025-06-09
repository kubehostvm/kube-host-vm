#!/bin/bash
set -eux

# pod env
## if flavor.vcpus < 2: MULTIQUEUE = false
## LSP_UID is the logical switch port kube-ovn vip uid
## shoud set mac as kube-ovn vip type kube_host_vm_vip
## iface id is kubeovn vip logical switch port name

# init var
if [ -z "${MAC_ADDR}" ]; then
    echo "MAC_ADDR is not set. Exiting."
    exit 1
fi
if [ -z "${LSP}" ]; then
    echo "LSP is not set. Exiting."
    exit 1
fi
if [ -z "${LSP_UID}" ]; then
    echo "LSP_UID is not set. Exiting."
    exit 1
fi
last12=${LSP_UID: -12}
dev="tap${last12}"
if [ -z "${CPU}" ]; then
    echo "CPU is not set. Exiting."
    exit 1
fi

multiqueue=true
if [ "$CPU" -lt 2 ]; then
    multiqueue=false
fi
switch='br-int'
set +e
ovsDuplicats=$(ovs-vsctl --no-heading --columns=_uuid,name find Interface external-ids:iface-id="${LSP}" name!="${dev}")
set -e
if [ -n "$ovsDuplicats" ]; then
    for odup in $ovsDuplicats; do
    if [[ $odup == tap* ]]; then
        echo "Deleting duplicate tap device ${odup} from OVS br-int"
        ovs-vsctl del-port "${switch}" "${odup}"
    fi
    done
    for odup in $ovsDuplicats; do
    if [[ $odup != tap* ]]; then
        echo "Deleting duplicate tap device ${odup}"
        ovs-vsctl remove Interface "${odup}" external-ids iface-id
    fi
    done
fi
set +e
duplicats=$(ip link show | grep -B1 "${MAC_ADDR}" | grep -o 'tap[a-zA-Z0-9]\{12\}' | grep -v "${dev}")
set -e
if [ -n "$duplicats" ]; then
    for dup in $duplicats; do
        echo "Deleting duplicate linux tap device ${dup}"
        ip link delete "${dup}"
    done
fi
# if not exists, create it
set +e
exists=$(ip link show "$dev")
set -e
if [ -z "$exists" ]; then
    echo "Creating tap device $dev"
	if [ "$multiqueue" = true ]; then
        ip tuntap add "${dev}" mode tap multi_queue
    else
        ip tuntap add "${dev}" mode tap
    fi
    ip link set "$dev" address "${MAC_ADDR}"
    ip link set "$dev" up
fi
# if not exists, plug it into OVS
set +e
ovsExists=$(ovs-vsctl list interface | grep -w "$dev")
set -e
if [ -z "$ovsExists" ]; then
    echo "Plugging tap device $dev into OVS"
    ovs-vsctl --timeout=30 add-port "${switch}" "${dev}" -- set Interface "${dev}" external_ids:iface-id="${LSP}"
    ip link set "$dev" up
else
    ovs-vsctl set Interface "${dev}" external_ids:iface-id="${LSP}"
    echo "Tap device $dev already plugged into OVS"
fi
