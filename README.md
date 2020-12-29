    # README

### STEPS TO REPRODUCE IN YOUR AWS ACCOUNT

1. Create necessary AWS Resources
   1. Create S3 Bucket to hold Terraform state. I called it `sample-rails-with-terraform-tf-state` but choose a different one because s3 bucket name can't be duplicate
   2. Create DyanmoDB Table to hold Terraform State lock. For primary key, put in `LockID`. I called my table: `sample-rails-with-terraform-tf-state-lock`. You can use the same name.
   3. Create ECR Repo. I named mine: sample-rails-with-terraform. You can also use the same name `sample-rails-with-terraform`
   4. Copy your public key, go to EC2 -> Key pairs -> Actions -> Import Key Pair -> Paste your key and name it `sample-rails-with-api-bastion`
2. Create IAM Policy with the below JSON policy. Replace s3 bucket name and ECR's accountID below.
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "TerraformRequiredPermissions",
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken",
                "ec2:*",
                "rds:DeleteDBSubnetGroup",
                "rds:CreateDBInstance",
                "rds:CreateDBSubnetGroup",
                "rds:DeleteDBInstance",
                "rds:DescribeDBSubnetGroups",
                "rds:DescribeDBInstances",
                "rds:ListTagsForResource",
                "rds:ModifyDBInstance",
                "iam:CreateServiceLinkedRole",
                "rds:AddTagsToResource",
                "iam:CreateRole",
                "iam:GetInstanceProfile",
                "iam:DeletePolicy",
                "iam:DetachRolePolicy",
                "iam:GetRole",
                "iam:AddRoleToInstanceProfile",
                "iam:ListInstanceProfilesForRole",
                "iam:ListAttachedRolePolicies",
                "iam:DeleteRole",
                "iam:TagRole",
                "iam:PassRole",
                "iam:GetPolicyVersion",
                "iam:GetPolicy",
                "iam:CreatePolicyVersion",
                "iam:DeletePolicyVersion",
                "iam:CreateInstanceProfile",
                "iam:DeleteInstanceProfile",
                "iam:ListPolicyVersions",
                "iam:AttachRolePolicy",
                "iam:CreatePolicy",
                "iam:RemoveRoleFromInstanceProfile",
                "logs:CreateLogGroup",
                "logs:DeleteLogGroup",
                "logs:DescribeLogGroups",
                "logs:ListTagsLogGroup",
                "logs:TagLogGroup",
                "ecs:DeleteCluster",
                "ecs:CreateService",
                "ecs:UpdateService",
                "ecs:DeregisterTaskDefinition",
                "ecs:DescribeClusters",
                "ecs:RegisterTaskDefinition",
                "ecs:DeleteService",
                "ecs:DescribeTaskDefinition",
                "ecs:DescribeServices",
                "ecs:CreateCluster",
                "elasticloadbalancing:*"
            ],
            "Resource": "*"
        },
        {
            "Sid": "AllowListS3StateBucket",
            "Effect": "Allow",
            "Action": "s3:ListBucket",
            "Resource": "arn:aws:s3:::<s3-bucket-name>"
        },
        {
            "Sid": "AllowS3StateBucketAccess",
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject"
            ],
            "Resource": "arn:aws:s3:::sample-rails-with-terraform-tf-state/*"
        },
        {
            "Sid": "LimitEC2Size",
            "Effect": "Deny",
            "Action": "ec2:RunInstances",
            "Resource": "arn:aws:ec2:*:*:instance/*",
            "Condition": {
                "ForAnyValue:StringNotLike": {
                    "ec2:InstanceType": [
                        "t2.micro"
                    ]
                }
            }
        },
        {
            "Sid": "AllowECRAccess",
            "Effect": "Allow",
            "Action": [
                "ecr:*"
            ],
            "Resource": "arn:aws:ecr:ap-southeast-1:<account-id>:repository/sample-rails-with-terraform"
        },
        {
            "Sid": "AllowStateLockingAccess",
            "Effect": "Allow",
            "Action": [
                "dynamodb:PutItem",
                "dynamodb:DeleteItem",
                "dynamodb:GetItem"
            ],
            "Resource": [
                "arn:aws:dynamodb:*:*:table/sample-rails-with-terraform-tf-state-lock"
            ]
        }
    ]
}
```
3. Attach that policy to a new 'progammatic-access only' user. Note down this user's ACCESS_KEY_ID and SECRET if you want to use CI/CD. This user can also be used to run terraform.
4. install aws-vault to save your AWS CLI auth token (use the user you just created or the one with administrator access)
https://github.com/99designs/aws-vault
    1. `aws-vault add <aws-user>`
    2. `aws-vault exec <aws-user> --no-session --duration=12h`
5. `cp deploy/sample.tfvars deploy/terraform.tfvars`
6. In `deploy/main.tf`, change line 3, `bucket=replace-your-tf-state-bucket`. Due to limitation of Terraform, string interpolation cannot be performed on backend config block so this needs to be changed manually.
7. Now try `docker-compose -f deploy/docker-compose.yml run --rm terraform init`
8. If init is successful, do `docker-compose -f deploy/docker-compose.yml run --rm terraform plan`, into `docker-compose -f deploy/docker-compose.yml run --rm terraform apply`
### How to run this locally

`docker-compose run --rm api rails db:create`
`docker-compose up`

### How to use Bastion Host to access the Rails server:
0. Look at Terraform apply output and note down bastion_host and db_host (rds-endpoint) outputs
1. Login to bastion host using ssh `ssh ec2-user@<bastion-host-dns>`
2. Login to ECR: `$(aws ecr get-login --no-include-email --region ap-southeast-1)`
3. `docker run -it -e DB_HOST=<RDS-ENDPOINT> -e DB_NAME=postgres -e DB_USER=postgres -e DB_PASS=password <ecr-repo>:latest rails console`

### How to use terraform with this project
Please use aws-vault to login with your Administrator AWS Account before running any terraformm command

To maintain consistent Terraform version between developers, prefix all commands with

`docker-compose -f deploy/docker-compose.yml run --rm terraform <command>`

Useful commands:
0. Initialize Terraform (run once locally)
`docker-compose -f deploy/docker-compose.yml run --rm terraform init`
1. Format terraform files:
`docker-compose -f deploy/docker-compose.yml run --rm terraform fmt`
2. Validate terraform files:
`docker-compose -f deploy/docker-compose.yml run --rm terraform validate`
3. Plan Terraform deployment:
`docker-compose -f deploy/docker-compose.yml run --rm terraform plan`
4. Deploy Terraform resources:
`docker-compose -f deploy/docker-compose.yml run --rm terraform apply`
