resource "aws_instance" "zookeeper" {
  count = "${var.instance_count}"
  ami           = "${var.ami}"
  instance_type = "${var.instance_type}"
  key_name = "${var.aws_key_name}"
  private_ip = "${format("%s%d", var.ip_prefix, count.index + 1)}"
  vpc_security_group_ids = ["${var.security_group_id}"]
  subnet_id = "${var.subnet_id}"
  tags = {
    Name="${format("%s%d","zookeeper",count.index + 1)}"
  }

  connection {
    type     = "ssh"
    user = "${var.ssh_username}"
    private_key = "${var.aws_private_key}"
  }

  provisioner "file" {
    source      = "${path.module}/init.sh"
    destination = "/tmp/init.sh"     
  }

  provisioner "remote-exec" {
    inline = [
      "export ZOOKEEPER_VERSION=${var.zookeeper_version}",
      "chmod +x /tmp/init.sh",
      "/tmp/init.sh ${count.index + 1} ${var.ip_prefix} ${var.instance_count} > /tmp/init.log"
    ]
  }
}

output "node_address" {
  value = "${format("%s:2181",join(":2181,", aws_instance.zookeeper.*.private_ip))}"
}