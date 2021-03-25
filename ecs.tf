resource "aws_ecs_capacity_provider" "cap-provider" {
  name = "cap-provider"
  auto_scaling_group_provider {
    auto_scaling_group_arn  = aws_autoscaling_group.asg.arn
    managed_scaling {
      status          = "ENABLED"
      target_capacity = 85
    }
  }
  
}

resource "aws_ecs_cluster" "demo-cluster" {
  name = var.cluster_name
  capacity_providers = [aws_ecs_capacity_provider.cap-provider.name]
  
}

resource "aws_ecs_task_definition" "task-def" {
  family = "task-1"
  container_definitions = file("service.json")
  network_mode = "bridge" 
}

resource "aws_ecs_service" "service1" {
  name = "service1"
  cluster = aws_ecs_cluster.demo-cluster.id
  task_definition = aws_ecs_task_definition.task-def.arn
  desired_count = 2
  scheduling_strategy = "REPLICA"
  

  load_balancer {
    target_group_arn = aws_lb_target_group.tg.arn
    container_name = "first"
    container_port = 80
  }
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent = 200
  
}
