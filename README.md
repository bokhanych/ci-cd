1. JENKINS: Отправка образа после создания в ghcr.io
- git clone https://github.com/bokhanych/spring-boot.git
- mvn package -f spring-boot/SpringBootHelloWorld/pom.xml  (DEPENDENCIES: apt install maven -y)

- bash .ghcr_login.sh #dockerhub login
- docker build -t ghcr.io/bokhanych/spring-boot-image:latest .
- docker push ghcr.io/bokhanych/spring-boot-image:latest

ДОПИЛИТЬ: 
- тесты сборки приложения
- Jenkins pipelines - trigger to BUILD and PULL to APP-SERVER latest image

#

2. APP-SERVER: Скачать docker-image приложения и запустить
- bash .ghcr_login.sh #dockerhub login
- docker pull ghcr.io/bokhanych/spring-boot-image:latest
- docker run --name spring-boot-container -p 8080:8181 -t ghcr.io/bokhanych/spring-boot-image:latest

ДОПИЛИТЬ: 
- контейнер с мониторингом url и java порта приложения http://localhost:8080/helloworld/hello


3. TERRAFORM:
- создание инфраструктуры для развертывания APP-SERVER и JENKINS


*** Tasks:
- создать pipeline в jenkins; 