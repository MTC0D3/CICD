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
                        ssh -o StrictHostKeyChecking=no ${server} << 'EOF'
                        set -e
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
                        set -e
                        cd ${directory}
                        docker rm -f testcode || true
                        docker run -d --name testcode -p 5009:5000 ${namebuild}
                        echo "Menunggu service siap..."
                        sleep 10

                        STATUS_CODE=\$(curl -s -o /dev/null -w "%{http_code}" http://localhost:5009/)
                        if [ "\$STATUS_CODE" -eq 404 ]; then
                            echo "Webserver is up and returning 404 as expected!"
                        else
                            echo "Unexpected response (\$STATUS_CODE), stopping process..."
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
                withCredentials([usernamePassword(credentialsId: dockerHubCredentials, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
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
                discordSend description: 'test desc',
                            footer: '',
                            image: '',
                            link: '',
                            result: 'SUCCESS',
                            scmWebUrl: '',
                            thumbnail: '',
                            title: 'Discord Notif',
                            webhookURL: 'https://discord.com/api/webhooks/1382515352096870461/lxo6OwPf-tKKvxbPytKXQdru8kizfdkZS2c4NEUIVozqvtev5z3LhHmpn1CxPvszmH48'
            }
        }
    }
}
