terraform {
  backend "s3" {
    bucket         = "myapp-tfstate-042617239394"
    key            = "bootstrap/state.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "myapp-tflock"
    encrypt        = true
    kms_key_id     = "arn:aws:kms:eu-central-1:042617239394:key/7e5b1883-c3e6-4dc6-8e57-9defcf363d04"
  }
}
