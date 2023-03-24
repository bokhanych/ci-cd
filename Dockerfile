FROM adoptopenjdk/openjdk11:alpine-jre

LABEL org.opencontainers.image.source https://github.com/bokhanych/ci-cd

WORKDIR /myapp

COPY spring-boot/SpringBootHelloWorld/target/SpringBootHelloWorld-0.0.1-SNAPSHOT.jar /myapp/my-app.jar

ENTRYPOINT ["java","-jar","my-app.jar"]