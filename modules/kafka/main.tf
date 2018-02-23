

resource "aws_instance" "kafka" {
  count = "${var.instance_count}"
  ami           = "${var.ami}"
  instance_type = "${var.instance_type}"
  key_name = "${var.aws_key_name}"  
  vpc_security_group_ids = ["${var.security_group_id}"]
  subnet_id = "${var.subnet_id}"

  ebs_block_device {
    device_name ="dev/sdh"
    volume_size = 200    
  }  

  provisioner "file" {
    source      = "${path.module}/init.sh"
    destination = "/tmp/init.sh"
  
    connection {
      type     = "ssh"
      user = "${var.ssh_username}"
      private_key = "${var.aws_private_key}"
    }
  }

  provisioner "file" {
    source      = "${path.module}/server.properties"
    destination = "/tmp/server.properties"
  
    connection {
      type     = "ssh"
      user = "${var.ssh_username}"
      private_key = "${var.aws_private_key}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "export KAFKA_VERSION=${var.kafka_version}",
      "chmod +x /tmp/init.sh",
      "/tmp/init.sh ${count.index + 1} ${var.instance_count} ${format("%s/%s", var.zookeeper_addresses, var.cluster_name)} > /tmp/init.log"
    ]

    connection {
      type     = "ssh"
      user = "${var.ssh_username}"
      private_key = "${var.aws_private_key}"
    }
  }
}
