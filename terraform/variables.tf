
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
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDrbLN5w2EMfLODTS+WbbzYTi4b4jvlcLAHVRvNAnDtR8AB+8Bq2bviuoudVdu6UjK+6rk38TGHvirZ/ks/lhIaeahnCus0rrhjwyMkb+v1OzU6U+7z2ttvR2AxKYgsqbAjOiE0P8GAslEB7uRdH5r8I6GzVIpsCkz2IRULfjIhHSUnaFyvSgPOrsBWD5DOaDJ/TbrBFr9L4A9O/nS46Y6lUv0RBnPKY6DYKbHfrNK3EboXrgn3upBd0/jHxHREuylAJz29yn+t+ywVVd7vRNJMo0uJ4XruU5CFj8h9Rcg5HbBlrQS7+higSt8y9DMTkmUGyFlIhvJWw7a4tc5WllbgZkfkfYNyGWWQC+0aXzTctMChK9nw78W3LZlPoR/h/peD3tsvXcs0HconpHZEAUlGmthEa8/w09ZCnEGjwTcAlrXpDCxB/KWDIcGkWf6Q2zxUuPvxriz46Vb9KkRvW3TkK5AAg1Jv/mfYPykTMatJzWCfxzLeVLJ/Tb+UToW0PTIm8fXYsYQOPU6z5f+xDJFcpPIz8FwM/LBjAT14Xilk57Sn4WEgJnqmTlJE7scx7QMrvV6PBeOMZL04qPyvj33kQf1xz0iAXzGncHyrZnZnDGV36InQhRR9CkAM5lNGRz6lOuNnGY4xSRdCSSNhIrhF0a0P8jR8LxvF4P7LBnuU0w=="
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
