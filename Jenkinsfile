pipeline {
  agent {
    docker 'maven:3.3.3'
  }
  stages {
    stage('build') {
      steps {
        powershell(script: 'CheckForLatestIncrementalBuild.ps1', returnStatus: true)
      }
    }
  }
}