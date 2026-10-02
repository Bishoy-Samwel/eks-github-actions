terraform {
  backend "s3" {
    bucket         = "myapp-tfstate-042617239394"
    key            = "infra/dev/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "myapp-tflock"
    encrypt        = true
  }
}
