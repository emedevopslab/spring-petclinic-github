FROM openjdk:latest
RUN curl -u jenkins:Admin1234 -o spring-petclinic.jar "https://springpetclinictestpro.jfrog.io/artifactory/example-repo-local/spring-petclinic-2.5.0-SNAPSHOT-1.0.jar" -L
EXPOSE 8080
ENTRYPOINT ["java","-jar","/spring-petclinic.jar"]
