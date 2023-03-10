APP-SERVER
- докер контейнер c application
- докер контейнер c Prometheus (мониторит порт и URL приложения)

JENKINS или GitHubActions
- скачать исходники приложения с github
- протестировать и собрать jar
- сделать докер образ, отправить на GitHub Container Registry
- тригером (после обновления ветки main) пересобрать контейнер на APP-SERVER


DOCKER:
docker build -t spring-boot-image:1 .
docker run --name spring-boot-container -p 8080:8181 -t spring-boot-image:1

TERRAFORM:
создание инфраструктуры для развертывания APP-SERVER и JENKINS

APP URL:
http://localhost:8080/helloworld/hello





NOTES:
# Скачать и собрать приложение
git clone https://github.com/bokhanych/spring-boot.git
cd spring-boot/SpringBootHelloWorld
mvn package
# ---
JAR файл: $(pwd)/target/SpringBootHelloWorld-0.0.1-SNAPSHOT.jar


Задачи:
1. Отправка образа после создания в регистри.



MANUALS:

GitHub Actions - Основы Автоматизации - DevOps - GitOps
https://www.youtube.com/watch?v=Yg5rpke79X4

ghcr.io
https://docs.github.com/ru/packages/working-with-a-github-packages-registry/working-with-the-container-registry