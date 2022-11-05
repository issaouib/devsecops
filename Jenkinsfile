pipeline {
  agent any

  environment {
    deploymentName = "devsecops"
    containerName = "devsecops-container"
    serviceName = "devsecops-svc"
    imageName = "issaouib/numeric-app:${GIT_COMMIT}"
    applicationURL = "http://myapp.dev-ops.tn/"
    applicationURI = "/increment/99"
  }

  stages {
      stage('Build Artifact') {
            steps {
              sh "mvn clean package -DskipTests=true"
              archive 'target/*.jar' //so that they can be downloaded later.
            }
      } 
      stage('Unit Test -JUnit and Jacoco') {
            steps {
              sh "mvn test"
            }

      }

      stage('Mutation-Test-PIT') {
            steps {
              sh "mvn org.pitest:pitest-maven:mutationCoverage"
            }
            post {
              always {
                pitmutation mutationStatsFile: 'target/pit-reports/**/mutations.xml'
              }
            }
      }
      
      stage('SonarQube') {
            steps {
              withSonarQubeEnv('SonarQube') {
                sh "mvn clean verify sonar:sonar \
                  -Dsonar.projectKey=numeric-application \
                  -Dsonar.host.url=http://sonar.dev-ops.tn"
              }
              timeout(time: 60, unit: 'MINUTES') {
                script {
                  waitForQualityGate abortPipeline: true
                  }
              }
           }
      }
      
      stage('Vulnerability Scan - Docker') {
            steps {
              parallel(
                "Dependency Scan": {
                   sh "mvn dependency-check:check"
                },
                "Trivy Scan": {
                  sh "bash trivy.sh"
                },
                "opa conftest": {
                  sh 'docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy opa-dockerfile-security.rego Dockerfile'
                }
                
              )
              
            }
      }
      
      stage('Docker Build&Push') {
            steps {
              withDockerRegistry(credentialsId: 'Docker', url: "") {
              sh 'printenv'
              sh 'sudo docker build -t issaouib/numeric-app:""$GIT_COMMIT"" .'
              sh 'docker push issaouib/numeric-app:""$GIT_COMMIT""'
              }
            }
      }

      stage('Vulnerability Scan - k8s') {
            steps {
              parallel(
                "OPA Scan": {
                    sh 'docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy opa-k8s-security.rego k8s_deployment_service.yaml'
                },
                "Kubesec Scan": {
                  sh "bash kubesec-scan.sh"
                },
                "Trivy Scan": {
                  sh "bash trivy-k8s-scan.sh"
                }

              )
            }
      }

      stage('kubernetes Deployments') {
          steps {
            parallel(
              "Deployment": {
                  withKubeConfig(credentialsId: 'kubernetes') {
                    sh "bash k8s-deployment.sh"
                  }
              },
              "Rollout Status": {
                  withKubeConfig(credentialsId: 'kubernetes') {
                    sh "bash k8s-rollout-status.sh"
                  }
              }
            )
          }
      } 
    stage('Integration Test') {
        steps {
          script {
            try {
              withKubeConfig(credentialsId: 'kubernetes') {
                sh "bash integration-test.sh"
              }
            } catch (e) {
                withKubeConfig(credentialsId: 'kubernetes') {
                  sh "kubectl -n default rollout undo deploy ${deploymentName}"
              } 
              throw e
            }
          }
        }
    }
  }
      post { 
            always { 
              junit 'target/surefire-reports/*.xml'
              jacoco execPattern: 'target/jacoco.exec'
              dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'

            }
      }        
}
