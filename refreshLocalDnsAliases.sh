#!/bin/bash

# got idea from https://rjackson.dev/posts/setting-up-dns-for-developers-on-osx/
#
# use dnsmasq (and don't forget the bit about configuring OSX resolver to force .test
# lookups to use dnsmasq!). YOu need to manually install dnsmasq and do the /etc/resolver
# bits. But then re-run this command to update dnsmasq.conf with actual live IP addresses
# for whatever. Using this at ICF but could be useful at any job.

# also requires jq

echo "refreshing local dns aliases..."

# double check the AWS profile to use (see ~/.aws/credentials) and the name of the load balancer
# (go into EC2 Dashboard | Load Balancers and find the one associated with e.g. litstream-dev-web)
# and follow instrux at https://aws.amazon.com/premiumsupport/knowledge-center/elb-find-load-balancer-IP/
# there are two, one for each availability zone - one for e.g. 1b and one for 1c. We are fine just grabbing
# a single one and using that

litstream_dev_loadbalancer_ip=`AWS_PROFILE=managed_services_cutover_staging aws ec2 describe-network-interfaces --filters Name=description,Values="ELB awseb-e-q-AWSEBLoa-6HNUZ75SVOM2" --query 'NetworkInterfaces[0].PrivateIpAddresses[*].Association.PublicIp' | jq '.[0]' -r`

echo "got litstream_dev ip: '${litstream_dev_loadbalancer_ip}'"
litstream_dev_entry="address=/litstreamdev.test/${litstream_dev_loadbalancer_ip}"

# if I add more entries over time, I can combine them here, one per line
entries=$litstream_dev_entry

echo "writing dnsmasq.conf..."
echo $entries | sudo tee /usr/local/etc/dnsmasq.conf

echo "restarting dnsmasq..."
sudo brew services restart dnsmasq

echo ""
echo ""
echo "done! Use e.g. https://litstreamdev.test to access dev instance!"
