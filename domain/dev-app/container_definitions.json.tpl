[
  {
    "name": "${name}",
    "image": "${container_image}",
    "cpu": 128,
    "memory": 1024,
    "essential": true,
    "portMappings": [
      {
        "containerPort": ${container_port},
        "hostPort": 0
      },
      {
        "containerPort": 5000,
        "hostPort": 0
      }
    ],
    "mountPoints": [
      {
        "sourceVolume": "${name}-home",
        "containerPath": "/var/${name}-home"
      }
    ],
    "Environment" : [
      {
        "Name": "JENKINS_USER",
        "Value": "admin"
      },
      {
        "Name": "JENKINS_PASS",
        "Value": "admin"
      },
      {
        "Name": "HTTP_PROXY",
        "Value": "${http_proxy}"
      },
      {
        "Name": "HTTPS_PROXY",
        "Value": "${https_proxy}"
      },
      {
        "Name": "NO_PROXY",
        "Value": "${no_proxy}"
      }
    ]
  }
]
