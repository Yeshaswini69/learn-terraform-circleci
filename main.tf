# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MIT

provider "aws" {
  region = var.region

  default_tags {                                #default tags will be applied to all the resources; key value pair
    tags = {
      hashicorp-learn = "circleci"
    }
  }
}

resource "random_uuid" "randomid" {}            #creation of new resource of type random_uuid name is randomid

resource "aws_s3_bucket" "app" {
  tags = {
    Name          = "App Bucket"
    public_bucket = true
  }

  bucket        = "${var.app}.${var.label}.${random_uuid.randomid.result}"
  force_destroy = true                          #allow bucket to get deleted even if it has objects.
}

resource "aws_s3_bucket_ownership_controls" "app" {
  bucket = aws_s3_bucket.app.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "app" {
  bucket = aws_s3_bucket.app.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "app" {
  depends_on = [
    aws_s3_bucket_ownership_controls.app,
    aws_s3_bucket_public_access_block.app,
  ]

  bucket = aws_s3_bucket.app.id
  acl    = "public-read"
}

resource "aws_s3_bucket_website_configuration" "app" {
  bucket = aws_s3_bucket.app.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_object" "app" {
  key          = "index.html"
  bucket       = aws_s3_bucket.app.id
  content      = file("./assets/index.html")
  content_type = "text/html"
}
