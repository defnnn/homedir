#!/usr/bin/env python
from cdktf import App, TerraformStack
from constructs import Construct
from imports.aws import AwsProvider, DataAwsAmi, Instance


class MyStack(TerraformStack):
    def __init__(self, scope: Construct, ns: str):
        super().__init__(scope, ns)

        AwsProvider(self, "Aws", region="us-west-1")

        ami = DataAwsAmi(
            self,
            "lookup",
            owners=["099720109477"],
            most_recent=True,
            filter=[
                {"name": "name", "values": ["ubuntu/images/hvm-ssd/ubuntu-*server-*"]},
                {"name": "root-device-type", "values": ["ebs"]},
                {"name": "virtualization-type", "values": ["hvm"]},
            ],
        )

        Instance(self, "hello", ami=ami.image_id, instance_type="t2.nano")


app = App()
MyStack(app, "default")

app.synth()
