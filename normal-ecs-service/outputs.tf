output "listner_port"{
    value = module.ecs_service.listener_port
}

output "listner_arn"{
    value = module.ecs_service.listener_arn
}

output "listner_id"{
    value = module.ecs_service.listener_id
}


#HTTP LISTENER
/* output "listner_arn_http"{
    value = module.ecs_service.listener_arn_http
}

output "listner_id_http"{
    value = module.ecs_service.listener_id_http
} */


#HTTPS LISTENER
/* output "listner_arn_https"{
    value = module.ecs_service.listener_arn_https
}

output "listner_id_https"{
    value = module.ecs_service.listener_id_https
} */