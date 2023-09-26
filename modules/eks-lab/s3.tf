resource "random_string" "mongo_dumps" {
  length  = 8
  special = false
}

resource "aws_s3_bucket" "mongo_dumps" {
  bucket = "${local.env}-${local.name}-mongo-dumps-${lower(random_string.mongo_dumps.result)}"

  tags = var.common_tags
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
