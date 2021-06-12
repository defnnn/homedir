package main

import (
	"github.com/aws/constructs-go/constructs/v3"
	"github.com/hashicorp/terraform-cdk-go/cdktf"

  "cdk.tf/go/stack/generated/hashicorp/aws"
  "github.com/aws/jsii-runtime-go"
)

func NewMyStack(scope constructs.Construct, id string) cdktf.TerraformStack {
	stack := cdktf.NewTerraformStack(scope, &id)

  aws.NewAwsProvider(stack, jsii.String("aws"), &aws.AwsProviderConfig{
        Region: jsii.String("us-east-1"),
    })

  instance := aws.NewInstance(stack, jsii.String("hello"), &aws.InstanceConfig{
        Ami:          jsii.String("ami-2757f631"),
        InstanceType: jsii.String("t2.nano"),
    })

	return stack
}

func main() {
	app := cdktf.NewApp(nil)

	NewMyStack(app, "default")

	app.Synth()
}
