output "sg_id" {
  value = aws_security_group.react_sg.id
}

output "blue_asg_id" {
  value = aws_autoscaling_group.blue_asg.id
}

output "green_asg_id" {
  value = aws_autoscaling_group.green_asg.id
}