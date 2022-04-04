FROM openjdk:latest
ARG SPC_VERSION=1.3
RUN echo "Building ${SPC_VERSION}"
RUN curl -u jenkins:Admin1234 -o spring-petclinic.jar "https://springpetclinictestpro.jfrog.io/artifactory/example-repo-local/spring-petclinic-2.5.0-SNAPSHOT-${SPC_VERSION}.jar" -L
EXPOSE 8080
ENTRYPOINT ["java","-jar","/spring-petclinic.jar"]
