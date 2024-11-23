#Output Key Information 
output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.web_scraper_instance
}

output "rds_endpoint" {
  description = "RDS Endpoint"
  value       = aws_db_instance.web_scraper_rds.endpoint
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket used for data storage"
  value       = aws_s3_bucket.web_scraper_bucket
}
