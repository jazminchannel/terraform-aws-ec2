terraform {
  backend "s3" {
    bucket         = "jaz-tfstate-bucket"
    key            = "envs/dev/terraform.tfstate"
    region         = "us-east-1"
#	    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
