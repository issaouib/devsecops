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
              
              withSonarQubeEnv('SonarQube', envOnly: true) {
  // This expands the evironment variables SONAR_CONFIG_NAME, SONAR_HOST_URL, SONAR_AUTH_TOKEN that can be used by any script.
                println ${env.SONAR_HOST_URL} 
              }

            }
        } 
            
  }    

}
