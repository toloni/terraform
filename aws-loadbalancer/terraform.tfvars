# load balancer
aws_region = "us-east-1"

vpc_id                 = "vpc-0bf09c857ec29b82b"
private_subnets = ["subnet-07610431fe88c9664", "subnet-0f6304b154427152d"]

tg_port                = 80
tg_protocol            = "HTTP"
lb_healthy_threshold   = 2
lb_unhealthy_threshold = 2
lb_timeout             = 3
lb_interval            = 30
listener_port          = 80
listener_protocol      = "HTTP"