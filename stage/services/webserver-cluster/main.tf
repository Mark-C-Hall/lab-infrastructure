provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket         = "lab.markchall.com-terraform-state"
    key            = "lab/stage/services/webserver-cluster/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "lab-terraform-locks"
    encrypt        = true
  }
}

data "terraform_remote_state" "mysql" {
  backend = "s3"

  config = {
    bucket = "lab.markchall.com-terraform-state"
    key    = "lab/stage/data-stores/mysql/terraform.tfstate"
    region = "us-east-1"
  }
}

resource "aws_launch_configuration" "webserver-cluster" {
  image_id        = "ami-04b70fa74e45c3917" // Ubuntu Server 24.04 LTS
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.instance.id]

  user_data = templatefile("user-data.sh", {
    db_address  = data.terraform_remote_state.mysql.outputs.address
    db_port     = data.terraform_remote_state.mysql.outputs.port
    server_port = var.server_port
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "webserver-cluster" {
  launch_configuration = aws_launch_configuration.webserver-cluster.name
  vpc_zone_identifier  = data.aws_subnets.default.ids

  target_group_arns = [aws_lb_target_group.webserver-cluster.arn]
  health_check_type = "ELB"


  min_size = 1
  max_size = 3

  tag {
    key                 = "Name"
    value               = "webserver-cluster"
    propagate_at_launch = true
  }
}



resource "aws_lb" "webserver-cluster" {
  name               = "webserver-cluster"
  load_balancer_type = "application"
  subnets            = data.aws_subnets.default.ids
  security_groups    = [aws_security_group.alb.id]
}

resource "aws_lb_listener" "webserver-cluster" {
  load_balancer_arn = aws_lb.webserver-cluster.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 400
    }
  }
}

resource "aws_lb_target_group" "webserver-cluster" {
  name     = "webserver-cluster"
  port     = var.server_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/"
    port                = var.server_port
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = 5
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener_rule" "webserver-cluster" {
  listener_arn = aws_lb_listener.webserver-cluster.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webserver-cluster.arn
  }

  condition {
    path_pattern {
      values = ["/"]
    }
  }
}

resource "aws_security_group" "instance" {
  name = "webserver-cluster"

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "alb" {
  name = "webserver-cluster-alb"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "server_port" {
  description = "Server Port"
  type        = number
  default     = 8080
}

output "alb_dns_name" {
  value       = aws_lb.webserver-cluster.dns_name
  description = "value of the ALB DNS Name"
}
