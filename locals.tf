locals {
  s3_buckets = [
    "arn:aws:s3:::aravindkoniki-tfstate-28092024",
    "arn:aws:s3:::aravindkoniki-tfstate-28092024/*",
    "${aws_s3_bucket.codepipeline_bucket.arn}",
    "${aws_s3_bucket.codepipeline_bucket.arn}/*",
  ]
}
