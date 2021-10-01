#!/usr/bin/env python
from cdktf import App, Fn, TerraformStack
from constructs import Construct

from imports.aws import (
    AwsProvider,
    DataAwsAmi,
    DataAwsIdentitystoreGroup,
    DataAwsSsoadminInstances,
    Instance,
    OrganizationsAccount,
    OrganizationsOrganization,
    SsoadminAccountAssignment,
    SsoadminManagedPolicyAttachment,
    SsoadminPermissionSet,
)


class MyStack(TerraformStack):
    def __init__(self, scope: Construct, ns: str):
        super().__init__(scope, ns)

        AwsProvider(self, "aws", region="us-west-2")

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

        ssoadmin_instances = DataAwsSsoadminInstances(self, "sso_instance")
        identitystore_group = DataAwsIdentitystoreGroup(
            self,
            "administrators_sso_group",
            identity_store_id="empty",
            filter=[
                {"attributePath": "DisplayName", "attributeValue": "Administrators"}
            ],
        )
        identitystore_group.add_override(
            "identity_store_id",
            "${[ for e in " + ssoadmin_instances.fqn + ".identity_store_ids: e ][0]}",
        )

        sso_permission_set_admin = SsoadminPermissionSet(
            self,
            "admin_sso_permission_set",
            name="Administrator",
            instance_arn="empty",
            session_duration="PT2H",
            tags={"ManagedBy": "Terraform"},
        )
        sso_permission_set_admin.add_override(
            "instance_arn", "${[ for e in " + ssoadmin_instances.fqn + ".arns: e ][0]}"
        )

        SsoadminManagedPolicyAttachment(
            self,
            "admin_sso_managed_policy_attachment",
            instance_arn=sso_permission_set_admin.instance_arn,
            permission_set_arn=sso_permission_set_admin.arn,
            managed_policy_arn="arn:aws:iam::aws:policy/AdministratorAccess",
        )

        account = "katt"
        domain = "defn.sh"

        for acctype in (
            "katt",
            "net",
            "log",
            "lib",
            "ops",
            "sec",
            "hub",
            "pub",
            "dev",
            "dmz",
        ):
            if acctype == account:
                acct = OrganizationsAccount(
                    self,
                    acctype,
                    name=acctype,
                    email=f"{account}@{domain}",
                    tags={"ManagedBy": "Terraform"},
                )
            else:
                acct = OrganizationsAccount(
                    self,
                    acctype,
                    name=acctype,
                    email=f"{account}+{acctype}@{domain}",
                    iam_user_access_to_billing="ALLOW",
                    role_name="OrganizationAccountAccessRole",
                    tags={"ManagedBy": "Terraform"},
                )

            SsoadminAccountAssignment(
                self,
                f"{acctype}_admin_sso_account_assignment",
                instance_arn=sso_permission_set_admin.instance_arn,
                permission_set_arn=sso_permission_set_admin.arn,
                principal_id=identitystore_group.group_id,
                principal_type="GROUP",
                target_id=acct.id,
                target_type="AWS_ACCOUNT",
            )


app = App()
MyStack(app, "default")

app.synth()
