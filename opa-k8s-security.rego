package main

deny[msg] {
    input.kind = "service"
    not input.spec.type = "ClusterIP"
    msg = "Service type should be ClusterIP"
}

deny[msg] {
    input.kind = "Deployment"
    not input.spec.template.containers[0].securityContext.runAsNonRoot = true
    msg = "Containers mut not run as root - use runAsNonRoot wihin container security context"
}