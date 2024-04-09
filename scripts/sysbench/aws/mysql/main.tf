variable "name" {
  default = "sysbench"
}

variable "ext_ip" {
  type    = string
  default = "0.0.0.0/0"
}

variable "access_key" {}
variable "secret_key" {}

variable "region" {}
variable "zone" {}
variable "slave_zone" {}

variable "db_instance_type" {}
variable "db_user" {}
variable "db_pwd" {}
variable "db_disk_size" {}
variable "db_disk_type" {}

variable "cpu" {}
variable "memory" {}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
 access_key = var.access_key
 secret_key = var.secret_key
 region = var.region
}

resource "aws_vpc" "vpc" {
  cidr_block       = "192.168.0.0/24"
  tags = {
    Name = var.name
  }
}

resource "aws_subnet" "subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "192.168.0.0/26"
  availability_zone = var.zone
  tags = {
    Name = var.name
  }
  depends_on        = [aws_vpc.vpc]
}

resource "aws_subnet" "subnet_slave" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "192.168.0.128/26"
  availability_zone = var.slave_zone
  tags = {
    Name = "${var.name}_slave_zone"
  }
  depends_on        = [aws_vpc.vpc]
}

resource "aws_security_group" "security_group" {
  name    = var.name
  vpc_id  = aws_vpc.vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true  # 允许安全组内的所有流量
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ext_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  depends_on = [aws_vpc.vpc]
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "db_subnet_group"
  subnet_ids = [aws_subnet.subnet.id, aws_subnet.subnet_slave.id]

  tags = {
    Name = var.name
  }
}

resource "aws_db_instance" "rds" {

  allocated_storage       = var.db_disk_size
  storage_type            = var.db_disk_type
  db_name                 = "sbtest"
  engine                  = "mysql"
  engine_version          = "8.0.36"
  instance_class          = var.db_instance_type
  multi_az                = true
  username                = var.db_user
  password                = var.db_pwd
  db_subnet_group_name    = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.security_group.id]
  skip_final_snapshot     = true
  
  tags = {
    Name = var.name
  }
  depends_on = [aws_security_group.security_group]
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route" "route" {
  route_table_id          = aws_vpc.vpc.main_route_table_id
  destination_cidr_block  = "0.0.0.0/0"
  gateway_id              = aws_internet_gateway.gateway.id
}

resource "aws_ecs_cluster" "ecs" {
  name = var.name
}

resource "aws_ecs_task_definition" "task" {
  family = "sysbench"
  cpu                      = var.cpu
  memory                   = var.memory
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  container_definitions = jsonencode([
    {
      name      = "sysbench"
      image     = "registry.cn-hangzhou.aliyuncs.com/ninedata_public/sysbench:latest"
      memory    = var.memory
      cpu       = var.cpu
      essential = true

      "command": ["/bin/sh", "-c", "/usr/sbin/sshd && sleep infinity"]

      portMappings = [
        {
          containerPort = 22
          hostPort      = 22
        }
      ]
    }
  ])

  depends_on = [aws_ecs_cluster.ecs, aws_db_instance.rds, aws_route.route]
}

resource "aws_ecs_service" "service" {
  name            = "ssh"
  cluster         = aws_ecs_cluster.ecs.id
  task_definition = aws_ecs_task_definition.task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  enable_ecs_managed_tags = true
  wait_for_steady_state   = true

  network_configuration {
    subnets          = [aws_subnet.subnet.id]
    security_groups  = [aws_security_group.security_group.id]
    assign_public_ip = true
  }

  depends_on = [aws_ecs_task_definition.task, aws_route.route]
}

data "aws_network_interface" "interface_tags" {
  filter {
    name   = "tag:aws:ecs:serviceName"
    values = ["ssh"]
  }

  depends_on = [aws_ecs_service.service]
}

output "url" {
  value = aws_db_instance.rds.address
}

output "host" {
  value = data.aws_network_interface.interface_tags.association[0].public_ip
}

output "user" {
  value = "root"
}

output "container" {
  value = true
}

output "db_port" {
  value = aws_db_instance.rds.port
}

output "db_user" {
  value = var.db_user
}

output "db_pwd" {
  value = var.db_pwd
}