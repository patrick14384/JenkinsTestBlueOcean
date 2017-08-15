pipeline {
  agent {
    node {
      label 'Windows7 x64'
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