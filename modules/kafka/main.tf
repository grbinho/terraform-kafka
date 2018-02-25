resource "aws_instance" "kafka" {
  count = "${var.instance_count}"
  ami           = "${var.ami}"
  instance_type = "${var.instance_type}"
  key_name = "${var.aws_key_name}"  
  vpc_security_group_ids = ["${var.security_group_id}"]
  subnet_id = "${var.subnet_id}" 
  tags = {
    Name="${format("%s%d","kafka",count.index + 1)}"
  }

  ebs_block_device {
    volume_size = 200
    volume_type = "gp2"  
    device_name = "/dev/xvdb"
    delete_on_termination = true
  }

  connection {
    type     = "ssh"
    user = "${var.ssh_username}"
    private_key = "${var.aws_private_key}"
  }

  provisioner "file" {
    source      = "${path.module}/server.properties"
    destination = "/tmp/server.properties"
  }

  provisioner "file" {
    source      = "${path.module}/init.sh"
    destination = "/tmp/init.sh"     
  } 
  
  provisioner "remote-exec" {
    inline = [
      "export KAFKA_VERSION=${var.kafka_version}",
      "chmod +x /tmp/init.sh",
      "/tmp/init.sh ${count.index + 1} ${var.instance_count} ${format("%s/%s", var.zookeeper_addresses, var.cluster_name)} > /tmp/init.log"
    ]  
  }
}

# resource "aws_ebs_volume" "data_volume" {
#   count = "${var.instance_count}"
#   size = 200
#   type = "gp2"    
#   availability_zone = "${element(aws_instance.kafka.*.availability_zone, count.index)}" 
#   skip_destroy = true 
# }

# resource "aws_volume_attachment" "data_volume_attachment" {
#   count = "${var.instance_count}"
#   instance_id = "${element(aws_instance.kafka.*.id, count.index)}"
#   volume_id = "${element(aws_ebs_volume.data_volume.*.id, count.index)}"
#   device_name = "/dev/xvdb"

#   provisioner "remote-exec" {
#     inline = [
#       "export KAFKA_VERSION=${var.kafka_version}",
#       "chmod +x /tmp/init.sh",
#       "/tmp/init.sh ${count.index + 1} ${var.instance_count} ${format("%s/%s", var.zookeeper_addresses, var.cluster_name)} > /tmp/init.log"
#     ]

#     connection {
#       host = "${element(aws_instance.kafka.*.public_dns, count.index)}"
#       type = "ssh"
#       user = "${var.ssh_username}"
#       private_key = "${var.aws_private_key}"
#     }
#   }
#   skip_destroy = true
# }

output "node_address" {
  value = "${format("%s:9092",join(":9092,", aws_instance.kafka.*.public_dns))}"
}
