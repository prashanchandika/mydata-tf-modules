[
  {
    "name": "${name}",
    "image": "${image}",
    "essential": true,
    "command": ${command},
    "environment": ${env_variables},
    "secrets": ${secrets},
    "portMappings": [
      {
        "containerPort": ${port},
        "hostPort": ${port}
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${log_group}",
        "awslogs-region": "${region}",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]
