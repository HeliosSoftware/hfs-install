
variable "zone_1" {
  description = "First AWS zone to deploy to"
  type        = string
  default     = "us-east-1a"
}

variable "zone_2" {
  description = "Second AWS zone to deploy to"
  type        = string
  default     = "us-east-1d"
}

variable "local_ssh_public_key" {
  description = "Public key to access the bastion server.  Either ~/.ssh/id_rsa.pub or ~/.ssh/id_ed25519.pub"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "local_ssh_private_key" {
  description = "Public key to access the bastion server.  Either ~/.ssh/id_rsa or ~/.ssh/id_ed25519"
  type        = string
  default     = "~/.ssh/id_ed25519"
}

variable "public_subnet_cidr" {
  description = "CIDR block for Public subnet on the internal network"
  type        = string
  default     = "10.0.255.0/25"
}

# VPC CIDR
variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR for VPC"
}

variable "public_subnet_1_cidr" {
  type        = string
  default     = "10.0.1.0/24"
  description = "CIDR for Public Subnet 1"
}

variable "public_subnet_2_cidr" {
  type        = string
  default     = "10.0.2.0/24"
  description = "CIDR for Public Subnet 2"
}

variable "private_subnet_1_cidr" {
  type        = string
  default     = "10.0.3.0/24"
  description = "CIDR for Private Subnet 1"
}

variable "private_subnet_2_cidr" {
  type        = string
  default     = "10.0.4.0/24"
  description = "CIDR for Private Subnet 2"
}

# Instance type
variable "worker_instance_type" {
  default     = "t3.xlarge"
  type        = string
  description = "Worker node instance type"
}

variable "AWS_DEFAULT_REGION" {
  type        = string
  description = "AWS region to deploy to.  This is a variable for the required TF_VAR_AWS_DEFAULT_REGION environment variable."
}

variable "CASSANDRA_CLUSTER_NAME" {
  type        = string
  description = "This is a variable for the required TF_VAR_CASSANDRA_CLUSTER_NAME environment variable."
}

variable "ENVIRONMENT" {
  type        = string
  description = "This is a variable for the required TF_VAR_ENVIRONMENT environment variable. e.g. Production, Testing, Development"
}

variable "route54_hostname_enabled" {
  description = "Set to true to enable a Route 53 hostname - defaults to r4.heliossoftware.com"
  type        = bool
  default     = false
}

variable "zone_name" {
  description = "The Route 53 zone domain name to deploy to"
  type        = string
  default     = "heliossoftware.com"
}

variable "host_name" {
  description = "The host name within the above zone."
  type        = string
  default     = "r4"
}
