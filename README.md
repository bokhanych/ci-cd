1. JENKINS with GitHub webhook

CI Job:
- git clone https://github.com/bokhanych/spring-boot.git
- mvn package -f spring-boot/SpringBootHelloWorld/pom.xml  (DEPENDENCIES: apt install maven -y)
- bash .ghcr_login.sh #dockerhub login
- docker build -t ghcr.io/bokhanych/spring-boot-image:latest .
- docker push ghcr.io/bokhanych/spring-boot-image:latest
CD Job:
- bash .ghcr_login.sh #dockerhub login
- docker pull ghcr.io/bokhanych/spring-boot-image:latest
- docker run --name spring-boot-container -p 8080:8181 -t ghcr.io/bokhanych/spring-boot-image:latest

NOTES:
.ghcr_login.sh.example - скрипт для логина на github, убрать расширение .example, изменить переменные, поместить на jenkins сервер в /home/
Зависимости в системе: default-jdk maven net-tools || usermod -aG docker jenkins && chmod 666 /var/run/docker.sock

#

2. APP-SERVER (terraform)

- разорачивание сервера с ключом RSA для подключения с JENKNS
- установка docker (docker-install.sh)

#

3. ДОПИЛИТЬ: 

- контейнер с мониторингом url и java порта приложения http://localhost:8080/helloworld/hello