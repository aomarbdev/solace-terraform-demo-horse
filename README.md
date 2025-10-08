# 🐎 Solace Terraform Jenkins Demo – "Horse"

This repository showcases how to **provision and destroy Solace PubSub+ brokers** (local and cloud) using **Terraform**, orchestrated by **Jenkins**, and version-controlled with **Git**.

---

## 🚀 Overview

This demo automates the full lifecycle of Solace brokers:

- ✅ **Local Broker** provisioning with Terraform  
- ☁️ **Cloud Broker** provisioning via Solace Cloud API  
- ⚙️ **CI/CD automation** using Jenkins pipelines  
- 🔁 Git integration for full reproducibility and traceability

---

## 🧩 Repository Structure

<img width="284" height="337" alt="Capture d’écran 2025-10-08 à 12 30 17" src="https://github.com/user-attachments/assets/68dd5973-d39c-497d-ab1a-d4b5a47cb584" />


---

## ⚙️ Prerequisites

Before using this demo, ensure you have the following:

| Tool | Version | Installation |
|------|----------|---------------|
| **Terraform** | ≥ 1.2.0 | [Download Terraform](https://developer.hashicorp.com/terraform/downloads) |
| **Jenkins** | Latest LTS | [Install Jenkins](https://www.jenkins.io/download/) |
| **Git** | Latest | [Install Git](https://git-scm.com/downloads) |
| **Solace Cloud Account** | - | [Sign up here](https://console.solace.cloud/login) |

> 🧠 Tip: Terraform and Jenkins should both be accessible from your `$PATH`.

---

## 🔧 Configuration

### 1. Solace Credentials

In Jenkins, go to:  
**Manage Jenkins → Credentials → System → Global credentials (unrestricted)**

Add:
- `SOLACE_CLOUD_CREDS_USER` → your Solace Cloud username  
- `SOLACE_CLOUD_CREDS_PSW` → your Solace Cloud password  

These will be used by the pipeline to authenticate Terraform against Solace Cloud.

---

### 2. Terraform Provider Setup

Each environment (local & cloud) defines its own `provider.tf`:

```hcl
terraform {
  required_providers {
    solacebroker = {
      source  = "solaceproducts/solacebroker"
      version = "1.2.0"
    }
  }
}

provider "solacebroker" {
  username = var.solace_username
  password = var.solace_password
}

Define variables in variables.tf:

variable "solace_username" {}
variable "solace_password" {}

🧱 Jenkins Pipeline

The pipeline automates Terraform commands for both environments.

Main Pipeline (Jenkinsfile)

pipeline {
    agent any

    environment {
        TERRAFORM_BIN = '/opt/homebrew/bin/terraform'
        SOLACE_CLOUD_CREDS = credentials('solace-cloud-creds')
    }

    stages {
        stage('Local Broker - Init Terraform') {
            steps {
                dir('local-broker') {
                    sh "${TERRAFORM_BIN} init"
                    sh "${TERRAFORM_BIN} plan -out=tfplan"
                }
            }
        }

        stage('Local Broker - Apply Terraform') {
            steps {
                dir('local-broker') {
                    sh "${TERRAFORM_BIN} apply -auto-approve tfplan"
                }
            }
        }

        stage('Cloud Broker - Init Terraform') {
            steps {
                dir('cloud-broker') {
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
                dir('cloud-broker') {
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
        success { echo 'All brokers provisioned successfully!' }
        failure { echo 'Pipeline failed. Check logs for errors.' }
    }
}
