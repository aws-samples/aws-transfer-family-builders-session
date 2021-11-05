#!/bin/bash
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this
# software and associated documentation files (the "Software"), to deal in the Software
# without restriction, including without limitation the rights to use, copy, modify,
# merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
# PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# Hard coded variables
export STACK_NAME=transfer-builders-session
export MOUNT_ADMIN='/mnt/admin'
export MOUNT_RISKADJUSTER1='/mnt/riskadjuster1'
export MOUNT_RISKADJUSTER2='/mnt/riskadjuster2'

# Install dependencies
sudo yum install jq amazon-efs-utils -y

# Variables from CloudFormation Output
export EFS_FILESYSTEM=`aws cloudformation describe-stacks | jq -r --arg STACK_NAME "$STACK_NAME" '.Stacks[] | select(.StackName==$STACK_NAME) | .Outputs[] | select(.OutputKey=="FileSystemID") | .OutputValue'`
export EFS_FILESYSTEM_ARN=`aws cloudformation describe-stacks | jq -r --arg STACK_NAME "$STACK_NAME" '.Stacks[] | select(.StackName==$STACK_NAME) | .Outputs[] | select(.OutputKey=="FileSystemArn") | .OutputValue'`
export EFS_ACCESSPOINT_ADMIN=`aws cloudformation describe-stacks | jq -r --arg STACK_NAME "$STACK_NAME" '.Stacks[] | select(.StackName==$STACK_NAME) | .Outputs[] | select(.OutputKey=="AccessPoint1ID") | .OutputValue'`
export EFS_ACCESSPOINT_RISKADJUSTER1=`aws cloudformation describe-stacks | jq -r --arg STACK_NAME "$STACK_NAME" '.Stacks[] | select(.StackName==$STACK_NAME) | .Outputs[] | select(.OutputKey=="RiskAdjuster1AccessPointID") | .OutputValue'`
export EFS_ACCESSPOINT_RISKADJUSTER2=`aws cloudformation describe-stacks | jq -r --arg STACK_NAME "$STACK_NAME" '.Stacks[] | select(.StackName==$STACK_NAME) | .Outputs[] | select(.OutputKey=="RiskAdjuster2AccessPointID") | .OutputValue'`
export EFS_MOUNT_TARGET_IP=`aws cloudformation describe-stacks | jq -r --arg STACK_NAME "$STACK_NAME" '.Stacks[] | select(.StackName==$STACK_NAME) | .Outputs[] | select(.OutputKey=="MountTarget1IPAddress") | .OutputValue'`
export S3_BUCKET=`aws cloudformation describe-stacks | jq -r --arg STACK_NAME "$STACK_NAME" '.Stacks[] | select(.StackName==$STACK_NAME) | .Outputs[] | select(.OutputKey=="S3BucketICD10Codes") | .OutputValue'`

# Create mount points
sudo mkdir $MOUNT_ADMIN
sudo mkdir $MOUNT_RISKADJUSTER1
sudo mkdir $MOUNT_RISKADJUSTER2

# Mount root directory with admin with TLS
sudo mount -t efs -o tls,accesspoint=$EFS_ACCESSPOINT_ADMIN,mounttargetip=$EFS_MOUNT_TARGET_IP $EFS_FILESYSTEM:/ $MOUNT_ADMIN

# Configure folders and permissions
sudo mkdir -p $MOUNT_ADMIN/Provider1/SiteA
sudo mkdir -p $MOUNT_ADMIN/Provider1/SiteB
sudo mkdir -p $MOUNT_ADMIN/Provider2/SiteA
sudo chmod 751 $MOUNT_ADMIN/Provider*/Site*
sudo chmod 751 $MOUNT_ADMIN/Provider*
sudo chgrp -R 3000 $MOUNT_ADMIN/Provider1
sudo chgrp -R 4000 $MOUNT_ADMIN/Provider2
sudo chown 3001 $MOUNT_ADMIN/Provider1/SiteA
sudo chown 3002 $MOUNT_ADMIN/Provider1/SiteB
sudo chown 4001 $MOUNT_ADMIN/Provider2/SiteA

# Mount different levels of access for the two risk adjuster users with TLS
sudo mount -t efs -o tls,accesspoint=$EFS_ACCESSPOINT_RISKADJUSTER1,mounttargetip=$EFS_MOUNT_TARGET_IP $EFS_FILESYSTEM:/ $MOUNT_RISKADJUSTER1
sudo mount -t efs -o tls,accesspoint=$EFS_ACCESSPOINT_RISKADJUSTER2,mounttargetip=$EFS_MOUNT_TARGET_IP $EFS_FILESYSTEM:/ $MOUNT_RISKADJUSTER2

# Upload reference data to DynamoDB
while IFS=, read -r code description
do
    export description_formatted=`echo $description | cut -d "\"" -f 2`
    aws dynamodb put-item --table-name ICD10Codes --item '{"code": {"S": "'"${code}"'"}, "description": {"S": "'"${description_formatted}"'"}}'
done < /home/ec2-user/environment/init/CommonICD10Codes.csv
