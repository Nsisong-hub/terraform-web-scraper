# Terraform-web-scraper
## Overview
This project sets up an **automated web scraper** using **Terraform** to provision AWS resources. The web scraper extracts data from a target website and stores it in an **RDS database** and an **S3 bucket** for persistent storage.

The infrastructure and automation are achieved using AWS services such as EC2, RDS, S3, CloudWatch, and IAM

## Features
+ **IAM Role**: Configured for secure access to S3, RDS, and CloudWatch.

+ **VPC Setup**: Includes public and private subnets for resource organization.

+ **EC2 Instance**: Runs the Python web scraper.

+ **RDS Instance**: Stores the scraped data in a MySQL database.

+ **S3 Bucket**: Backups the scraped data for long-term storage.

+ **CloudWatch Logs**: Monitors the EC2 instance for enhanced observability.


## Prerequisites
Ensure you have the following:
- ![AWS CLI](https://img.icons8.com/color/48/000000/amazon-web-services.png) AWS CLI configured
- ![Terraform](https://img.icons8.com/color/48/000000/terraform.png) Terraform installed (`>= 1.0`)
- ![Key](https://img.icons8.com/emoji/48/000000/key-emoji.png) An AWS key pair (replace in `variables.tf`)
- ![Git](https://img.icons8.com/color/48/000000/git.png)  Git installed

# Setup Instructions
## Step 1: Clone the Repository
```bash
git clone https://github.com/Nsisong-hub/web-scraper.git
cd web-scraper
```
## Step 2: Initialize Terraform
```bash
terraform init
```

## Step 3: Review and Customize Variables
Edit `variables.tf`  to update default values such as `region`, `key_pair_name`, and `db_password` if necessary.

## Step 4: Apply the Terraform Configuration
```bash
terraform appy
```
Type `yes` to confirm the infrastructure creation.

## Outputs
After deployment, Terraform provides key outputs:

* **EC2 Public IP**: SSH into your instance if needed.
* **RDS Endpoint**: Connect to the database.
* **S3 Bucket Name**: Verify where scraped data is stored.

## Python Web Scraper
The scraper performs the following tasks:

1. **Extracts Data**: Scrapes `<h1>` titles from a target website using BeautifulSoup.
2. **Stores Data in RDS**: Saves the scraped titles into a MySQL database table.
3. **Backups Data to S3**: Writes titles to a `.txt` file and uploads it to an S3 bucket.
Script Location: `/scraper.py`

## AWS Services Used
+ **IAM**: Role and policies for secure access.
+ **VPC**: Network for organizing resources.
+ **EC2**: Hosts the web scraper script.
+ **RDS**: MySQL database for persistent data storage.
+ **S3**: Storage for backup files.
+ **CloudWatch**: Log monitoring for troubleshooting.

## Known Issues
+ **RDS Connectivity**: Ensure security groups allow traffic between EC2 and RDS.
+ **Scraper Target**: Replace the `url` in `scraper.py` with a valid target website.

## Future Improvements
+ Add error handling for robust scraping.
+ Enable autoscaling for high availability.
+ Integrate notifications using AWS SNS.

## Author
This project was developed by **Nsisong Etim**. 

Feel free to connect on [LinkedIn](https://www.linkedin.com/in/nsisong-etim-64589126a) for collaboration.


