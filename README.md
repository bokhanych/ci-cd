**1. GITHUB**
- Репозиторий приложения: https://github.com/bokhanych/spring-boot, в нем содержится Dockerfile для сборки. Подключен webhook для запуска билда JENKINS.
- Используется ghcr.io как хранилище docker-image приложения.

**2. APP-SERVER**
- Поднимается через Terraform
- Используемые скрипты настройки APP-SERVER (все в одном user_data.sh):
   1. ssh-git-setup.sh (.gitignore) - добавляет ключ SSH и .ghcr_login.sh - скрипт для логина на ghcr.io
   2. docker-install.sh - установка Docker
   3. monitoring-setup.sh - установка Prometheus, Grafana, Node-explorer

**3. JENKINS**
- Поднимается вручную, необходимо вписать IP адрес APP-SERVER в Build-Job
- Используемые скрипты настройки JENKINS:
   1. jenkins-install.sh - установка jenkins
   2. docker-install.sh - установка Docker
   3. .ghcr_login.sh - скрипт для логина на ghcr.io
- localhost Build Steps: сборка приложения и отправка docker image в container registry
- server-app Build Steps: если требуется, очистка от старого docker container и docker image, скачивание и запуск нового docker image
- уведомление о результате сборки на почту gmail
- DEPENDENCIES: default-jdk maven || usermod -aG docker jenkins && chmod 666 /var/run/docker.sock

**NOTES**:
- .ghcr_login.sh - скрипт для логина на github, создается скриптом в /home/
- Приложение запускается по адресу http://APP-SERVER-IP:8080/helloworld/hello

**ДОПИЛИТЬ:** 
- jenkins as pipeline
- мониторинг url и java порта приложения http://localhost:8080/helloworld/hello