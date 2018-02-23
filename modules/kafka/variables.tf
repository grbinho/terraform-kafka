variable security_group_id {
    description= "AWS Security group id in which to place this instance"
}
variable subnet_id {}
variable kafka_version {}
variable ami {}
variable aws_key_name {
    description = "Name of the security key defined in AWS that will be put on EC2 instances"
}
variable aws_private_key {
    description = "Content of private key used to authenticate to EC2 instances. Shoud correspod to the key in aws_key_name"
}
variable ssh_username {
    description = "Username for SSH access to EC2 instance."
}

variable instance_type {}
variable instance_count {
    description = "Count of zookeeper nodes to create"
}

variable zookeeper_addresses {
    default = "localhost:2181"
}

variable cluster_name {
    default = "mykafka"
}