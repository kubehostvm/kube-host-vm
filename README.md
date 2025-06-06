# kube-host-vm
k8s cluster host the virtual machine

![kubehostvm](khm.png)


## 1. k8s run a host network pod to run a vm

### 1.1 qemu run vm

参考 kube-qemu-vm.yaml

### 1.2 libvirt run vm

参考 kube-libvirt-vm.yaml

先创建 vm ip，使用 01-vip.yaml

```bash
▶ k get vip
NAME   V4IP         V6IP   MAC                 SUBNET        TYPE
vm01   10.16.0.77          02:94:b0:9e:52:29   ovn-default   kube_host_vm_vip

▶ k ko nbctl show
switch 71ef42c1-8206-42ac-8181-ebc76b589777 (ovn-default)
    port coredns-bb4ff7b7b-v44dz.kube-system
        addresses: ["c6:a3:ee:2c:8a:1b 10.16.0.9"]
    port coredns-bb4ff7b7b-74f4d.kube-system
        addresses: ["52:34:8f:98:05:71 10.16.0.5"]
    port vm01.default # lsp 名字
        addresses: ["02:94:b0:9e:52:29 10.16.0.77"]
    port kube-ovn-pinger-jsmgx.kube-system
        addresses: ["86:33:9d:e5:53:84 10.16.0.8"]
    port ovn-default-ovn-cluster
        type: router
        router-port: ovn-cluster-ovn-default
```

然后使用 LSP 的名字和 MAC地址构造虚拟机网卡部分的 XML：参考 libvirt-ovs-nic.xml


## 3. debug

### 3.1 关闭 host libvirtd

```bash

sudo systemctl disable libvirtd
sudo systemctl stop libvirtd

# 禁用 libvirt 的 socket 拉起 libvirtd 服务
sudo systemctl disable libvirtd.socket
sudo systemctl disable libvirtd-ro.socket
sudo systemctl disable libvirtd-admin.socket

sudo systemctl stop libvirtd.socket
sudo systemctl stop libvirtd-ro.socket
sudo systemctl stop libvirtd-admin.socket

# 确认无进程
ps -aux | grep libvirt

systemctl cat libvirtd
systemctl cat libvirtd.socket
systemctl cat libvirtd-ro.socket
systemctl cat libvirtd-admin.socket

```

## 4. virsh connect socket

```bash

export LIBVIRT_DEFAULT_URI=qemu+unix:///system?socket=/run/libvirt2host/libvirt-sock

virsh list

```