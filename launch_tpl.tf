data "aws_ami" "image" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

data "template_file" "user_data" {
  template = <<EOF
  #!/bin/bash
  amazon-linux-extras install nginx1.12 -y
  amazon-linux-extras install php7.2 -y
  yum install php-fpm -y
  echo "<?php phpinfo(); ?>" > /usr/share/nginx/html/index.php
  for i in php-fpm nginx; do service $i start; done
EOF
}
###################################
resource "aws_launch_template" "web" {
  name                        = "WEB-${var.project}"
  image_id                    = data.aws_ami.image.id
  instance_type               = var.ec2_type
  vpc_security_group_ids      = [aws_security_group.sg.id]
  key_name                    = var.key
  user_data                   = base64encode(data.template_file.user_data.rendered)
  lifecycle {
    create_before_destroy     = true
  }
  depends_on = [aws_vpc.main]
}
