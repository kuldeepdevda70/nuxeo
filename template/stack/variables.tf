variable "aws_region" {
  description = "AWS region to deploy"
  type        = string
  default     = "eu-central-1"
}

variable "vpc_id" {}
variable "public_subnets" {
  type = list(string)
}
variable "ami" {}
variable "instance_type" {}
variable "key_name" {}
variable "ansible_repo" {}

variable "blue_version" {}
variable "green_version" {}
variable "active_color" {
  description = "Which environment receives traffic (blue or green)"
  type        = string
}