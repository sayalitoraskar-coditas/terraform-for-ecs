variable "cluster_name" {
    default = "new"
}

variable "aws_launch_configuration" {
  default = "auto_scaling_config"
}
variable "instance_type" {
  default = "t2.micro"
}

variable "image_id" {
  default = "ami-0c0dc7872b44903a6"
}

variable "vpc" {
  default = "vpc-40b9b928"
}
variable key_pair {
    default = "es-keypair"
}
