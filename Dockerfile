FROM adoptopenjdk/openjdk11:alpine-jre

LABEL description="Spring Boot Hello World Example"

WORKDIR /myapp

COPY target/SpringBootHelloWorld-0.0.1-SNAPSHOT.jar /myapp/my-app.jar

ENTRYPOINT ["java","-jar","my-app.jar"]