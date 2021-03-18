FROM alpine:3.12.4
RUN apk --no-cache --update add openjdk11-jre npm git
COPY sonar.crt /tmp/
COPY root-ca.crt /tmp/
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk
RUN keytool -import -v -trustcacerts -alias sonarqube -file /tmp/sonar.crt \
    -keystore ${JAVA_HOME}/lib/security/cacerts -noprompt -storepass changeit
RUN keytool -import -v -trustcacerts -alias ca-root -file /tmp/root-ca.crt \
    -keystore ${JAVA_HOME}/lib/security/cacerts -noprompt -storepass changeit
RUN rm /tmp/*.crt
ENV SONAR_SCANNER_OPTS="-Djavax.net.ssl.trustStore=$JAVA_HOME/lib/security/cacerts -Djavax.net.ssl.keyStore=$JAVA_HOME/lib/security/cacerts"
WORKDIR workspace

ADD sonar.tar.gz /bin/
COPY entrypoint.sh /bin/entrypoint.sh
RUN chmod +x /bin/entrypoint.sh
ENV PATH="$PATH:$JAVA_HOME"
COPY sonar-project.properties sonar-project.properties
ENTRYPOINT ["/bin/sh", "/bin/entrypoint.sh"]
