provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "website_bucket" {
  bucket = "my-generic-website-bucket-${random_id.bucket_id.hex}"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  tags = {
    Name = "Website Bucket"
  }
}

resource "random_id" "bucket_id" {
  byte_length = 4
}
