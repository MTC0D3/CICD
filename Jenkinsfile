def secret = 'taofiks-appserver'
def server = 'taofiks@103.175.221.143'
def directory = '/home/taofiks/wayshub-backend'
def branch = 'master'
def namebuild = 'wayshub-backend:1.0'
def dockerHubCredentials = 'docker-hub-credentials'
def dockerHubRepo = 'mtc0d3/wayshub-backend'

pipeline {
    agent any

    stages {

        stage('Pull New Code') {
            steps {
                sshagent([secret]) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ${server} << EOF
                        cd ${directory}
                        git pull origin ${branch}
                        echo "Selesai Pulling!"
                        exit
                        EOF
                    """
                }
            }
        }

        stage('Build the Code') {
            steps {
                sshagent([secret]) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ${server} << EOF
                        cd ${directory}
                        docker build -t ${namebuild} .
                        echo "Selesai Building!"
                        exit
                        EOF
                    """
                }
            }
        }

        stage('Test the Code') {
            steps {
                sshagent([secret]) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ${server} << 'EOF'
                        cd ${directory}
                        docker run -d --name testcode -p 5002:5000 ${namebuild}
                        sleep 5
                        HTTP_CODE=\$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:5002/)
                        if [ "\$HTTP_CODE" = "404" ]; then
                            echo "Webserver is up and returning 404 as expected!"
                        else
                            echo "Unexpected HTTP response: \$HTTP_CODE"
                            docker logs testcode
                            docker rm -f testcode
                            exit 1
                        fi
                        docker rm -f testcode
                        echo "Selesai Testing!"
                        exit
                        EOF
                    """
                }
            }
        }

        stage('Deploy') {
            steps {
                sshagent([secret]) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ${server} << EOF
                        cd ${directory}
                        docker compose down
                        docker compose up -d
                        echo "Selesai Men-Deploy!"
                        exit
                        EOF
                    """
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: dockerHubCredentials, 
                    usernameVariable: 'DOCKER_USER', 
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sshagent([secret]) {
                        sh """
                            ssh -o StrictHostKeyChecking=no ${server} << EOF
                            cd ${directory}
                            echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin
                            docker tag ${namebuild} ${dockerHubRepo}:latest
                            docker push ${dockerHubRepo}:latest
                            echo "Selesai Push ke Docker Hub!"
                            exit
                            EOF
                        """
                    }
                }
            }
        }

        stage('Push Notif to Discord') {
            steps {
                discordSend(
                    description: 'test desc',
                    footer: '',
                    image: '',
                    link: '',
                    result: 'SUCCESS',
                    scmWebUrl: '',
                    thumbnail: '',
                    title: 'Discord Notif',
                    webhookURL: 'https://discord.com/api/webhooks/1382515352096870461/lxo6OwPf-tKKvxbPytKXQdru8kizfdkZS2c4NEUIVozqvtev5z3LhHmpn1CxPvszmH48'
                )
            }
        }

    }
}
