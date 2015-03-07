#!/bin/bash
# Remove all virtual machines including seed vm,
# undercloud vm, and all overcloud vms.
#
# This script must be executed from the host OS.

virsh list --all --name | while read f
do
  virsh destroy $f
  virsh undefine $f
done
rm -rf /var/lib/libvirt/images/*
