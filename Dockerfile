FROM balenalib/rpi-raspbian:buster
MAINTAINER reeganm <>

# Jenkins version
ENV JENKINS_VERSION 2.235.1

# Other env variables
ENV JENKINS_HOME /var/jenkins_home
ENV JENKINS_SLAVE_AGENT_PORT 50000

# Enable cross build
RUN ["cross-build-start"]

# Install dependencies
RUN apt-get update \
  && apt-get install -y --no-install-recommends curl openjdk-8-jdk wget ca-certificates \
  && rm -rf /var/lib/apt/lists/*

# godaddy certificate is missing somehow
RUN mkdir -p /usr/local/share/ca-certificates
RUN wget https://ssl-ccp.godaddy.com/repository/gdroot-g2.crt -o /usr/local/share/ca-certificates/gdroot-g2.crt
RUN update-ca-certificates

# Get Jenkins
RUN curl -fL -o /opt/jenkins.war https://repo.jenkins-ci.org/public/org/jenkins-ci/main/jenkins-war/{$JENKINS_VERSION}/jenkins-war-{$JENKINS_VERSION}.war

# Disable cross build
RUN ["cross-build-end"]

# Expose volume
VOLUME ${JENKINS_HOME}

# Working dir
WORKDIR ${JENKINS_HOME}

# Expose ports
EXPOSE 8080 ${JENKINS_SLAVE_AGENT_PORT}

# Start Jenkins
CMD ["sh", "-c", "java -jar /opt/jenkins.war"]
