pipeline {
  agent any
  tools {

  maven 'maven'

  }
    stages {

      stage ('Checkout SCM'){
        steps {
          checkout([$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'github', url: 'https://github.com/atulvsharma/demo-maven-hello-world.git']]])
        }
      }

          stage ('Build')  {
              steps {

            dir('jenkins-data/devops-project/demo-maven-hello-world/'){
            sh pwd
                        sh "mvn package"
          }
        }

      }

     stage ('SonarQube Analysis') {
        steps {
              withSonarQubeEnv('sonar') {

                                dir('jenkins-data/devops-project/demo-maven-hello-world/'){
                 sh 'mvn -U clean install sonar:sonar'
                }

              }
            }
      }

    stage ('Artifactory configuration') {
            steps {
                rtServer (
                    id: "jfrog",
                    url: "http://172.26.252.31/:8082/artifactory",
                    credentialsId: "jfrog"
                )

                rtMavenDeployer (
                    id: "MAVEN_DEPLOYER",
                    serverId: "jfrog",
                    releaseRepo: "libs-release",
                    snapshotRepo: "libs-snapshot"
                )

                rtMavenResolver (
                    id: "MAVEN_RESOLVER",
                    serverId: "jfrog",
                    releaseRepo: "libs-release",
                    snapshotRepo: "libs-snapshot"
                )
            }
    }

    stage ('Deploy Artifacts') {
            steps {
                rtMavenRun (
                    tool: "maven", // Tool name from Jenkins configuration
                    pom: 'demo-maven-hello-world/pom.xml',
                    goals: 'clean install',
                    deployerId: "MAVEN_DEPLOYER",
                    resolverId: "MAVEN_RESOLVER"
                )
         }
    }

    stage ('Publish build info') {
            steps {
                rtPublishBuildInfo (
                    serverId: "jfrog"
             )
        }
    }

    stage('Build Container Image') {

            steps {
                                  dir('jenkins-data/devops-project/demo-maven-hello-world/'){
                  sh "sudo ansible-playbook create-container-image.yaml"
            }
        }
    }
   
    stage('Waiting for Approvals') {

        steps{
             input('Test Completed ? Please provide  Approvals for Prod Release ?')
             }

		}
	}
}
