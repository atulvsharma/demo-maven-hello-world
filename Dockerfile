# Create a coustom docker image
# Pull tomcat latest image from dockerhub
From tomcat:latest

#Created and maintained by - Atul Sharma
MAINTAINER "Atul Sharma"

#Copy the war file inside the tomcat container
COPY ./target/jb-hello-world-maven-0.2.0.jar  /usr/local/tomcat/webapps
