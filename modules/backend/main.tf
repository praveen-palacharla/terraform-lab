terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-east-1"
}

resource "aws_s3_bucket" "t_s3_bucket" {
  bucket = "mystate-file-s3-bucket"
  
  lifecycle {
	prevent_destroy = true
  }
  
  versioning {
	enabled = true
  }
  
  server_side_encryption_configuration {
	rule {
		apply_server_side_encryption_by_default {
			sse_algorithm = "AES256"
		}
        }
  }
}

resource "aws_dynamodb_table" "t_dynamo_locks" {
	name = "mystatefile-dynamo-locks"
	billing_mode = "PAY_PER_REQUEST"
	hash_key = "LockID"
	
	attribute {
		name = "LockID"
		type = "S"
	}
}

