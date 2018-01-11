variable "cluster_name" { default="default" }

data "external" "ecs_instances" {
    program = ["/bin/bash", "${path.module}/get_params.sh" ]
    query = {
        cluster_name = "${var.cluster_name}"
    }   
}

output "ids" {
    value = ["${split(",",data.external.ecs_instances.result.ids)}"]
}
output "private_ips" {
    value = ["${split(",",data.external.ecs_instances.result.private_ips)}"]
}
output "public_ips" {
    value = ["${split(",",data.external.ecs_instances.result.public_ips)}"]
}
output "public_dns_names" {
    value = ["${split(",",data.external.ecs_instances.result.public_dns)}"]
}
output "private_dns_names" {
    value = ["${split(",",data.external.ecs_instances.result.private_dns)}"]
}
