#!/bin/bash
set -eux
# pod env
# init var

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

if [ -z "${CPU}" ]; then
    echo "CPU is not set. Exiting."
    exit 1
fi

# get current vnc index
set +e
vnc_index=$(ss -tunlp | grep -c "0.0.0.0:59")
set -e

using_vnc_port=$((5900 + vnc_index))
echo "vm ${name} using vnc port ${using_vnc_port}"

# set libvirt config
rm -fr /run/libvirt2host && mkdir -p /run/libvirt2host
cp /etc/kube-host-vm/libvirtd.conf /etc/libvirt/libvirtd.conf
cp /etc/kube-host-vm/qemu.conf /etc/libvirt/qemu.conf
# start libvirtd listen
/usr/sbin/libvirtd --listen --verbose
