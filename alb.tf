resource "aws_alb" "web" {
  name = "web-${var.project}"
  subnets = [aws_subnet.public_1.id, aws_subnet.public_2.id]
  security_groups = [aws_security_group.sg.id]
##  depends_on = [aws_alb_target_group.nginx]
}

resource "aws_alb_listener" "web" {
  load_balancer_arn = aws_alb.web.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.nginx.id
    type             = "forward"
  }
  depends_on = [aws_alb.web]
}

resource "aws_alb_target_group" "nginx" {
  name       = "nginx"
  port       = 80
  protocol   = "HTTP"
  vpc_id     = aws_vpc.main.id
##  depends_on = [aws_autoscaling_group.web]

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 86400
  }

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 20
    interval            = 30
    matcher             = "200,301,302"
  }
}
