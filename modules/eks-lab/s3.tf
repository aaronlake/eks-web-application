resource "random_string" "mongo_dumps" {
  length  = 8
  special = false
}

resource "aws_s3_bucket" "mongo_dumps" {
  bucket = "${local.env}-${local.name}-mongo-dumps-${lower(random_string.mongo_dumps.result)}"

  tags = var.common_tags
}

resource "aws_s3_bucket_ownership_controls" "mongo_dumps" {
  bucket = aws_s3_bucket.mongo_dumps.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
  depends_on = [aws_s3_bucket_public_access_block.mongo_dumps]
}

resource "aws_s3_bucket_public_access_block" "mongo_dumps" {
  bucket = aws_s3_bucket.mongo_dumps.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "mongo_dumps" {
  bucket = aws_s3_bucket.mongo_dumps.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "PublicReadGetObject",
        "Effect" : "Allow",
        "Principal" : "*",
        "Action" : ["s3:GetObject"],
        "Resource" : ["arn:aws:s3:::${aws_s3_bucket.mongo_dumps.id}/*"]
      }
    ]
  })
}
