# Use the default VPC in an account if the use-default-vpc variable is set to true
data "aws_vpc" "default-vpc" {
  count = var.use-default-vpc == true ? 1 : 0
  default = true
}

# Set a default subnet from the default VPC if the use-default-vpc variable is set to true
resource "aws_default_subnet" "default-subnet" {
  count = var.use-default-vpc == true ? 1 : 0
  availability_zone = "${var.aws-region}a"
}

# Create a new VPC specifically for Battlefield 1942 if the use-default-vpc variable is false
module "bf1942-vpc" {
  count = var.use-default-vpc == false ? 1 : 0
  source = "registry.terraform.io/terraform-aws-modules/vpc/aws"
  version = "3.14.3"

  name = "bf1942-vpc"
  cidr = "192.168.250.0/28"

  azs = ["${var.aws-region}a"]
  public_subnets = ["192.168.250.0/28"]
}

# Create a security group for the Battlefield1942 EC2 instance. This is like a firewall that can be tweaked to allow only specific IP addresses to access your server
resource "aws_security_group" "bf1942-server-security-group" {
  name = "bf1942-server-sg"
  description = "Allow traffic to the Battlefield 1942 server."
  vpc_id = var.use-default-vpc == true ? data.aws_vpc.default-vpc[0].id : module.bf1942-vpc.vpc_id

  # Allow bf1942-related inbound connections from any IP address
  ingress {
    from_port = 14567
    protocol  = "UDP"
    to_port   = 14567
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow outbound traffic - wouldn't recommend changing this, weird stuff can happen if the outbound access is restricted
  egress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}