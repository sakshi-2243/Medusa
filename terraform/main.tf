provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "zones" {}

module "vpc" {
  source      = "./vpc"
  aws_region  = var.aws_region
}

module "ecr" {
  source = "./ecr"
}

module "ecs" {
  source       = "./ecs"
  vpc_id       = module.vpc.vpc_id
  subnets      = module.vpc.subnets
  ecr_repo_url = module.ecr.repository_url
}
