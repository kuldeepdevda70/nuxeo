module "alb" {
  source         = "../../modules/load-balancer"
  vpc_id         = var.vpc_id
  public_subnets = var.public_subnets
  sg_id          = module.ec2.sg_id
  active_color   = var.active_color
}

module "ec2" {
  source         = "../../modules/ec2"
  sg_name        = "react-sg"
  vpc_id         = var.vpc_id
  ami            = var.ami
  instance_type  = var.instance_type
  key_name       = var.key_name
  ansible_repo   = var.ansible_repo
  public_subnets = var.public_subnets

  blue_version  = var.blue_version
  green_version = var.green_version

  blue_target_group_arn  = module.alb.blue_target_group_arn
  green_target_group_arn = module.alb.green_target_group_arn
}

output "alb_dns" {
  value = module.alb.alb_dns
}