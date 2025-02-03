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
                    url: "http://172.26.252.31:8082/artifactory/",
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
		   sh "cd ./jenkins-data/devops-project/demo-maven-hello-world"
                   sh "ls -l"
		   sh "sudo -n  ansible-playbook create-container-image.yaml"
	          }
            }

    stage('Deploy to AWS EC2') {
            steps {
                sshagent(['ad53457a-e545-46cd-9085-2634158d0f4c']) {
                    sh '''
                    ssh -i /home/jenkinsadmin/.ssh/id_rsa -o StrictHostKeyChecking=no ubuntu@18.206.125.73 <<EOF
                    sudo docker pull atulvsharma/helloworld:1.0
                    if sudo docker ps -a --format '{{.Names}}' | grep -q 'helloworld-container'; then
                       sudo docker stop helloworld-container || true
                       sudo docker rm helloworld-container || true
		    fi
                    sudo docker run -d -p 80:80 --name hellowrold-container atulvsharma/helloworld:1.0
                    EOF
                    '''
                }
            }
        }


   
	}
}
