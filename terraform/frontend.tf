data "aws_route53_zone" "vsdev1_de" {
  name         = "vsdev1.de."
  private_zone = false
}

data "aws_acm_certificate" "vsdev1_de_certificate_us-east"{
  provider = aws.us_east_1
  domain = "*.vsdev1.de"
}

resource "aws_s3_bucket" "appsyncmasterclass-frontend" {
  bucket = "appsyncmasterclass-frontend.vsdev1.de"
  acl = "public-read" # TODO: only cloudfront shoud be allowed to access this bucket
  website {
    index_document = "index.html"
  }
 /*  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
 */  
  force_destroy = true
}

resource "aws_cloudfront_distribution" "appsyncmasterclass-frontend" {
  origin {
    domain_name = aws_s3_bucket.appsyncmasterclass-frontend.website_endpoint
    origin_id   = "assetS3Origin"
    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }
  default_root_object = "index.html"
  enabled             = true
  is_ipv6_enabled     = true
  aliases = [aws_s3_bucket.appsyncmasterclass-frontend.bucket]
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "assetS3Origin"
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 5
    max_ttl                = 10
    compress               = true
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  price_class = "PriceClass_100"
  tags = {
    Environment = "dev"
  }
  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn = data.aws_acm_certificate.vsdev1_de_certificate_us-east.arn
    ssl_support_method = "sni-only"
    minimum_protocol_version = "TLSv1"
  }
}

resource "aws_route53_record" "frontend-host-name" {
  zone_id = data.aws_route53_zone.vsdev1_de.id
  name = aws_s3_bucket.appsyncmasterclass-frontend.bucket
  type = "CNAME"
  ttl = "60"
  records = [aws_cloudfront_distribution.appsyncmasterclass-frontend.domain_name]
}

