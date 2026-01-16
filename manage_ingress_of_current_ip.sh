#!/bin/bash

echo "taken from langqs; backup..."
exit 1

# script for managing ingress into a security group. Common use case is when a Github
# Runner instance (CI/CD) is activated; it has AWS permissions but does not have 
# access through the Bastion EC2 instance to e.g. tunnel to a database and perform
# database migrations. This script can be used for the CI/CD process to:
# 1. with the "ensure" operation, add it's own current public IP to the ingress
#	 list for the bastion security group
# 2. (perform whatever additional setup / tasks it needs to)
# 3. with the "remove" operation, remove it's IP from the ingress list.

# the "ensure" operation will create a new rule if necessary; it can also update
# an existing rule. In a CI/CD context, this latter update case should only happen if 
# a previous run died in the middle. But, this script could also be used by developers
# to add their own updated IP's to the bastions for different environments.

# usage: ./manage_ingress.sh <security_group_id> <group_rule_description>
#
# example for UAT ./manage_ingress.sh sg-0989f47e18dacad30 "TEMP ssh access from the Github Runner"

# testing
# aws ec2 describe-security-groups --group-ids sg-0b25730c7f1cb0157
#aws ec2 describe-security-group-rules \
    #--filters Name="group-id",Values="$security_group_id" \
    #| jq '.SecurityGroupRules[] | select(.IsEgress = false) | select(.Description == "xssh access to the langqs-dev-tfeiler-20241017 VPC for tom f home IP")' | jq -r '.SecurityGroupRuleId'


if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
	echo "usage: ./manage_ingress.sh <security_group_id> <group_rule_description> <ensure|remove>"
	exit 0
fi

if [ "$3" != "ensure" ] && [ "$3" != "remove" ]; then
	echo "usage: ./manage_ingress.sh <security_group_id> <group_rule_description> <ensure|remove>"
	exit 0
fi

security_group_id="$1"
group_rule_description="$2"
operation="$3"

if [ "$operation" == "ensure" ]; then
	my_current_ip=`curl -s ipinfo.io/ip`
	my_exact_cidr="${my_current_ip}/32"

	echo "ensure (update/add) '$my_exact_cidr' is in ingress list of sg '$security_group_id' group with description '$group_rule_description'..."
elif [ "$operation" == "remove" ]; then
	echo "remove group_rule with description '$group_rule_description' from ingress list of sg '$security_group_id'..."
fi

# check that group id is valid...
group_response=`aws ec2 describe-security-groups --group-ids $security_group_id >/dev/null 2>&1`

if [ $? -ne 0 ]; then
	echo "No group found with id '$security_group_id'; cannot proceed"
	exit 1
fi

rules_response=`aws ec2 describe-security-group-rules \
    --filters Name="group-id",Values="$security_group_id"`

if [ $? -ne 0 ]; then
	echo "no rules found at all; unexpected case not coded for..."
	exit 1
fi

group_rule_id=`echo "$rules_response" | jq ".SecurityGroupRules[] | select(.IsEgress == false) | select(.Description == \"$group_rule_description\")" | jq -r '.SecurityGroupRuleId'`

# do we have an existing group by that description, or do we need to create a new one?
if [ "$group_rule_id" == "" ]; then
	echo "No group found with description '$group_rule_description'"

	if [ "$operation" == "remove" ]; then
		# nothing to remove...
		exit 1
	elif [ "$operation" == "ensure" ]; then
		# add a new group
		aws ec2 authorize-security-group-ingress \
			--group-id $security_group_id \
			--ip-permissions IpProtocol=tcp,FromPort=22,ToPort=22,IpRanges="[{Description=\"$group_rule_description\",CidrIp=$my_exact_cidr}]"
	fi
else
	echo "Group found with id '$group_rule_id'"

	if [ "$operation" == "remove" ]; then
		aws ec2 revoke-security-group-ingress \
			--group-id $security_group_id \
			--security-group-rule-ids $group_rule_id
	elif [ "$operation" == "ensure" ]; then
		# modify the existing group
		aws ec2 modify-security-group-rules \
			--group-id $security_group_id \
			--security-group-rules SecurityGroupRuleId=$group_rule_id,SecurityGroupRule="{Description=\"$group_rule_description\",FromPort=22,ToPort=22,IpProtocol=tcp,CidrIpv4=$my_exact_cidr}"
	fi
fi
