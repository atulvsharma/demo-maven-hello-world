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

	  stage ('Just Testing'){
				steps{
					sh 'echo "Here I am"'
				     }
				}

          stage ('Build')  {
              steps {
					sh 'pwd'
					sh "cd ./jenkins-data/devops-project/demo-maven-hello-world"
					sh "ls -l"
                                        sh "mvn --version"
					sh "mvn package"
					}

      }

     stage ('SonarQube Analysis') {
        steps {
              withSonarQubeEnv('sonar') {

                  sh "cd ./jenkins-data/devops-project/demo-maven-hello-world"               
		  sh "mvn clean verify sonar:sonar \
			-Dsonar.projectKey=jb-hello-world-maven \
			-Dsonar.projectName='jb-hello-world-maven' \
			-Dsonar.host.url=http://172.26.252.31:9000 \
			-Dsonar.token=sqp_6397ce008a11ea10a24bf557e946894140a63990"
                 }
            }
      }

    stage ('Artifactory configuration') {
            steps {
                rtServer (
                    id: "jfrog",
                    url: "http://172.26.252.31/:8082/",
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
                    pom: './pom.xml',
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
