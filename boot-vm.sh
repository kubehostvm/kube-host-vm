#!/bin/bash
set -eux
# pod env
# init var

BASE_IMG="/etc/kube-host-vm/noble-server-cloudimg-amd64.img"
BASE_IMG_CLOUD_CFG="/etc/kube-host-vm/cloud-cfg.raw"

if [ -z "${POD_NAME}" ]; then
    echo "POD_NAME is not set. Exiting."
    exit 1
fi
if [ -z "${POD_NAMESPACE}" ]; then
    echo "POD_NAMESPACE is not set. Exiting."
    exit 1
fi
name="${POD_NAMESPACE}-${POD_NAME}"
if [ -z "${CPU}" ]; then
    echo "CPU is not set. Exiting."
    exit 1
fi
# todo:// MAC_ADDRs for multi nic
if [ -z "${MAC_ADDR}" ]; then
    echo "MAC_ADDR is not set. Exiting."
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

smp=$((2 * CPU))
qcow2_file="/etc/kube-host-vm/${name}.qcow2"
if [ ! -f "${qcow2_file}" ]; then
    echo "qcow2 file ${qcow2_file} does not exist, creating."
    if [ ! -f "${BASE_IMG}" ]; then
        echo "base image ${BASE_IMG} does not exist. Exiting."
        exit 1
    fi
    cp "${BASE_IMG}" "${qcow2_file}"

fi
cloud_cfg_file="/etc/kube-host-vm/${name}-cloud-cfg.raw"
# cloud config file is used to inject into the vm cloud-init
if [ ! -f "${cloud_cfg_file}" ]; then
    echo "cloud cfg file ${cloud_cfg_file} does not exist, creating."
    if [ ! -f "${BASE_IMG_CLOUD_CFG}" ]; then
        echo "base image ${BASE_IMG_CLOUD_CFG} does not exist. Exiting."
        exit 1
    fi
    cp "${BASE_IMG_CLOUD_CFG}" "${cloud_cfg_file}"
fi
qemu-system-x86_64 \
  -name "${name}" \
  -m 2G \
  -smp "${smp},cores=${CPU}" \
  -boot menu=on \
  -drive file="${qcow2_file}",format=qcow2,if=virtio,cache=unsafe \
  -drive file="${cloud_cfg_file}",format=raw,if=virtio,media=cdrom \
  -nographic \
  -vnc :0 \
  -netdev tap,id=hn0,ifname="${dev}",script=/etc/kube-host-vm/tap-into-ovs.sh,downscript=/etc/kube-host-vm/untap-into-ovs.sh,vhost=on \
  -device virtio-net-pci,netdev=hn0,id=n0,mac="${MAC_ADDR}" \
  -device virtio-rng-pci -enable-kvm -cpu host,+x2apic
