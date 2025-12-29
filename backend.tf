terraform {
  backend "s3" {
    #Replace this with your bucket name!
    bucket = "kotak811-terraform-state-dr"
    key    = "kotak811/env/uat-dr/acqui-mongodb-nodes/terraform.tfstate"
    region = "ap-south-2"
    #Replace this with your DynamoDB table name!
    dynamodb_table = "tf-up-and-run-locks-dr"
    encrypt        = true
  }
}