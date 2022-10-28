pipeline {
  agent any

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
                  -Dsonar.host.url=http://sonar.dev-ops.tn \
                  -Dsonar.login=sqp_239f49470e99e04d4ec8fa9c952871abfe51c2c1"
              }
              timeout(time: 1, unit: 'MINUTES') {
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

      stage('kubernetes Deployments') {
            steps {
              withKubeConfig(credentialsId: 'kubernetes') {
                sh "sed -i 's#replace#issaouib/numeric-app:${GIT_COMMIT}#g' k8s_deployment_service.yaml"
                sh "kubectl apply -f k8s_deployment_service.yaml"
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
