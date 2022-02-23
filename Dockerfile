FROM openjdk:latest
ARG APP_VERSION=$(mvn -q help:evaluate -Dexpression=spc.version -DforceStdout=true)
RUN echo "Building ${APP_VERSION}"
RUN curl -u jenkins:Admin1234 -o spring-petclinic.jar "https://springpetclinictestpro.jfrog.io/artifactory/example-repo-local/spring-petclinic-2.5.0-SNAPSHOT-${APP_VERSION}.jar" -L
EXPOSE 8080
ENTRYPOINT ["java","-jar","/spring-petclinic.jar"]
