#!/bin/bash

SERVERS=`openstack server list  -f value | grep "ece-server" | cut -d " " -f 1`

for server in ${SERVERS} ; do
  openstack server delete ${server} 
done


terraform apply --auto-approve
