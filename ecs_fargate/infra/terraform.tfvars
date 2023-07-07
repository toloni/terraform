# root/variables.tf

aws_region= "us-east-1"
availability_zones = ["us-east-1a", "us-east-1b"]
vpc_cidr = "10.0.0.0/16"
internet_cidr_block = "0.0.0.0/0"
public_vpc_cidrs = ["10.0.2.0/24", "10.0.4.0/24"]
private_vpc_cidrs = ["10.0.1.0/24", "10.0.3.0/24"]
app_name = "apptoloni"