resource "aws_dynamodb_table" "dynamodb-terraform-state-lock" {
  name = "terraform-state-lock-dynamo"
  hash_key = "LockID"
  read_capacity = 20
  write_capacity = 20
 
  attribute {
    name = "LockID"
    type = "S"
  }
}

terraform {
  backend "s3" {
    encrypt = true    
    bucket = "testcodebuildbucket12"
    dynamodb_table = "terraform-state-lock-dynamo"
    key    = "state_files/terraform.tfstate"
    region = "us-east-1"
  }
}
