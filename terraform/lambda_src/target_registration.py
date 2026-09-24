import os
import boto3

ec2 = boto3.client('ec2')
elbv2 = boto3.client('elbv2')
autoscaling = boto3.client('autoscaling')

TARGET_GROUP_ARN = os.environ['TARGET_GROUP_ARN']

def handler(event, context):
    detail = event['detail']
    instance_id = detail['EC2InstanceId']
    lifecycle_hook_name = detail['LifecycleHookName']
    asg_name = detail['AutoScalingGroupName']
    lifecycle_action_token = detail['LifecycleActionToken']
    transition = detail['LifecycleTransition']

    result = 'CONTINUE'
    try:
        resp = ec2.describe_instances(InstanceIds=[instance_id])
        private_ip = resp['Reservations'][0]['Instances'][0]['PrivateIpAddress']

        if transition == 'autoscaling:EC2_INSTANCE_LAUNCHING':
            elbv2.register_targets(
                TargetGroupArn=TARGET_GROUP_ARN,
                Targets=[{'Id': private_ip, 'AvailabilityZone': 'all'}]
            )
        elif transition == 'autoscaling:EC2_INSTANCE_TERMINATING':
            elbv2.deregister_targets(TargetGroupArn=TARGET_GROUP_ARN, Targets=[{'Id': private_ip}])
    except Exception as e:
        print(f"Error handling {transition} for {instance_id}: {e}")
        result = 'ABANDON'

    autoscaling.complete_lifecycle_action(
        LifecycleHookName=lifecycle_hook_name,
        AutoScalingGroupName=asg_name,
        LifecycleActionToken=lifecycle_action_token,
        LifecycleActionResult=result
    )