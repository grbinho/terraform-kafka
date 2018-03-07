# Terraform Kafka

This repository contains terraform files that create a Kafka environment. 
By default 5 node zookeeper ensable is created as well as 5 node kafka cluster.

## Usage

Create a file `terraform.tfvars` and add all required variables to it

Example:
```
aws_region = "eu-west-1"
aws_access_key = "<your access key>"
aws_secret_key = "<your secret key>"
amis = {
    "eu-west-1" = "ami-1b791862"
}
```

Scripts expect for AWS pem key to be present in the root directory. With current configuration it should be called 'terraform.pem' and have equivalent key for AWS EC2 instances. You can change this by enditing `tfvars` file.

To create the environment run `terraform apply`
To delete the environment run `terraform destroy`

### Notes
Initialization scripts expect Ubuntu 16.04 as the image. Ami provided in the example is available in the Ireland region. If you use another region, you will probably need to change ami.
