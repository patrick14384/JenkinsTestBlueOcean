pipeline {
  agent {
    node {
      label 'TFS Build'
    }
    
  }
  stages {
    stage('build') {
      steps {
        powershell(script: 'CheckForLatestIncrementalBuild.ps1', returnStatus: true)
      }
    }
  }
  environment {
    First = 'TFS Build'
  }
}