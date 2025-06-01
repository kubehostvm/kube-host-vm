#!/bin/bash
set -eux
# pod env
# init var

# BASE_IMG="/etc/kube-host-vm/img/noble-server-cloudimg-amd64.img"
BASE_IMG="/etc/kube-host-vm/img/qemu-cirros.qcow2"
BASE_IMG_CLOUD_CFG="/etc/kube-host-vm/img/cloud-cfg.raw"

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
qcow2_file="/etc/kube-host-vm/img/${name}.qcow2"
if [ ! -f "${qcow2_file}" ]; then
    echo "qcow2 file ${qcow2_file} does not exist, creating."
    if [ ! -f "${BASE_IMG}" ]; then
        echo "base image ${BASE_IMG} does not exist. Exiting."
        exit 1
    fi
    cp "${BASE_IMG}" "${qcow2_file}"

fi
cloud_cfg_file="/etc/kube-host-vm/img/${name}-cloud-cfg.raw"
# cloud config file is used to inject into the vm cloud-init
if [ ! -f "${cloud_cfg_file}" ]; then
    echo "cloud cfg file ${cloud_cfg_file} does not exist, creating."
    if [ ! -f "${BASE_IMG_CLOUD_CFG}" ]; then
        echo "base image ${BASE_IMG_CLOUD_CFG} does not exist. Exiting."
        exit 1
    fi
    cp "${BASE_IMG_CLOUD_CFG}" "${cloud_cfg_file}"
fi

multiqueue=true
if [ "$CPU" -lt 2 ]; then
    multiqueue=false
fi

# get current vnc index
set +e
vnc_index=$(ss -tunlp | grep -c "0.0.0.0:59")
set -e

using_vnc_port=$((5900 + vnc_index))
echo "vm ${name} using vnc port ${using_vnc_port}"

# refer to https://www.linux-kvm.org/page/Multiqueue
vectors=$((CPU * 2 + 2)) # N for tx queues, N for rx queues, 1 for config, and one for possible control vq

if [ "$multiqueue" = true ]; then
    qemu-system-x86_64 \
        -name "${name}" \
        -m 2G \
        -smp "${smp},cores=${CPU}" \
        -boot menu=on \
        -drive file="${qcow2_file}",format=qcow2,if=virtio,cache=unsafe \
        -drive file="${cloud_cfg_file}",format=raw,if=virtio,media=cdrom \
        -nographic \
        -vnc :"${vnc_index}" \
        -netdev tap,id=hn0,ifname="${dev}",script=/etc/kube-host-vm/tap-into-ovs.sh,downscript=no,vhost=on,queues="${CPU}" \
        -device virtio-net-pci,mq=on,vectors="${vectors}",netdev=hn0,id=n0,mac="${MAC_ADDR}" \
        -device virtio-rng-pci -enable-kvm -cpu host,+x2apic
else
    qemu-system-x86_64 \
        -name "${name}" \
        -m 2G \
        -smp "${smp},cores=${CPU}" \
        -boot menu=on \
        -drive file="${qcow2_file}",format=qcow2,if=virtio,cache=unsafe \
        -drive file="${cloud_cfg_file}",format=raw,if=virtio,media=cdrom \
        -nographic \
        -vnc :"${vnc_index}" \
        -netdev tap,id=hn0,ifname="${dev}",script=/etc/kube-host-vm/tap-into-ovs.sh,downscript=no,vhost=on \
        -device virtio-net-pci,netdev=hn0,id=n0,mac="${MAC_ADDR}" \
        -device virtio-rng-pci -enable-kvm -cpu host,+x2apic
fi
