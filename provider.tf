provider "aws" {
  region = var.aws-region

  default_tags {
    tags = {
      ManagedByTerraform = "True"
      Project = "Battlefield 1942 Server"
    }
  }
}