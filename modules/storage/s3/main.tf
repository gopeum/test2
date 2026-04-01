resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name

  tags = {
    Name = "${var.project}-s3"
  }
}

# 퍼블릭 접근 차단 (기본 보안)
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 버전 관리 (나중에 로그/데이터 보호)
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}
