pipeline {
  agent {
    node {
      label 'Window 7 x64'
    }
    
  }
  stages {
    stage('build') {
      steps {
        powershell(script: 'CheckForLatestIncrementalBuild.ps1', returnStatus: true)
      }
    }
  }
}