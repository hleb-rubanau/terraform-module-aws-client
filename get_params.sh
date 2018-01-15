#!/bin/bash


ECS_CLUSTER_NAME=$( jq '.cluster_name' -r )

for e in $(env | cut -f1 -d= | grep -E '^TF_VAR_AWS' ) ; do
    shortname="$(echo "$e" | sed -e 's/^TF_VAR_//' )"
    export $shortname=${!e}
done

jqfilter='.containerInstanceArns | join(",")'
ecs_instances_ids=$(aws ecs list-container-instances --cluster "${ECS_CLUSTER_NAME}" --status ACTIVE | jq "${jqfilter}" -r )

jqfilter='[ .containerInstances[] | .ec2InstanceId ] | join (",")'
ec2_instances_ids=$( aws ecs describe-container-instances --container-instances "$ecs_instances_ids" | jq "${jqfilter}" -r )

jqfilter=' .Reservations[] | .Instances '
result=$( aws ec2 describe-instances --instance-ids "${ec2_instances_ids}" |  jq "${jqfilter}"  )

function get_vs() {
    parameter=$1
    echo "$result" | jq '[ .[] | .'$parameter' ] | join(",") ' 
}

ids=$( get_vs InstanceId )
private_ips=$( get_vs PrivateIpAddress )
public_ips=$( get_vs PublicIpAddress )
private_dns=$( get_vs PrivateDnsName )
public_dns=$( get_vs PublicDnsName )

echo '{ "ids": '$ids' , "private_ips": '$private_ips', "public_ips": '$public_ips' , "private_dns": '$private_dns', "public_dns": '$public_dns' }'
