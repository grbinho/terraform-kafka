resource "aws_vpc" "kafka_vpc" {
    cidr_block = "${var.vpc_cidr}"
    enable_dns_support = true
    enable_dns_hostnames = true

    tags {
        Name = "kafka-vpc"
    }
}

resource "aws_subnet" "kafka_public" {
    vpc_id = "${aws_vpc.kafka_vpc.id}"
    cidr_block = "${var.public_subnet_cidr}"
    map_public_ip_on_launch = true
    availability_zone = "eu-west-1a"

    tags {
        Name = "Kafka_public 1a"
    }
}

resource "aws_internet_gateway" "kafka_gateway" {
    vpc_id = "${aws_vpc.kafka_vpc.id}"
    tags {
        Name = "kafka-vpc"
    }
}

resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.kafka_vpc.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.kafka_gateway.id}"
}

resource "aws_eip" "kafka_eip" {
  vpc      = true
  depends_on = ["aws_internet_gateway.kafka_gateway"]
   tags {
        Name = "kafka-vpc"
    }
}

resource "aws_nat_gateway" "kafka_nat" {
    allocation_id = "${aws_eip.kafka_eip.id}"
    subnet_id = "${aws_subnet.kafka_public.id}"
    depends_on = ["aws_internet_gateway.kafka_gateway"]
     tags {
        Name = "kafka-vpc"
    }
}

resource "aws_security_group" "kafka_sg" {
    vpc_id = "${aws_vpc.kafka_vpc.id}"
    name = "kafka_security_group"
    description = "Allow traffic to pass from the internet"

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 2181
        to_port = 2181
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }   
    ingress {
        from_port = 2888
        to_port = 2888
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 3888
        to_port = 3888
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }     
        ingress {
        from_port = 9092
        to_port = 9092
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }     

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags {
        Name = "kafka-vpc"
    }
}

