# variables.tf
variable "vpc_id" {}
variable "public_subnets" { type = list(string) }
variable "sg_id" {}
variable "active_color" {
  description = "Which environment receives traffic (blue or green)"
  type        = string
}