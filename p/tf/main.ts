import { Construct } from 'constructs';
import { App, TerraformStack } from 'cdktf';

import { AwsProvider } from "./.gen/providers/aws";

class MyStack extends TerraformStack {
  constructor(scope: Construct, name: string) {
    super(scope, name);

    new AwsProvider(this, "aws", {
      region: "us-east-1",
    });
  }
}

const app = new App();
new MyStack(app, 'defn');
app.synth();
