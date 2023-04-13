pipeline {
    agent any

    stages {
        stage('Git clone') {
            steps {
                git clone https://github.com/bokhanych/spring-boot.git && mvn package -f spring-boot/SpringBootHelloWorld/pom.xml
            }
        }
        stage('Docker build & push') {
            steps {
                docker build spring-boot/ -t ghcr.io/bokhanych/spring-boot-image:latest && bash /home/ghcr_login.sh && docker push ghcr.io/bokhanych/spring-boot-image:latest
            }
        }
        stage('SSH - clear old version') {
            steps {
                ssh -o StrictHostKeyChecking=no root@$APP_SERVER_IP 'DCC=$(docker container ls -a | grep "spring-boot"); if [ ! "${DCC}" ]; then echo "ALL OK"; else docker rmi ghcr.io/bokhanych/spring-boot-image -f && docker rm spring-boot-container -f;fi'
            }
        }
        stage('SSH - run latest version') {
            steps {
                ssh -o StrictHostKeyChecking=no root@$APP_SERVER_IP 'bash /home/ghcr_login.sh && docker pull ghcr.io/bokhanych/spring-boot-image:latest && docker run -d --name spring-boot-container -p 8080:8181 -t ghcr.io/bokhanych/spring-boot-image:latest'
            }
        }
    }
}