pipeline {
  agent {
    kubernetes {
      yaml '''
        apiVersion: v1
        kind: Pod
        metadata:
          labels:
            some-label: some-label-value
        spec:
          containers:
          - name: maven
            image: maven:alpine
            command:
            - cat
            tty: true
        '''
    }
  }

  stages {
      stage('Build Artifact') {
            steps {
              container('maven') {
              sh "mvn clean package -DskipTests=true"
              //archive 'target/*.jar' //so that they can be downloaded later.
              }
            }
        }          
  }    

}
