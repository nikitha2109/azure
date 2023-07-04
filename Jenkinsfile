import groovy.json.JsonSlurper

def getFtpPublishProfile(def publishProfilesJson) {
  def pubProfiles = new JsonSlurper().parseText(publishProfilesJson)
  for (p in pubProfiles) {
    if (p['publishMethod'] == 'FTP') {
      return [url: p.publishUrl, username: p.userName, password: p.userPWD]
    }
  }
}

pipeline {
  agent any
  
  environment {
    AZURE_SUBSCRIPTION_ID = '79fbf3cc-259d-457c-bc08-b52560e2f0a6'
    AZURE_TENANT_ID = 'efce57aa-4ecc-4454-8451-82234c9c49c4'
  }
  
  stages {
    stage('Initialize') {
      steps {
        checkout scm
      }
    }
    
    stage('Build') {
      steps {
        sh 'mvn clean package'
      }
    }
    
    stage('Deploy') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'azure-service-principal', passwordVariable: 'AZURE_CLIENT_SECRET', usernameVariable: 'AZURE_CLIENT_ID')]) {
          sh '''
            az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET -t $AZURE_TENANT_ID
            az account set --subscription $AZURE_SUBSCRIPTION_ID
          '''
          
          def resourceGroup = '<deployments_group>'
          def webAppName = '<deployments>'
          
          // Get publish settings
          def pubProfilesJson = sh script: "az webapp deployment list-publishing-profiles -g $resourceGroup -n $webAppName", returnStdout: true
          def ftpProfile = getFtpPublishProfile(pubProfilesJson)
          
          // Upload package
          sh "curl -T target/calculator-1.0.war $ftpProfile.url/webapps/ROOT.war -u '${ftpProfile.username}:${ftpProfile.password}'"
          
          // Log out
          sh 'az logout'
        }
      }
    }
  }
}
