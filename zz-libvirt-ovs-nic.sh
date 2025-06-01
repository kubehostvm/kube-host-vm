#!/bin/bash
# REF: https://github.com/feiskyer/sdn-handbook/blob/master/ovs/ovn-libvirt.md

# ifaceid=$(ovs-vsctl get interface vnet0 external_ids:iface-id)
# ovn-nbctl lsp-add name <switch > $IFACE_ID
# ovs-vsctl get interface <name >external_ids:attached-mac
# MAC_ADDR=$(ovs-vsctl get interface vnet0 external_ids:attached-mac | sed s/\"//g)
# ovn-nbctl lsp-set-addresses $IFACE_ID $MAC_ADDR

# use it in libvirt-vm-nic-xml:
