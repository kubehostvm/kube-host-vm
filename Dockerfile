# syntax = docker/dockerfile:experimental
FROM kubeovn/kube-ovn:v1.14.0

ARG DEBIAN_FRONTEND=noninteractive
# use tsinghua mirror
RUN rm -fr /etc/apt/sources.list.d /etc/apt/*.list
COPY sources.list /etc/apt/sources.list
# test if sources.list is working
RUN apt-get update
# TODO:// simplify
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    j2cli \
    hostname \
    vim \
    tree \
    iproute2 \
    inetutils-ping \
    traceroute \
    arping \
    lsof \
    ncat \
    iptables \
    tcpdump \
    ipset \
    curl \
    openssl \
    easy-rsa \
    dnsutils \
    qemu-kvm \
    qemu-utils \
    qemu-system \
    ifenslave \
    bridge-utils \
    cloud-image-utils \
    libvirt-clients \
    libvirt-daemon-system \
    net-tools && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /etc/localtime