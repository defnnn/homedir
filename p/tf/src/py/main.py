#!/usr/bin/env python
from cdktf import App, TerraformStack
from constructs import Construct
from imports.aws import AwsProvider, Instance


class MyStack(TerraformStack):
    def __init__(self, scope: Construct, ns: str):
        super().__init__(scope, ns)

        AwsProvider(self, "Aws", region="us-east-1")

        Instance(
            self,
            "hello",
            ami="ami-2757f631",
            instance_type="t2.nano",
        )


app = App()
MyStack(app, "default")

app.synth()
