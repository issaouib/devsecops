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
              
              withSonarQubeEnv('SonarQube'){
                sh "mvn clean verify sonar:sonar -Dsonar.java.jdkHome=/usr/lib/jvm/java-11-openjdk-11.0.17.0.8-2.el8_6.aarch64 -Dsonar.projectKey=numeric-application -Dsonar.host.url=http://sonar.dev-ops.tn -Dsonar.login=sqp_998a3de54eb5758821eaa4c3dcc32b7af1975fa1"
              }

            }
        } 
            
  }    

}
