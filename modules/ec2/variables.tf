variable "sg_name" {}
variable "vpc_id" {}
variable "public_subnets" {
  type = list(string)
}
variable "ami" {}
variable "instance_type" {}
variable "key_name" {}
variable "ansible_repo" {}

# Blue-Green specific
variable "blue_version" {}
variable "green_version" {}
variable "blue_target_group_arn" {}
variable "green_target_group_arn" {}