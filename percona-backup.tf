resource "aws_s3_bucket" "backup_bucket" {
  bucket        = var.bucket_name
  acl           = "private"
  force_destroy = false # Set to true to allow bucket deletion with objects inside

  tags = {
    Environment = var.environment
    Project     = "MongoDB-Backup"
  }
}

resource "aws_iam_policy" "backup_bucket_full_access" {
  name        = "${var.bucket_name}_full_access_policy"
  description = "Full access to S3 bucket ${var.bucket_name}"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        Resource = [
          aws_s3_bucket.backup_bucket.arn,
          "${aws_s3_bucket.backup_bucket.arn}/*"
        ]
      }
    ]
  })
}
