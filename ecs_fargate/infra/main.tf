# root/main.tf

module "vpc" {
  source             = "./vpc"
  private_vpc_cidrs  = var.private_vpc_cidrs
  public_vpc_cidrs   = var.public_vpc_cidrs
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  app_name           = var.app_name
}

module "ecs-cluster" {
  source = "./ecs-cluster"

  app_name             = var.app_name
  internet_cidr_block = var.internet_cidr_block
  subnets              = module.vpc.public_subnets
  vpc_id               = module.vpc.vpc_id
}