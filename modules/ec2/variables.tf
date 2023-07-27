variable "access_key" {
  default = "AKIAYQVNNUZWEHL3VEIH"
}
variable "secret_key" {
  default = "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"
}

variable "instance_name" {
  description = "Name of the instance to be created"
  default     = "awsbuilder"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "ami_id" {
  default = "ami-0f74c08b8b5effa56"
}

variable "number_of_instances" {
  default = 1
}


variable "ami_key_pair_name" {
  default = "ubuntu-ec2-kp"
}