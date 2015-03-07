HP Helion OpenStack Community Edition - Virtual Install
=======================================================

Prerequisites
-------------

### Hardware ###

Get a physical server with at least 64GB memory, virtualization
capable CPU-s, and at least 200GB free disk space. A well
performing SSD disk subsystem suggested to speed up deployment,
but the demo works with simple SATA hdd.

### Operating System ###

Deploy a clean 64bit Ubuntu 14.04 OS, register at HP site
and download HP Helion Community Edition 1.4 tar.gz.

### Generate a new privatekey ###

Create a new privatekey as a root user with empty an
passphrase.

    $ sudo -i
    $ ssh-keygen -t rsa

### Deploy package dependencies ###

    $ apt-get install -y libvirt-bin openvswitch-switch python-libvirt qemu-system-x86
    $apt-get install -y telnet curl byobu

### Configure NTP service ###

`NOTICE` NTP service is mandatory to keep time synced between cloud nodes,
without date sync the deployment can produce strange errors randomly.

Follow the NTP setup guide here:

http://docs.hpcloud.com/helion/openstack/install/ntp/


Installation
------------

### Deploy the seed vm ###

Extract Helion_Openstack_Community_V1.4.tar.gz under /opt directory:

    host> cd /opt
    host> md5sum ~/Helion_Openstack_Community_V1.4.tar.gz
    e397c2795359d959376e9f3b2fe276e4  /root/Helion_Openstack_Community_V1.4.tar.gz
    host> tar -xzvf ~/Helion_Openstack_Community_V1.4.tar.gz

Start seed vm deployment:

    host> export HP_VM_MODE=y
    host> time bash -x /opt/tripleo/tripleo-incubator/scripts/hp_ced_host_manager.sh \
      --create-seed 2>&1|tee seed-install.log
    ...
    real    5m7.533s
    user    0m0.705s
    sys     0m8.403s

### Install the undercloud ###

Login to seed vm:

    host> ssh 192.0.2.1

Set the environment variables:

    seed> export LANG=C
    seed> export OVERCLOUD_NTP_SERVER=192.168.122.1
    seed> export UNDERCLOUD_NTP_SERVER=192.168.122.1
    seed> export OVERCLOUD_SWIFTSTORAGESCALE=1
    seed> export OVERCLOUD_SWIFT_REPLICA_COUNT=1
    seed> export OVERCLOUD_CONTROLSCALE=1
    seed> export OVERCLOUD_COMPUTESCALE=2
    seed> export OVERCLOUD_STACK_TIMEOUT=120
    seed> export UNDERCLOUD_STACK_TIMEOUT=120
    seed> export OVERCLOUD_NEUTRON_DVR=False

Start undercloud deployment:

    seed> time bash -x /root/tripleo/tripleo-incubator/scripts/hp_ced_installer.sh \
      --skip-demo --skip-install-overcloud 2>&1|tee undercloud-install.log
    ...
    real    14m59.347s
    user    1m11.924s
    sys     0m14.519s

### Install the overcloud ###

    seed> bash -x /root/tripleo/tripleo-incubator/scripts/hp_ced_installer.sh \
      --skip-install-seed --skip-install-undercloud 2>&1|tee overcloud-install.log

Access overcloud dashboard
--------------------------

Get the helper scripts from hphelioncedemo git repository:

    seed> git clone https://github.com/mkissam/hphelioncedemo.git

Display account information:

    seed> bash hphelioncedemo/scripts/endpoints.sh
    ## UNDERCLOUD ##
    undercloud.ip:                  192.0.2.2
    undercloud_dashboard.url:       http://192.0.2.2
    undercloud_dashboard.user:      admin
    undercloud_dashboard.password:  12d24XXXXXXXXXXXXXXXXXXXXXXXX
    undercloud_kibana.url:          http://192.0.2.2:81
    undercloud_kibana.user:         kibana
    undercloud_kibana.password:     42e19XXXXXXXXXXXXXXXXXXXXXXXX
    undercloud_icinga.url:          http://192.0.2.2/icinga
    undercloud_icinga.user:         icingaadmin
    undercloud_icinga.password:     icingaadmin

    ## OVERCLOUD ##
    overcloud.ip:                  192.0.2.21
    overcloud_dashboard.url:       http://192.0.2.21
    overcloud_dashboard.user:      admin
    overcloud_dashboard.password:  e95d24XXXXXXXXXXXXXXXXXXXXXXXX

Login at `undercloud_dashboard_url` with `undercloud_dashboard_user` / `undercloud_dashboard_password`

Cleaning up
-----------

If you want to repeat or retry the deployment process, just remove the seed vm, undercloud vm and
overcloud vms from the host os, using the scripts/cleanup.sh from hphelioncedemo.git repository.

