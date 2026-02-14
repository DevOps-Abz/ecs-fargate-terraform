
module "alb" {
  source                = "./modules/alb"
  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnets
  alb_security_group_id = module.sg.alb_security_group_id
}

module "ecr" {
  source          = "./modules/ecr"
  repository_name = "my_repository"
}

module "ecs" {
  source                      = "./modules/ecs"
  vpc_id                      = module.vpc.vpc_id
  private_subnet_ids          = module.vpc.private_subnets
  alb_tg_arn                  = module.alb.alb_tg_arn
  alb_load_balancer_arn       = module.alb.alb_arn
  ecs_security_group_id       = module.sg.ecs_security_group_id
  ecs_task_execution_role_arn = module.iam.ecs_task_execution_role_arn
  ecr_repository_url          = module.ecr.repository_url
  container_image             = "${module.ecr.repository_url}:latest"
}

module "iam" {
  source = "./modules/iam"
}

module "sg" {
  source = "./modules/sg"
  vpc_id = module.vpc.vpc_id
}

module "vpc" {
  source = "./modules/vpc"
}









