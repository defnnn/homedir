#!/usr/bin/env python
from cdktf import App, TerraformStack
from constructs import Construct

from imports.aws import AwsProvider, DataAwsAmi, Instance, OrganizationsOrganization


class MyStack(TerraformStack):
    def __init__(self, scope: Construct, ns: str):
        super().__init__(scope, ns)

        AwsProvider(self, "Aws", region="us-west-1")

        OrganizationsOrganization(
            self,
            "org",
            feature_set="ALL",
            enabled_policy_types=["SERVICE_CONTROL_POLICY", "TAG_POLICY"],
            aws_service_access_principals=[
                "cloudtrail.amazonaws.com",
                "config.amazonaws.com",
                "ram.amazonaws.com",
                "ssm.amazonaws.com",
                "sso.amazonaws.com",
                "tagpolicies.tag.amazonaws.com",
            ],
        )

        ami = DataAwsAmi(
            self,
            "lookup",
            owners=["099720109477"],
            most_recent=True,
            filter=[
                {
                    "name": "name",
                    "values": ["ubuntu/images/hvm-ssd/ubuntu-focal-*server-*"],
                },
                {"name": "root-device-type", "values": ["ebs"]},
                {"name": "virtualization-type", "values": ["hvm"]},
            ],
        )


app = App()
MyStack(app, "default")

app.synth()
