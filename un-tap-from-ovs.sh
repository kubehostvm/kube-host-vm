#!/bin/bash

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

switch='br-int'
ovs-vsctl --timeout=30 --if-exist del-port "${switch}" "${dev}"
# if exists, delete it
set +e
exists=$(ip link show "$dev" 2>/dev/null)
set -e

if [ -n "$exists" ]; then
    echo "Deleting tap device $dev"
    ip link delete "$dev"
else
    echo "Tap device $dev does not exist, not deleting"
fi
