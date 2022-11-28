
pipeline {
  agent any

  stages {
      stage('kubernetes Deployments - Prod') {
          steps {
            parallel(
              "Deployment": {
                  withKubeConfig(credentialsId: 'kubernetes') {
                    def imageName = "${cat /var/lib/jenkins/tag}"
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
