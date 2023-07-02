FROM openjdk:11
COPY target/*.jar app.jar
CMD ["java", "-jar", "app.jar"]
EXPOSE 9003
MAINTAINER vikranth.devops18@yahoo.com
