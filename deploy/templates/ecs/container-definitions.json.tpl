[
    {
        "name": "api",
        "image": "${app_image}",
        "essential": true,
        "memoryReservation": 512,
        "environment": [
            {"name": "RAILS_MASTER_KEY", "value": "${rails_master_key}"},
            {"name": "RAILS_ENV", "value": "production"},
            {"name": "DB_HOST", "value": "${db_host}"},
            {"name": "DB_NAME", "value": "${db_name}"},
            {"name": "DB_USER", "value": "${db_user}"},
            {"name": "DB_PASS", "value": "${db_pass}"},
            {"name": "ALLOWED_HOSTS", "value": "${allowed_hosts}"}
        ],
        "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
                "awslogs-group": "${log_group_name}",
                "awslogs-region": "${log_group_region}",
                "awslogs-stream-prefix": "api"
            }
        },
        "portMappings": [
            {
                "containerPort": 3000,
                "hostPort": 3000
            }
        ],
        "mountPoints": [
            {
                "readOnly": false,
                "containerPath": "/vol/web",
                "sourceVolume": "static"
            }
        ]
    }
]
