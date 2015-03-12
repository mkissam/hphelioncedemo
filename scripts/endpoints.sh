#!/bin/bash
# helper script to display HP Helion OpenStack CE admin accounts and
# endpoints in a human consumable format. :)

. /root/stackrc
UNDERCLOUD_IP=$(nova list | grep "undercloud" | awk ' { print $12 } ' | sed s/ctlplane=// )
. /root/tripleo/tripleo-undercloud-passwords

column -t -e -s !<<EOF
## UNDERCLOUD ##
undercloud.ip:!$UNDERCLOUD_IP
undercloud_dashboard.url:!http://$UNDERCLOUD_IP
undercloud_dashboard.user:!admin
undercloud_dashboard.password:!$UNDERCLOUD_ADMIN_PASSWORD
undercloud_kibana.url:!http://$UNDERCLOUD_IP:81
undercloud_kibana.user:!kibana
undercloud_kibana.password:!$UNDERCLOUD_KIBANA_PASSWORD
undercloud_icinga.url:!http://$UNDERCLOUD_IP/icinga
undercloud_icinga.user:!icingaadmin
undercloud_icinga.password:!icingaadmin
EOF

TE_DATAFILE=/root/tripleo/ce_env.json . /root/tripleo/tripleo-incubator/undercloudrc
OVERCLOUD_IP=$(heat output-show overcloud KeystoneURL | cut -d: -f2 | sed s,/,,g )

. /root/tripleo/tripleo-overcloud-passwords

column -t -e -s !<<EOF

## OVERCLOUD ##
overcloud.ip:!$OVERCLOUD_IP
overcloud_dashboard.url:!http://$OVERCLOUD_IP
overcloud_dashboard.admin.user:!admin
overcloud_dashboard.admin.password:!$OVERCLOUD_ADMIN_PASSWORD
overcloud_dashboard.demo.user:!demo
overcloud_dashboard.demo.password:!$OVERCLOUD_DEMO_PASSWORD
EOF
