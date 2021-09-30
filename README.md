# Terraform for Deploying DylanMTaylor to AWS

## Usage

To apply this, export these variables and run `terraform apply` (replace with correct credentials; these are invalid examples):

```
  export AWS_ACCESS_KEY_ID="AKIAXTLGDHJKEFDLEXWC"
  export AWS_SECRET_ACCESS_KEY="5+/+m0YNbodtiW+dbEhQgySdXDeF9bOjpE3He1xL"
```

Connecting with SSH:

aws ssm start-session --target [replace me]

Connecting with RDP:

aws ssm start-session --target [replace me]  --document-name AWS-StartPortForwardingSession --parameters "localPortNumber=3389,portNumber=3389"

Using Remmina, connect to `localhost:3389`.