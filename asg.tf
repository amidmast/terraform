resource "aws_autoscaling_group" "web" {
  name = "ASG-for-ALB-web-${var.project}"
  desired_capacity   = 2
  max_size           = 2
  min_size           = 2
  force_delete              = true
  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }
  health_check_type = "ELB"
  vpc_zone_identifier = [aws_subnet.private_1.id, aws_subnet.private_2.id]
  target_group_arns = [aws_alb_target_group.nginx.id]
  tag {
      key = "Name"
      value = "WEB-${var.project}"
      propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "scale_up" {
  name                   = "scaleup-${var.project}"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 15
  autoscaling_group_name = aws_autoscaling_group.web.name

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "scaledown-${var.project}"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 15
  autoscaling_group_name = aws_autoscaling_group.web.name

  lifecycle {
    create_before_destroy = true
  }
}
