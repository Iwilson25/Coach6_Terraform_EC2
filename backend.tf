terraform {
  backend "s3" {
    bucket = "sctp-ce11-tfstate"
    key = "terraform.tfstate.backup"
    region = "us-east-1"
    
  }
}