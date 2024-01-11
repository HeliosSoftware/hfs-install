
variable "customer" {
  description = "The name of the customer"
  type        = string
  default     = "helios-cassandra-poc"
}

variable "zone_1" {
  description = "First AWS zone to deploy to"
  type        = string
  default     = "us-east-1a"
}

variable "zone_2" {
  description = "Second AWS zone to deploy to"
  type        = string
  default     = "us-east-1c"
}

variable "local_ssh_public_key" {
  description = "Public key to access the bastion server.  Either ~/.ssh/id_rsa.pub or ~/.ssh/id_ed25519.pub"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
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