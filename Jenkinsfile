



import groovy.json.JsonSlurper

def getFtpPublishProfile(def publishProfilesJson) {
  def pubProfiles = new JsonSlurper().parseText(publishProfilesJson)
  for (p in pubProfiles)
    if (p['publishMethod'] == 'FTP')
      return [url: p.publishUrl, username: p.userName, password: p.userPWD]
}

pipeline {
  agent any
  
   environment {
    AZURE_SUBSCRIPTION_ID = '79fbf3cc-259d-457c-bc08-b52560e2f0a6'
    AZURE_TENANT_ID = 'efce57aa-4ecc-4454-8451-82234c9c49c4'
  }
  
  stages {
    stage('init') {
      steps {
        checkout scm
      }
    }
    
    stage('build') {
      steps {
        sh 'mvn clean package'
      }
    }
    
    stage('deploy') {
      steps {
        script {
           def resourceGroup = 'deployments_group'
          def webAppName = 'deployments'
          
          // login Azure
          withCredentials([azureServicePrincipal('azuredeploy')]) { {
            sh '''
              az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET -t $AZURE_TENANT_ID
              az account set -s $AZURE_SUBSCRIPTION_ID
            '''
          }
          
          // get publish settings
          def pubProfilesJson = sh script: "az webapp deployment list-publishing-profiles -g $resourceGroup -n $webAppName", returnStdout: true
          def ftpProfile = getFtpPublishProfile(pubProfilesJson)
          
          // upload package
          sh "curl -T target/calculator-1.0.war $ftpProfile.url/webapps/ROOT.war -u '${ftpProfile.username}:${ftpProfile.password}'"
          
          // log out
          sh 'az logout'
        }
      }
    }
  }
}
