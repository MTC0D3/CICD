def secret = 'taofiks-appserver'
def server = 'taofiks@103.175.221.143'
def directory = '/home/taofiks/wayshub-backend'
def branch = 'main'
def namebuild = 'wayshub-backend:1.0'
def dockerHubCredentials = 'docker-hub-credentials'
def dockerHubRepo = 'mtc0d3/wayshub-backend'

pipeline{
    agent any
    stages{
        stage ('pull new code'){
            steps{
                sshagent([secret]){
                    sh """ssh -o StrictHostKeyChecking=no ${server} << EOF
                    cd ${directory}
                    git pull origin ${branch}
                    echo "Selesai Pulling!"
                    exit
                    EOF"""
                }
            }
        }

        stage ('build the code'){
            steps{
                sshagent([secret]){
                    sh """ssh -o StrictHostKeyChecking=no ${server} << EOF
                    cd ${directory}
                    docker build -t ${namebuild} .
                    echo "Selesai Building!"
                    exit
                    EOF"""
                }
            }
        }

        stage ('test the code'){
            steps{
                sshagent([secret]){
                    sh """ssh -o StrictHostKeyChecking=no ${server} << EOF
                        cd ${directory}
                        docker run -d --name testcode -p 5001:5000 ${namebuild}
                        wget --spider localhost:5001
			docker stop testcode
                        docker rm -f testcode
                        echo "Selesai Testing!"
                        exit
                    EOF"""
                }
            }
        }

        stage ('deploy'){
            steps {
                sshagent([secret]){
                    sh """ssh -o StrictHostKeyChecking=no ${server} << EOF
                    cd ${directory}
                    docker compose down
                    docker compose up -d
                    echo "Selesai Men-Deploy!"
                    exit
                    EOF"""
                }
            }
        }

        stage('push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: dockerHubCredentials, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sshagent([secret]) {
                        sh """ssh -o StrictHostKeyChecking=no ${server} << EOF
                        cd ${directory}
                        echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                        docker tag ${namebuild} ${dockerHubRepo}:latest
                        docker push ${dockerHubRepo}:latest
                        echo "Selesai Push ke Docker Hub!"
                        exit
                        EOF"""
                    }
                }
            }
        }

        stage('push notif to discord') {
            steps {
                discordSend description: 'Be update', footer: '', image: '', link: '', result: 'SUCCESS', scmWebUrl: '', thumbnail: '', title: 'Discord Notif', webhookURL: 'https://discord.com/api/webhooks/1382515352096870461/lxo6OwPf-tKKvxbPytKXQdru8kizfdkZS2c4NEUIVozqvtev5z3LhHmpn1CxPvszmH48'
            }
        }

    }
}

