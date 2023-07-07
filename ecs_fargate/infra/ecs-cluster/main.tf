# ecs-cluster/main.tf

# ECS CLUSTER
resource "aws_ecs_cluster" "fargate-cluster" {
  name = "${var.app_name}-fargate-cluster"
}

# SECURITY GROUP
resource "aws_security_group" "ecs_alb_security_group" {
  name        = "${aws_ecs_cluster.fargate-cluster.name}-ALB-SG"
  description = "Security Group for ALB to traffic for ECS Cluster"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    protocol    = "TCP"
    to_port     = 80
    cidr_blocks = [var.internet_cidr_block]
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = [var.internet_cidr_block]
  }
}

# APPLICATION LOAD BALANCER
resource "aws_alb" "ecs_cluter_alb" {
  name            = "${aws_ecs_cluster.fargate-cluster.name}-ALB"
  internal        = false
  security_groups = [aws_security_group.ecs_alb_security_group.id]
  subnets         = var.subnets

  tags = {
    Name = "ALB-${aws_ecs_cluster.fargate-cluster.name}"
  }
}

resource "aws_alb_target_group" "ecs_default_target_group" {
  name     = "${aws_ecs_cluster.fargate-cluster.name}-TG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  tags = {
    Name = "TG-${aws_ecs_cluster.fargate-cluster.name}"
  }
}

resource "aws_alb_listener" "ecs_alb_http_listener" {
  load_balancer_arn = aws_alb.ecs_cluter_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.ecs_default_target_group.arn
  }

  depends_on = [aws_alb_target_group.ecs_default_target_group]
}

# IAM ROLE
data "local_file" "iam_roles" {
  filename = "${path.module}/iam-role.json"
}
locals {
  iam_roles = jsondecode(data.local_file.iam_roles.content)
}
resource "aws_iam_role" "ecs_cluster_role" {
  name = "IAM-Role-${aws_ecs_cluster.fargate-cluster.name}"
  assume_role_policy = jsonencode(local.iam_roles)
}

data "local_file" "iam_roles-policy" {
  filename = "${path.module}/iam-role-policy.json"
}

locals {
  iam_roles_policy = jsondecode(data.local_file.iam_roles-policy.content)
}
resource "aws_iam_role_policy" "ecs_cluster_policy" {
  name = "${aws_ecs_cluster.fargate-cluster.name}-IAM-Policy"
  policy = jsonencode(local.iam_roles_policy)
  role   = aws_iam_role.ecs_cluster_role.id
}

