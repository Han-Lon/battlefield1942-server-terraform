variable "allowed-ssh-ip" {
  description = "Optional: The public IP address to allow SSH traffic. Highly recommended to set this as you REALLY want to restrict SSH traffic to your own IP."
  default = ""
  type = string
}

variable "use-spot-instance" {
  description = "Whether to use on-demand or spot pricing with the virtual machine. Spot pricing is cheaper, but your instance can be terminated at any time by Azure due to utilization increases."
  type = bool
  default = false
}