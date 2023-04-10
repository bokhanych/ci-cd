**1. GITHUB**
- Репозиторий приложения: https://github.com/bokhanych/spring-boot, в нем содержится Dockerfile для сборки. Подключен webhook для запуска билда JENKINS.
- Используется ghcr.io как хранилище docker-image приложения.

**2. APP-SERVER**
- Создается с помощью Terraform командой terraform apply в папке проекта. После созданий необходимо вписать IP адрес в Глобальные настройки Jenkins
- Используемые скрипты настройки APP-SERVER:
   1. ssh-git-setup.sh (.gitignore) - добавляет ключ SSH и ghcr_login.sh - скрипт для логина на ghcr.io
   2. docker-install.sh - установка Docker
   3. monitoring-setup.sh - установка Prometheus, Grafana, Blackbox, docker-metrics.

**3. JENKINS**
- Создается вручную, 
- Используемые скрипты настройки JENKINS:
   1. jenkins-install.sh - установка jenkins
   2. docker-install.sh - установка Docker
   3. ghcr_login.sh - скрипт для логина на ghcr.io
- localhost Build Steps: сборка приложения и отправка docker image в container registry
- server-app Build Steps: если требуется, очистка от старого docker container и docker image, скачивание и запуск нового docker image
- уведомление о результате сборки на почту gmail
- DEPENDENCIES: default-jdk maven || usermod -aG docker jenkins && chmod 666 /var/run/docker.sock

**4. MONITORING**
- Используется Grafana+Prometheus+Blackbox+Docker-metrics. Поднимается автоматически, с dashboard. Мониторит url приложения и docker containers.

**NOTES**:
- Приложение запускается по адресу http://APP-SERVER-IP:8080/helloworld/hello

**Для будущих релизов:** 
- проверка кода в test-brache
- jenkins as pipeline