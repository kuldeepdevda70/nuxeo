resource "aws_lb" "react_alb" {
  name               = "react-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.sg_id]
  subnets            = var.public_subnets
}

resource "aws_lb_target_group" "blue_tg" {
  name     = "react-blue-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path     = "/"
    protocol = "HTTP"
  }
}

resource "aws_lb_target_group" "green_tg" {
  name     = "react-green-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path     = "/"
    protocol = "HTTP"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.react_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "forward"

    target_group_arn = var.active_color == "blue" ? aws_lb_target_group.blue_tg.arn : aws_lb_target_group.green_tg.arn
  }
}