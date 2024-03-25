terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

########################################################

# Expected Deliverables:

# - Launch an EC2 instance with Autoscaling using Terraform
# - Install stress test application 
# - Monitor VM scaling

# Deployment plan

# Deploy AutoScaling group using templates with AWS Linux 2023
# Create Autoscaling policy with metrics for scale UP and Down. Thresholds are 10% CPU for scaledown and 60% for scaleup
# Create network services (IG, Subnets, RT, RTa, VPC, SG)
# Security Group open ports 22
# Connect to instance manually and deploy Stress Test software

# NOTE: Security credentials configured with aws-cli (aws configure)
# and saved in ~/.aws/credentials upon running tf script system asks 
# for profile and it is "default". For unattended run use "terraform apply -var profile=default -auto-approve"
# 

########################################################
#######  1. EC2 Deployment
########################################################

provider "aws" {
   profile    = "${var.profile}"
   region     = "${var.region}"
}

#AutoScalingGroup 
/*if the number of requests to the target groups increases, the Auto Scaling group will automatically scale the number 
of instances in the group up to handle the increased load. If the number of requests to the target groups decreases, 
the Auto Scaling group will automatically scale the number of instances in the group down to save costs.*/
resource "aws_autoscaling_group" "auto_scaling_group" {
  desired_capacity = 1
  max_size = 2
  min_size = 1
  vpc_zone_identifier =  ["${aws_subnet.devops-public1.id}"] 

  launch_template {
    id = aws_launch_template.launch_template.id
    version = aws_launch_template.launch_template.latest_version
  }
}

#AutoScalingGroup ScaleDown Policy and Metrics
resource "aws_autoscaling_policy" "capstone_scale_down" {
  name                   = "capstone_scale_down"
  autoscaling_group_name = "auto_scaling_group"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 60
  depends_on = [
    aws_autoscaling_group.auto_scaling_group
  ]
}

resource "aws_cloudwatch_metric_alarm" "capstone_scale_down" {
  alarm_description   = "Monitors CPU utilization for Capstone ASG for 10% low"
  alarm_actions       = [aws_autoscaling_policy.capstone_scale_down.arn]
  alarm_name          = "capstone_scale_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  threshold           = "10"
  evaluation_periods  = "1"
  period              = "60"
  statistic           = "Average"

  dimensions = {
    AutoScalingGroupName = "auto_scaling_group"
  }
}

#AutoScalingGroup ScaleUp Policy and Metrics
resource "aws_autoscaling_policy" "capstone_scale_up" {
  name                   = "capstone_scale_up"
  autoscaling_group_name = "auto_scaling_group"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 60
  depends_on = [
    aws_autoscaling_group.auto_scaling_group
  ]
}

resource "aws_cloudwatch_metric_alarm" "capstone_scale_up" {
  alarm_description   = "Monitors CPU utilization for Capstone ASG for 60% peaks"
  alarm_actions       = [aws_autoscaling_policy.capstone_scale_up.arn]
  alarm_name          = "capstone_scale_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  threshold           = "60"
  evaluation_periods  = "1"
  period              = "60"
  statistic           = "Average"

  dimensions = {
    AutoScalingGroupName = "auto_scaling_group"
  }
}


# Launch Template and Resources
resource "aws_launch_template" "launch_template" {
  name          = "capstone-launch-template"
  image_id      = var.ami
  instance_type = var.instance_type
  key_name = "capstone"
  network_interfaces {
    device_index    = 0
    associate_public_ip_address = true
    security_groups = ["${aws_security_group.allow_ports.id}"]
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "capstone-asg-ec2"
    }
  }
}

resource "aws_eip" "elastic_ip" {
  tags = {
    Name = "capstone3-elastic-ip"
  }
}



########################################################
#######  3. Security Group open ports 22, 8080
########################################################

resource "aws_security_group" "allow_ports" {
  name        = "allow_ssh"
  description = "Allow 22 inbound traffic"
  vpc_id      = aws_vpc.vpc.id

 ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}




