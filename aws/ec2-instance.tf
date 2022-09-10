# Dynamically grab the most recent Ubuntu 20.04 AMI
data "aws_ami" "ubuntu-ami" {
  owners      = ["099720109477"]
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "random_password" "initial-user-password" {
  length = 8
}

module "bf1942-server-iam-role" {
  source = "registry.terraform.io/terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "5.3.1"

  role_name = "bf1942-server-iam-role"

  trusted_role_services = ["ec2.amazonaws.com"]
  create_role = true
  create_instance_profile = true
  role_requires_mfa = false

  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
  number_of_custom_role_policy_arns = 1
}

resource "aws_spot_instance_request" "bf1942-spot-server" {
  count = var.use-spot-instance == true ? 1 : 0
  ami = data.aws_ami.ubuntu-ami.image_id
  instance_type = var.ec2-instance-type

  wait_for_fulfillment = true

  subnet_id = var.use-default-vpc == true ? aws_default_subnet.default-subnet[0].id : module.bf1942-vpc.public_subnets[0]
  iam_instance_profile = module.bf1942-server-iam-role.iam_instance_profile_id

  root_block_device {
    volume_size = var.ec2-volume-size
  }

  user_data = templatefile("../server-bootstrap.sh", {
    PASSWD = random_password.initial-user-password.result
  })
}