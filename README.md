Demo project using AWS EC2 autoscaling and Terraform

Expected Deliverables:

- Launch an EC2 instance with Autoscaling using Terraform
- Install stress test application 
- Monitor VM scaling

Deployment plan

 Deploy AutoScaling group using templates with AWS Linux 2023
 Create Autoscaling policy with metrics for scale UP and Down. Thresholds are 10% CPU for scaledown and 60% for scaleup
 Create network services (IG, Subnets, RT, RTa, VPC, SG)
 Security Group open ports 22
 Connect to instance manually and deploy Stress Test software

 NOTE: Security credentials configured with aws-cli (aws configure)
 and saved in ~/.aws/credentials upon running tf script system asks 
 for profile and it is "default". For unattended run use "terraform apply -var profile=default -auto-approve"
