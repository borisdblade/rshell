#!/usr/bin/env bash


# Get the param
if [ $# -ne 1 ]; then
    echo $0: usage: rsh instance-name
    exit 1
fi

# Instance name
name=$1

# Run the RSH

if [ $name == list ]
then

        aws ec2 describe-instances --output table --query 'Reservations[].Instances[].Tags[?Key==`Name`].Value'

else

        OUTPUT=$(aws ec2 describe-instances --filters "Name=tag:Name,Values='$name'" --output text  --query "Reservations[*].Instances[*].PublicIpAddress")

        ssh ubuntu@$OUTPUT -i ~/.ssh/aws-csa.pem -o ServerAliveInterval=30

fi
