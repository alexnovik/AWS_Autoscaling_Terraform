variable "region" {
        default = "us-east-2"
}

variable "profile" {
    default = "default"
    description = "AWS credentials profile"
}

variable "ami" {
  description = "ami of ec2 instance"
  type        = string
  default     = "ami-08333bccc35d71140"
}

# Launch Template and ASG Variables
variable "instance_type" {
  description = "launch template EC2 instance type"
  type        = string
  default     = "t2.micro"
}