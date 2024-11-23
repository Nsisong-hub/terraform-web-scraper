variable "region" {
  default = "us-east-1"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  default = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  default = "10.0.2.0/24"
}

variable "db_instance_class" {
  default = "db.t3.micro"
}

variable "db_engine" {
  default = "mysql"
}

variable "db_name" {
  default = "scraperdb"
}

variable "db_username" {
  default = "admin"
}

variable "db_password" {
  default = "SecurePassword123!"
}
variable "key_pair_name" {
  default = "web-keypair" # Replace with your actual key pair name
}


