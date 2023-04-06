#**1. GITHUB**
## Репозиторий приложения: https://github.com/bokhanych/spring-boot, в нем написал Dockerfile для сборки. Подключен webhook.
## Используется ghcr.io как хранилище docker-image приложения.

#**2. APP-SERVER**
## Поднимается через Terraform, установка docker и ключа RSA для подключения с JENKNS с помощью скрипта Terraform/uploads/app-server-setup.sh (скрыт, т.к. содержит ключи). 
## Приложение запускается по адресу http://APP-SERVER-IP:8080/helloworld/hello

#**3. JENKINS**
## Поднимается вручную, настраивается скриптом jenkins-server-setup.sh + добавляются ключи SSH и скрипт для логина на ghcr.io
### localhost Build Steps: сборка приложения и отправка docker image в container registry:
#### git clone https://github.com/bokhanych/spring-boot.git && mvn package -f spring-boot/SpringBootHelloWorld/pom.xml && docker build spring-boot/ -t ghcr.io/bokhanych/spring-boot-image:latest && bash /home/.ghcr_login.sh && docker push ghcr.io/bokhanych/spring-boot-image:latest
### server-app Build Steps: если требуется, очистка от старого docker container и docker image, скачивание нового docker image и запуск контейнера:
#### ssh -o StrictHostKeyChecking=no root@3.70.135.140 'DCC=$(docker ps -aq); if [ ! "${DCC}" ]; then echo "Container doesnt exists"; else docker rm $(docker ps -aq) -f && docker rmi $(docker images -q);fi'
#### ssh -o StrictHostKeyChecking=no root@3.70.135.140 'bash /home/.ghcr_login.sh docker pull ghcr.io/bokhanych/spring-boot-image:latest && docker run -d --name spring-boot-container -p 8080:8181 -t ghcr.io/bokhanych/spring-boot-image:latest'

#**NOTES**:
    - .ghcr_login.sh.example - скрипт для логина на github, убрать расширение .example, изменить переменные, поместить на jenkins и app-сервер в /home/
    - Зависимости в системе: default-jdk maven net-tools || usermod -aG docker jenkins && chmod 666 /var/run/docker.sock

#**ДОПИЛИТЬ:** 
    - jenkins as pipeline
    - этапы проверки кода линтером
    - контейнер с мониторингом url и java порта приложения http://localhost:8080/helloworld/hello
    - уведомление о результате сборки и развертывания в любой канал