[
  {
    "essential": true,
    "image": "sonamsamdupkhangsar/springboot-docker",
    "name": "${NAME}",
    "portMappings": [
      {
        "hostPort": 80,
        "protocol": "tcp",
        "containerPort": 80
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${NAME}",
        "awslogs-region": "${AWS_REGION}",
        "awslogs-stream-prefix": "${ENV}"
      }
    }
  }
]
