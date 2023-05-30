node{

    stage('Code Check-Out'){
        git 'https://github.com/pavankasiboina/Medicure-proj.git'
    }

    stage('Code Build'){
        sh 'mvn clean package'
    }

    stage('Building Docker Image'){
        sh 'docker build -t pavankasiboina/medicure:3.0 .'
    }

    stage('pushing image to Docker-Hub'){
        withCredentials([string(credentialsId: 'dockerhubcred', variable: 'dockercred')]) {
        sh "docker login -u pavankasiboina -p ${dockercred}"
        sh 'docker push pavankasiboina/medicure:3.0'
         }
    }
    
    stage('Provisioning Kubernetes Server'){
        
        withCredentials([[
            $class: 'AmazonWebServicesCredentialsBinding',
            credentialsId: 'aws-jenkins-cred',
            accessKeyVariable: 'AWS_ACCESS_KEY_ID',
            secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]){
        sh 'terraform init'
        sh 'terraform validate'
        sh 'terraform plan'
        sh 'terraform apply --auto-approve'
        }
    }
    
    stage('To set-up Kubernetes Cluster'){
        ansiblePlaybook become: true, credentialsId: 'ssh-key-ansible', disableHostKeyChecking: true, installation: 'Ansible', inventory: 'hosts', playbook: 'kubernetes-config.yml'
        
    }
    
    stage('Deploying medicure on Test-Env in kube-cluster'){
        ansiblePlaybook become: true, credentialsId: 'ssh-key-ansible', disableHostKeyChecking: true, installation: 'Ansible', inventory: 'hosts', playbook: 'test-config.yml'
        
    }
    stage('Running runnable jar'){
        sh 'java -jar medicure-runnable.jar'
    }

    stage('Deploying medicure on Prod-Env in kube-cluster'){
        ansiblePlaybook become: true, credentialsId: 'ssh-key-ansible', disableHostKeyChecking: true, installation: 'Ansible', inventory: 'hosts', playbook: 'prod-config.yml'
        
    }
    
    

}