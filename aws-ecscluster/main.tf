# Crie um cluster ECS
resource "aws_ecs_cluster" "helloworld_cluster" {
  name = "helloworld-ecs-cluster" # Substitua pelo nome desejado para o cluster
}

# Crie IAM ROLE
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs-task-execution-role"

  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "",
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "ecs-tasks.amazonaws.com"
          },
          "Action" : "sts:AssumeRole"
        }
      ]
  })
}

resource "aws_iam_policy" "ecs_task_execution_policy" {
  name        = "ecs-task-execution-policy"
  description = "Allows ECS tasks to call AWS services on your behalf."

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : "logs:CreateLogStream",
          "Resource" : "arn:aws:logs:*:*:*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "logs:PutLogEvents",
            "logs:CreateLogGroup"
          ],
          "Resource" : "arn:aws:logs:*:*:*"
        }
      ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_task_execution_policy.arn
}

# Crie uma definição de tarefa ECS
# resource "aws_ecs_task_definition" "helloworld_task_definition" {
#   family                   = "helloworld-task-definition" # Substitua pelo nome desejado para a definição da tarefa
#   cpu                      = "256"                        # Define a quantidade de CPU para a tarefa
#   memory                   = "512"                        # Define a quantidade de memória para a tarefa
#   requires_compatibilities = ["FARGATE"]
#   network_mode             = "awsvpc"
#   execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

#   container_definitions = jsonencode([
#     {
#       "name" : "helloworld-container",
#       "image" : "nginx:latest",
#       "cpu" : 256,
#       "memory" : 512,
#       "portMappings" : [
#         {
#           "containerPort" : 80,
#           "hostPort" : 80,
#           "protocol" : "tcp"
#         }
#       ],
#       "essential" : true,
#       "logConfiguration" : {
#         "logDriver" : "awslogs",
#         "options" : {
#           "awslogs-group" : "/ecs/helloworld-container",
#           "awslogs-region" : "us-east-1",
#           "awslogs-stream-prefix" : "ecs"
#         }
#       }
#     }
#   ])

# }

# # Crie um serviço ECS para executar a tarefa
# resource "aws_ecs_service" "helloworld_service" {
#   name            = "helloworld-service" # Substitua pelo nome desejado para o serviço
#   cluster         = aws_ecs_cluster.helloworld_cluster.id
#   task_definition = aws_ecs_task_definition.helloworld_task_definition.arn
#   desired_count   = 1

#   network_configuration {
#     subnets          = var.private_subnets # Substitua pelas subnets desejadas
#     security_groups  = var.security_groups # Substitua pelo(s) security group(s) desejado(s)
#     assign_public_ip = false
#   }

#   # Configuração do balanceador de carga
#   load_balancer {
#     target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:617519438190:targetgroup/helloworld-lb-tg-d6d/73543c4485489536"
#     container_name   = "helloworld-container"
#     container_port   = 80
#   }
# }
