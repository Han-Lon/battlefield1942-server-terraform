variable "allowed-ssh-ip" {
  description = "Optional: The public IP address to allow SSH traffic. Highly recommended to set this as you REALLY want to restrict SSH traffic to your own IP."
  default = ""
  type = string
}