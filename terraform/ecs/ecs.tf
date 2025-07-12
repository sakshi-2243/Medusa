variable "vpc_id" {}
variable "subnets" { type = list(string) }
variable "ecr_repo_url" { type = string }

resource "aws_ecs_cluster" "main" {
  name = "medusa-cluster"
}

resource "aws_iam_role" "exec_role" {
  name = "ecsTaskExecutionRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "ecs-tasks.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach" {
  role = aws_iam_role.exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_security_group" "sg" {
  name = "medusa-sg"
  description = "Allow traffic on 9000"
  vpc_id = var.vpc_id

  ingress {
    from_port = 9000
    to_port = 9000
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 egress {
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

}

resource "aws_ecs_task_definition" "task" {
  family                   = "medusa-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.exec_role.arn

  container_definitions = jsonencode([
    {
      name      = "medusa",
      image     = "${var.ecr_repo_url}:latest",
      essential = true,
      portMappings = [
        {
          containerPort = 9000,
          hostPort      = 9000
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "service" {
  name            = "medusa-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnets
    assign_public_ip = true
    security_groups  = [aws_security_group.sg.id]
  }

  depends_on = [aws_ecs_cluster.main] # optional, adds safety for ordering
}


