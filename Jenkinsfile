@Library('slack') _
pipeline {
  agent any

  environment {
    deploymentName = "devsecops"
    containerName = "devsecops-container"
    serviceName = "devsecops-svc"
    //imageName = "issaouib/numeric-app:${GIT_COMMIT}"
    applicationURL = "http://myapp.dev-ops.tn"
    applicationURI = "/increment/99"
  }

  stages {
      stage('kubernetes Deployments - Prod') {
          steps {
            parallel(
              "Deployment": {
                  withKubeConfig(credentialsId: 'kubernetes') {
                    sh "imageName=$(cat /var/lib/jenkins/tag)"
                    sh "sed -i 's#replace#${imageName}#g' k8s_prod_deployment_service.yaml"
                    sh "kubectl -n prod apply -f k8s_prod_deployment_service.yaml"
                  }
              },
              "Rollout Status": {
                  withKubeConfig(credentialsId: 'kubernetes') {
                    sh "bash k8s-prod-rollout-status.sh"
                  }
              }
            )
          }
      } 
    
  }
      
}
