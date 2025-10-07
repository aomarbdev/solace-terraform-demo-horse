pipeline {
    agent any

    environment {
        TERRAFORM_BIN = '/opt/homebrew/bin/terraform'
        SOLACE_CLOUD_CREDS = credentials('solace-cloud-creds')
        REPO_DIR = '/Users/aomarbariz/Documents/Sales_Engineer/Demo/solace-terraform-jenkins'
    }

    stages {
        stage('Local Broker - Init Terraform') {
            steps {
                dir("${REPO_DIR}/local-broker") {
                    sh "${TERRAFORM_BIN} init"
                    sh "${TERRAFORM_BIN} plan -out=tfplan"
                }
            }
        }

        stage('Local Broker - Apply Terraform') {
            steps {
                dir("${REPO_DIR}/local-broker") {
                    sh "${TERRAFORM_BIN} apply -auto-approve tfplan"
                }
            }
        }

        stage('Trigger Cloud Broker Demo Commit') {
            steps {
                dir("${REPO_DIR}") {
                    // Make a dummy empty commit to trigger cloud broker stage
                    sh 'git commit --allow-empty -m "Trigger Cloud Broker after Local Broker"'
                    sh 'git push origin main'
                }
            }
        }

        stage('Cloud Broker - Init Terraform') {
            steps {
                dir("${REPO_DIR}/cloud-broker") {
                    sh """
                        export SOLACE_USERNAME=${SOLACE_CLOUD_CREDS_USR}
                        export SOLACE_PASSWORD=${SOLACE_CLOUD_CREDS_PSW}
                        ${TERRAFORM_BIN} init
                        ${TERRAFORM_BIN} plan -out=tfplan
                    """
                }
            }
        }

        stage('Cloud Broker - Apply Terraform') {
            steps {
                dir("${REPO_DIR}/cloud-broker") {
                    sh """
                        export SOLACE_USERNAME=${SOLACE_CLOUD_CREDS_USR}
                        export SOLACE_PASSWORD=${SOLACE_CLOUD_CREDS_PSW}
                        ${TERRAFORM_BIN} apply -auto-approve tfplan
                    """
                }
            }
        }
    }

    post {
        success { echo '✅ All brokers provisioned successfully!' }
        failure { echo '❌ Pipeline failed. Check logs for errors.' }
    }
}

