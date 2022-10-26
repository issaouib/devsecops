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
            post {
              always {
                junit 'target/surefire-reports/*.xml'
                jacoco execPattern: 'target/jacoco.exec'
              }
            }
      }
      stage('SonarQube Analyzer') {
            steps {
              sh "mvn clean verify sonar:sonar  -Dsonar.projectKey=numeric-application -Dsonar.host.url=http://sonar.dev-ops.tn -Dsonar.login=sqp_998a3de54eb5758821eaa4c3dcc32b7af1975fa1"
              }

            }
        
            
  }    

}
