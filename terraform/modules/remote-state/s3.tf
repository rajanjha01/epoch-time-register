##s3 bucket to store tfstate file

resource "aws_s3_bucket" "terraform_state_bucket" {
  bucket = local.bucket_name
  acl    = "private"
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
  lifecycle {
    prevent_destroy = true
  }
}
resource "aws_s3_bucket_public_access_block" "block" {
  bucket = aws_s3_bucket.terraform_state_bucket.id 

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
########################################################
