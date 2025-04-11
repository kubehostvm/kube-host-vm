#!/bin/bash
set -eux
# pod env
# init var
if [ -z "${POD_UID}" ]; then
    echo "POD_UID is not set. Exiting."
    exit 1
fi
last12=${POD_UID: -12}
dev="tap${last12}"
if [ -z "${POD_NAME}" ]; then
    echo "POD_NAME is not set. Exiting."
    exit 1
fi
# todo:// LSPs for multi nic
if [ -z "${LSP}" ]; then
    echo "LSP is not set. Exiting."
    exit 1
fi
if [ -z "${CPU}" ]; then
    echo "CPU is not set. Exiting."
    exit 1
fi
# todo:// MAC_ADDRs for multi nic
if [ -z "${MAC_ADDR}" ]; then
    echo "MAC_ADDR is not set. Exiting."
    exit 1
fi

qemu-system-x86_64 \
  -name "${POD_NAME}" \
  -m 2G \
  -smp "${CPU}" \
  -boot menu=on \
  -drive file=/etc/kube-host-vm/"${POD_NAME}".qcow2,format=qcow2,if=virtio \
  -drive file=/etc/kube-host-vm/"${POD_NAME}"-cloud-cfg.img,format=raw,if=virtio,media=cdrom \
  -nographic \
  -vnc :0 \
  -netdev tap,id=net0,ifname="${dev}",script=/etc/kube-host-vm/tap-into-ovs.sh,downscript=/etc/kube-host-vm/untap-into-ovs.sh,vhost=on \
  -device virtio-net-pci,netdev=net0,mac="${MAC_ADDR}" \
  -device virtio-rng-pci -enable-kvm -cpu host,+x2apic