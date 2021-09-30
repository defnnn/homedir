#!/usr/bin/env python
from cdktf import App, TerraformStack
from constructs import Construct

from imports.aws import (
    AwsProvider,
    DataAwsAmi,
    Instance,
    OrganizationsAccount,
    OrganizationsOrganization,
)


class MyStack(TerraformStack):
    def __init__(self, scope: Construct, ns: str):
        super().__init__(scope, ns)

        AwsProvider(self, "aws", region="us-west-1")
        AwsProvider(self, "sso", region="us-west-2", alias="sso")

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

        account = "katt"
        domain = "defn.sh"

        for acctype in "net", "log", "lib", "ops", "sec", "hub", "pub", "dev", "dmz":
            OrganizationsAccount(
                self,
                acctype,
                name=acctype,
                email=f"{account}+{acctype}@{domain}",
                iam_user_access_to_billing="ALLOW",
                role_name="OrganizationAccountAccessRole",
                tags={"ManagedBy": "Terraform"},
            )


app = App()
MyStack(app, "default")

app.synth()
