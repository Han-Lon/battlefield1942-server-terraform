variable "use-default-vpc" {
  description = "Whether to use the default VPC in an AWS account or create a new one."
  type = bool
  default = true
}

variable "aws-region" {
  description = "The AWS region to deploy into. Pick a region closest to your geographic location -> https://aws.amazon.com/about-aws/global-infrastructure/regions_az/"
  type = string
  default = "us-west-2"
}

variable "use-spot-instance" {
  description = "Whether to use on-demand or spot pricing with the EC2. Spot pricing is cheaper, but your instance can be terminated at any time by AWS due to utilization increases."
  type = bool
  default = false
}

variable "ec2-instance-type" {
  description = "Determines the CPU and memory available to your server. Boost this if you run into memory or CPU utilization errors -> https://aws.amazon.com/ec2/instance-types/"
  type = string
  default = "t3a.small"
}

variable "ec2-volume-size" {
  description = "Determine the size of the storage volume attached to the web server, in GB. Boost this if you run into out-of-disk or low storage/high volume utilization errors."
  type = number
  default = 20
}