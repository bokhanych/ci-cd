**1. GITHUB**
- Репозиторий приложения: https://github.com/bokhanych/spring-boot, в нем написал Dockerfile для сборки. Подключен webhook.
- Используется ghcr.io как хранилище docker-image приложения.

**2. APP-SERVER**
- Поднимается через Terraform, установка docker и ключа RSA для подключения с JENKNS с помощью скрипта Terraform/uploads/app-server-setup.sh (скрыт, т.к. содержит ключи). 
- Приложение запускается по адресу http://APP-SERVER-IP:8080/helloworld/hello
- Используемые скрипты настройки APP-SERVER:
   > ssh-rsa-setup.sh (скрыт). Его содержимое: mkdir /root/.ssh/ && echo "ssh-rsa YOUR_KEY" > /root/.ssh/authorized_keys && chmod 600 /root/.ssh/authorized_keys
**3. JENKINS**
- Поднимается вручную, настраивается скриптом jenkins-server-setup.sh + добавляются ключи SSH и скрипт для логина на ghcr.io
- localhost Build Steps: сборка приложения и отправка docker image в container registry
- server-app Build Steps: если требуется, очистка от старого docker container и docker image, скачивание и запуск нового docker image
- DEPENDENCIES: default-jdk maven || usermod -aG docker jenkins && chmod 666 /var/run/docker.sock

**NOTES**:
- .ghcr_login.sh - скрипт для логина на github, поместить на jenkins и app-сервер в /home/
- содержимое: export PAT=<YOUR_TOKEN>> && export GIT_USER=<YOUR_USERNAME> && echo $PAT | docker login ghcr.io --username $GIT_USER --password-stdin

**ДОПИЛИТЬ:** 
- jenkins as pipeline
- мониторинг url и java порта приложения http://localhost:8080/helloworld/hello
- уведомление о результате сборки и развертывания в любой канал