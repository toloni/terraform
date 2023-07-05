#  Security Group
resource "aws_security_group" "helloworld_sg" {
  name        = "helloworld_sg"
  description = "Security Group for helloworld app"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Load Balancer
resource "aws_lb" "helloworld_lb" {
  name            = "helloworld-loadbalancer"
  subnets         = var.private_subnets
  security_groups = [aws_security_group.helloworld_sg.id]
  idle_timeout    = 400
}

resource "aws_lb_target_group" "helloworld_tg" {
  name     = "helloworld-lb-tg-${substr(uuid(), 0, 3)}"
  port     = var.tg_port
  protocol = var.tg_protocol
  vpc_id   = var.vpc_id
  target_type = "ip"
  lifecycle {
    ignore_changes        = [name]
    create_before_destroy = true
  }
  health_check {
    healthy_threshold   = var.lb_healthy_threshold
    unhealthy_threshold = var.lb_unhealthy_threshold
    timeout             = var.lb_timeout
    interval            = var.lb_interval
  }
}

resource "aws_lb_listener" "helloworld_lb_listener" {
  load_balancer_arn = aws_lb.helloworld_lb.arn
  port              = var.listener_port
  protocol          = var.listener_protocol
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.helloworld_tg.arn
  }
}