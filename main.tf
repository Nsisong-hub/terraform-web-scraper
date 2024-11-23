provider "aws" {
  region = var.region
}
# IAM Role for EC2, 
#This role will allow the EC2 instance to access S3, RDS, and CloudWatch.S
resource "aws_iam_role" "web_scraper_role" {
  name = "web_scraper_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach_s3_policy" {
  role       = aws_iam_role.web_scraper_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "attach_rds_policy" {
  role       = aws_iam_role.web_scraper_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
}

resource "aws_iam_role_policy_attachment" "attach_cloudwatch_policy" {
  role       = aws_iam_role.web_scraper_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}

resource "aws_iam_instance_profile" "web_scraper_instance_profile" {
  name = "web_scraper_instance_profile"
  role = aws_iam_role.web_scraper_role.name
}

#create a VPC
resource "aws_vpc" "web_scraper_vpc" {
  cidr_block = var.vpc_cidr_block
}

#Create a public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.web_scraper_vpc.id
  cidr_block = var.public_subnet_cidr
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
}

#Create a private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.web_scraper_vpc.id
  cidr_block = var.private_subnet_cidr
  availability_zone = "us-east-1c"
  
}

#Create internetgateway
resource "aws_internet_gateway" "web_scraper_igw" {
  vpc_id = aws_vpc.web_scraper_vpc.id
}

#Create a public RT
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.web_scraper_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.web_scraper_igw.id
  }
}

#Associate public RT and give it internet access
resource "aws_route_table_association" "public_subnet_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}


#Provision the EC2 instance that will run the web scraper.

resource "aws_instance" "web_scraper_instance" {
  ami           = "ami-012967cc5a8c9f891"  # Amazon Linux 2023 AMI ID (change if needed)
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public_subnet.id
  iam_instance_profile = aws_iam_instance_profile.web_scraper_instance_profile.name
  key_name               = var.key_pair_name

  security_groups = [aws_security_group.web_scraper_sg.id]

  tags = {
    Name = "Web Scraper EC2"
  }
  user_data = <<-EOF
                #!/bin/bash
                sudo yum update -y
                sudo yum install python3 git -y
                python3 -m ensurepip --upgrade # Ensure pip3 is installed
                python3 -m pip install --upgrade pip # Upgrade pip
                pip3 install requests beautifulsoup4 boto3 mysql-connector-python
                
                # Clone the GitHub repository
                git clone -b master https://github.com/Nsisong-hub/web-scraper.git /home/ec2-user/scraper

                # Run the scraper script
                python3 /home/ec2-user/scraper/scraper.py
              EOF


}
# Create a security group
resource "aws_security_group" "web_scraper_sg" {
  vpc_id = aws_vpc.web_scraper_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH from anywhere
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # HTTP access
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# New Security Group for RDS
resource "aws_security_group" "web_scraper_rds_sg" {
  vpc_id = aws_vpc.web_scraper_vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.web_scraper_sg.id] # Allow traffic from the EC2 instance's security group
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "RDS Security Group"
  }
}

# Update the RDS instance to use the new security group
resource "aws_db_instance" "web_scraper_rds" {
  allocated_storage    = 20
  instance_class       = var.db_instance_class
  engine               = var.db_engine
  engine_version       = "8.0.32"
  db_name              = var.db_name
  username             = var.db_username
  password             = var.db_password
  vpc_security_group_ids = [aws_security_group.web_scraper_rds_sg.id] # Updated here
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
  skip_final_snapshot = true
}

#Create an RDS instance that your web scraper will use to store data
/*resource "aws_db_instance" "web_scraper_rds" {
  allocated_storage    = 20
  instance_class       = var.db_instance_class
  engine               = var.db_engine
  engine_version       = "8.0.32"
  db_name              = var.db_name
  username             = var.db_username
  password             = var.db_password
  vpc_security_group_ids = [aws_security_group.web_scraper_sg.id]
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
  skip_final_snapshot = true
}*/

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "web_scraper_rds_subnet_group"
  subnet_ids = [aws_subnet.public_subnet.id, aws_subnet.private_subnet.id]

  tags = {
    Name = "Web Scraper RDS Subnet Group"
  }
}


#S3 Bucket, This bucket will store the backup of your scraped data
resource "aws_s3_bucket" "web_scraper_bucket" {
  bucket = "web-scraper-data-bucket"

  tags = {
    Name = "Web Scraper S3 Bucket"
  }
}

#Monitor the EC2 instance with CloudWatch
resource "aws_cloudwatch_log_group" "web_scraper_log_group" {
  name = "/aws/ec2/web-scraper"
}

resource "aws_cloudwatch_log_stream" "web_scraper_log_stream" {
  name           = "web-scraper-logs"
  log_group_name = aws_cloudwatch_log_group.web_scraper_log_group.name
}

