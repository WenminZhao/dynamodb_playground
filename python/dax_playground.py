
#
#  Copyright 2010-2019 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
#  This file is licensed under the Apache License, Version 2.0 (the "License").
#  You may not use this file except in compliance with the License. A copy of
#  the License is located at
# 
#  http://aws.amazon.com/apache2.0/
# 
#  This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
#  CONDITIONS OF ANY KIND, either express or implied. See the License for the
#  specific language governing permissions and limitations under the License.
#
#!/usr/bin/env python3
from __future__ import print_function

import os
import time
import amazondax
import botocore.session
import sys
import boto3

region = os.environ.get('AWS_DEFAULT_REGION', 'ap-southeast-1')
table_name = os.environ.get('DAX_TABLE_NAME')
dax_endpoint = os.environ.get('DAX_ENDPOINT')
dax_iam_role = os.environ.get('DAX_IAM_ROLE')

if not table_name:
    sys.exit("DAX_TABLE_NAME must be set in the environment")

sts_client = boto3.client('sts')
assumed_role_object=sts_client.assume_role(RoleArn=dax_iam_role, RoleSessionName="AssumeRoleSession1")
credentials=assumed_role_object['Credentials']
dynamodb = boto3.client('dynamodb', region_name=region, aws_access_key_id=credentials['AccessKeyId'], aws_secret_access_key=credentials['SecretAccessKey'], aws_session_token=credentials['SessionToken'])
if dax_endpoint:
    dax = amazondax.AmazonDaxClient(region_name=region, endpoints=[dax_endpoint], aws_access_key_id=credentials['AccessKeyId'],
                                    aws_secret_access_key=credentials['SecretAccessKey'], aws_session_token=credentials['SessionToken'])

def write_data():
    some_data = 'X' * 1000
    pk_max = 10
    sk_max = 10
    
    for ipk in range(1, pk_max+1):
        for isk in range(1, sk_max+1):
            params = {
                'TableName': table_name,
                'Item': {
                    "pk": {'S': str(ipk)},
                    "sk": {'S': str(isk)},
                    "someData": {'S': some_data},
                    "ttl": {'N': str(int(time.time()) + 60*60*24)}
                }
            }
    
            dynamodb.put_item(**params)
            print("PutItem ({}, {}) suceeded".format(ipk, isk))

def get_item_with_dax():
    if not dax_endpoint:
        sys.exit("DAX_ENDPOINT must be set in the environment")

    pk = 10
    sk = 10
    iterations = 5
    
    start = time.time()
    for i in range(iterations):
        for ipk in range(1, pk+1):
            for isk in range(1, sk+1):
                params = {
                    'TableName': table_name,
                    'Key': {
                        "pk": {'S': str(ipk)},
                        "sk": {'S': str(isk)}
                    }
                }
    
                result = dax.get_item(**params)
                print('.', end='', file=sys.stdout); sys.stdout.flush()
    print()
    
    end = time.time()
    print('Total time (Dax): {} sec - Avg time: {} sec'.format(end - start, (end-start)/iterations))

def get_item_with_dynamodb():
    pk = 10
    sk = 10
    iterations = 5
    
    start = time.time()
    for i in range(iterations):
        for ipk in range(1, pk+1):
            for isk in range(1, sk+1):
                params = {
                    'TableName': table_name,
                    'Key': {
                        "pk": {'S': str(ipk)},
                        "sk": {'S': str(isk)}
                    }
                }
    
                result = dynamodb.get_item(**params)
                print(f'.{result}', end='', file=sys.stdout); sys.stdout.flush()
    print()
    
    end = time.time()
    print('Total time (DynamoDB): {} sec - Avg time: {} sec'.format(end - start, (end-start)/iterations))


if __name__ == '__main__':
    write_data()
    get_item_with_dax()
    get_item_with_dynamodb()