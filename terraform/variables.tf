
variable "customer" {
  description = "The name of the customer"
  type = string
  default = "helios-cassandra-poc"
}

variable "region" {
  description = "AWS region to deploy to"
  type = string
  default = "us-east-1"
}

variable "zone" {
  description = "AWS zone to deploy to"
  type = string
  default = "us-east-1a"
}

variable "automation_ssh_pubkey" {
  description = "Public key for the ubuntu user"
  type = string
  default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBiz5YOIUBqjyIrF1mx9hrXhKHrIi6yW1NvHO2ij2kuA"
}

variable "poc_vpc_cidr" {
  description = "CIDR block for the entire cassandra VPC"
  type = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for Public subnet on the internal network"
  type = string
  default = "10.0.255.0/25"
}

variable "gateway_private_ip" {
  description = "Private IP address to give the Gateway server"
  type = string
  default = "10.0.255.10"
}
