FROM openjdk:11.0.10-slim AS builder

COPY ./certs/sonar/sonar.crt /tmp/
COPY ./certs/ca/root-ca.crt /tmp/

RUN keytool -import -v -trustcacerts -alias sonarqube -file /tmp/sonar.crt \
    -keystore ${JAVA_HOME}/lib/security/cacerts -noprompt -storepass changeit
RUN keytool -import -v -trustcacerts -alias ca-root -file /tmp/root-ca.crt \
    -keystore ${JAVA_HOME}/lib/security/cacerts -noprompt -storepass changeit

FROM sonarqube:8.7.0-community
RUN find . -type f -path '/lib/security/cacerts'
COPY --from=builder /usr/local/openjdk-11/lib/security/cacerts ${JAVA_HOME}/lib/security/cacerts
