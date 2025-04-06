FROM jenkins/inbound-agent:latest-jdk17

USER root

RUN apt-get update && \
    apt-get install -y docker.io && \
    usermod -aG docker jenkins

USER jenkins
