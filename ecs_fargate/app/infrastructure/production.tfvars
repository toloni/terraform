# remote state
remote_state_key = "PROD/platform.tfstate"
remote_state_bucket = "YOUR_S3_BUCKET"

# service variables
ecs_service_name = "springbootapp"
docker_container_port = 8080
desired_task_number = "2"
spring_profile = "default"
memory = 1024