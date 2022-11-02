# iv-terraform

# Terraform template for AWS Cloudfront/S3 & ECS/Fargate

This terraform setup can be used to setup the AWS infrastructure
for a cloudfrond served website hosted on AWS S3 and a dockerized application running on ECS with Fargate launch
configuration.

## Resources

This setup creates the following resources:

- Route53
- S3
- Cloudfront
- VPC
- one public and one private subnet per AZ
- Routing tables for the subnets
- Internet Gateway for public subnets
- NAT gateways with attached Elastic IPs for the private subnet
- Two security groups
  - one that allows HTTP/HTTPS access
  - one that allows access to the specified container port
- An ALB + target group with listeners for port 80 and 443
- An ECR for the docker images
- An ECS cluster with a service (incl. auto scaling policies for CPU and memory usage)
  and task definition to run docker containers from the ECR (incl. IAM execution role)
- Secrets - a Terraform module that creates many secrets based on a `map` input value, and has a list of secret ARNs as an output value


![alt text](https://github.com/Pip7747/Notebook-/blob/main/project7.png)

### Get Started building your own infrastructure

- Install terraform on MacOS with `brew install terraform`
- For other system https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli`
- execute `terraform init`, it will initialize your local terraform and connect it to the state store, and it will download all the necessary providers
- execute `terraform plan -var-file="secret.tfvars" -var-file="environment.tfvars" -out="out.plan"` - this will calculate the changes terraform has to apply and creates a plan. If there are changes, you will see them. Check if any of the changes are expected, especially deletion of infrastructure.
- if everything looks good, you can execute the changes with `terraform apply out.plan`

