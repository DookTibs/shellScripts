#!/bin/bash

# 2024 - this old approach doesn't wrk on my new laptop. Instead let's just monkey with /etc/hosts

# got idea from https://rjackson.dev/posts/setting-up-dns-for-developers-on-osx/
#
# use dnsmasq (and don't forget the bit about configuring OSX resolver to force .test
# lookups to use dnsmasq!). YOu need to manually install dnsmasq and do the /etc/resolver
# bits. But then re-run this command to update dnsmasq.conf with actual live IP addresses
# for whatever. Using this at ICF but could be useful at any job.

# also requires jq

# echo "NOT CURRENTLY WORKING ON MY NEW LAPTOP -- NEED TO TROUBLESHOOT"
# echo "OLD IP (fast):"
# cat /usr/local/etc/dnsmasq.conf
# echo "proceeding as is..."

echo "refreshing local dns aliases..."

# double check the AWS profile to use (see ~/.aws/credentials) and the name of the load balancer
# (go into EC2 Dashboard | Load Balancers and find the one associated with e.g. litstream-dev-web)
# and follow instrux at https://aws.amazon.com/premiumsupport/knowledge-center/elb-find-load-balancer-IP/
# there are two, one for each availability zone - one for e.g. 1b and one for 1c. We are fine just grabbing
# a single one and using that

litstream_dev_loadbalancer_ip=`AWS_PROFILE=managed_services_cutover_staging aws ec2 describe-network-interfaces --filters Name=description,Values="ELB awseb-e-q-AWSEBLoa-6HNUZ75SVOM2" --query 'NetworkInterfaces[0].PrivateIpAddresses[*].Association.PublicIp' | jq '.[0]' -r`

echo "got litstream_dev ip: '${litstream_dev_loadbalancer_ip}'"
# litstream_dev_entry="address=/litstreamdev.test/${litstream_dev_loadbalancer_ip}"

# changed for /etc/hosts approach
litstream_dev_entry="${litstream_dev_loadbalancer_ip} litstreamdev.test"

# if I add more entries over time, I can combine them here, one per line
entries=$litstream_dev_entry


if [ 1 -eq 0 ]; then
	echo "writing dnsmasq.conf..."
	echo $entries | sudo tee /usr/local/etc/dnsmasq.conf

	echo "restarting dnsmasq..."
	sudo brew services restart dnsmasq
fi


# ORIGINAL /etc/hosts BEFORE I MONKEYED WITH IT:

if [ 1 -eq 0 ]; then
	[tfeiler@ICF shellScripts]$ ls -ltr /etc/hosts
	-rw-r--r--  1 root  wheel  349 Sep 19 11:00 /etc/hosts

	##
	# Host Database
	#
	# localhost is used to configure the loopback interface
	# when the system is booting.  Do not change this entry.
	##
	127.0.0.1	localhost
	255.255.255.255	broadcasthost
	::1             localhost
fi



# https://stackoverflow.com/questions/5227295/how-do-i-delete-all-lines-in-a-file-starting-from-after-a-matching-line
#
# cat /etc/hosts

# cat /etc/hosts | sed -n '/# CUSTOM START/q;p'

echo "making safe backup of /etc/hosts in ~/HOSTS_JUST_IN_CASE..."
cp /etc/hosts ~/HOSTS_JUST_IN_CASE

cat /etc/hosts | sed '/# CUSTOM START/q' > /tmp/onthefly.hosts
echo "$entries" >> /tmp/onthefly.hosts
sudo chown root /tmp/onthefly.hosts
sudo mv /tmp/onthefly.hosts /etc/hosts


echo ""
echo ""
echo "done! Use e.g. https://litstreamdev.test to access dev instance!"
