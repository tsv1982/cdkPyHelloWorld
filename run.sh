#!/bin/bash

#Install OS UPdate
sudo yum update -y
sudo yum check-update

#Install Docker
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install docker
sudo systemctl start docker
sudo systemctl enable docker

#Install Kubectl
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
sudo yum install -y kubectl

#AWS cli installation
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

#aws-iam-authenticator installation
curl -o aws-iam-authenticator https://s3.us-west-2.amazonaws.com/amazon-eks/1.21.2/2021-07-05/bin/linux/amd64/aws-iam-authenticator
chmod +x ./aws-iam-authenticator
mkdir -p $HOME/bin && cp ./aws-iam-authenticator $HOME/bin/aws-iam-authenticator && export PATH=$PATH:$HOME/bin
echo 'export PATH=$PATH:$HOME/bin' >> ~/.bashrc

#Install Terraform
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
sudo yum -y install terraform

#Install Git
yum install git -y

#Git Clone the repo
git clone https://github.com/git-ranjan/helloworlddb-docker.git

#docker Image creation
cd helloworlddb-docker
docker build --tag ranjan/helloworlddb-docker .
docker run -d ranjan/helloworlddb-docker

#Install Helm in localsystem
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 > get_helm.sh
chmod 700 get_helm.sh
./get_helm.sh

#Prod
cd ./prod
terraform init
terraform validate
terraform apply --auto-approve
#Connect Kube-cli Tool to prod
terraform output kubeconfig > ~/.kube/config
aws eks --region us-east-1 update-kubeconfig --name prod
#get config details of authentication with AWS prod & deploy the config map deployment
terraform output config-map-aws-auth > config-map-aws-auth.yaml
kubectl apply -f config-map-aws-auth.yaml
#Deploy the Python Microservice in EKS cluster prod
kubectl create -f - <<EOF
apiVersion: batch/v1
kind: Job
metadata:
  name: hello-world
spec:
  template:
    metadata:
      name: hello-world-pod
    spec:
      containers:
      - name: hello-world
        image: ranjan/helloworlddb-docker
        imagePullPolicy: Never
      restartPolicy: OnFailure
      automountServiceAccountToken: false
      containers:
      - name: python
        image: docker.io/python
      restartPolicy: OnFailure
EOF
#Deploy Prometheus in the cluster
kubectl create namespace prometheus
kubectl create -f - <<EOF
kind: PersistentVolume
apiVersion: v1
metadata:
  name: pv-volume1
spec:
  storageClassName: gp2
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/mnt/pv1"
---
kind: PersistentVolume
apiVersion: v1
metadata:
  name: pv-volume2
spec:
  storageClassName: gp2
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/mnt/pv2"
EOF
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm upgrade -i prometheus prometheus-community/prometheus \
    --namespace prometheus \
    --set alertmanager.persistentVolume.storageClass="gp2",server.persistentVolume.storageClass="gp2"
kubectl --namespace=prometheus port-forward deploy/prometheus-server 9090
#STG
cd ../stg
terraform init
terraform validate
terraform apply --auto-approve
#Connect Kube-cli Tool to stg
terraform output kubeconfig > ~/.kube/config
aws eks --region us-east-1 update-kubeconfig --name prod
#get config details of authentication with AWS stg & deploy the config map deployment
terraform output config-map-aws-auth > config-map-aws-auth.yaml
kubectl apply -f config-map-aws-auth.yaml
#Deploy the Python Microservice in EKS cluster stg
kubectl create -f - <<EOF
apiVersion: batch/v1
kind: Job
metadata:
  name: hello-world
spec:
  template:
    metadata:
      name: hello-world-pod
    spec:
      containers:
      - name: hello-world
        image: ranjan/helloworlddb-docker
        imagePullPolicy: Never
      restartPolicy: OnFailure
      automountServiceAccountToken: false
      containers:
      - name: python
        image: docker.io/python
      restartPolicy: OnFailure
EOF
#Deploy Prometheus in the cluster
kubectl create namespace prometheus
kubectl create -f - <<EOF
kind: PersistentVolume
apiVersion: v1
metadata:
  name: pv-volume1
spec:
  storageClassName: gp2
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/mnt/pv1"
---
kind: PersistentVolume
apiVersion: v1
metadata:
  name: pv-volume2
spec:
  storageClassName: gp2
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/mnt/pv2"
EOF
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm upgrade -i prometheus prometheus-community/prometheus \
    --namespace prometheus \
    --set alertmanager.persistentVolume.storageClass="gp2",server.persistentVolume.storageClass="gp2"
kubectl --namespace=prometheus port-forward deploy/prometheus-server 9090

#DEV
cd ../dev
terraform init
terraform validate
terraform apply --auto-approve
#Connect Kube-cli Tool to dev
terraform output kubeconfig > ~/.kube/config
aws eks --region us-east-1 update-kubeconfig --name prod
#get config details of authentication with AWS dev & deploy the config map deployment
terraform output config-map-aws-auth > config-map-aws-auth.yaml
kubectl apply -f config-map-aws-auth.yaml
#Deploy the Python Microservice in EKS cluster dev
kubectl create -f - <<EOF
apiVersion: batch/v1
kind: Job
metadata:
  name: hello-world
spec:
  template:
    metadata:
      name: hello-world-pod
    spec:
      containers:
      - name: hello-world
        image: ranjan/helloworlddb-docker
        imagePullPolicy: Never
      restartPolicy: OnFailure
      automountServiceAccountToken: false
      containers:
      - name: python
        image: docker.io/python
      restartPolicy: OnFailure
EOF
#Deploy Prometheus in the cluster
kubectl create namespace prometheus
kubectl create -f - <<EOF
kind: PersistentVolume
apiVersion: v1
metadata:
  name: pv-volume1
spec:
  storageClassName: gp2
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/mnt/pv1"
---
kind: PersistentVolume
apiVersion: v1
metadata:
  name: pv-volume2
spec:
  storageClassName: gp2
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/mnt/pv2"
EOF
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm upgrade -i prometheus prometheus-community/prometheus \
    --namespace prometheus \
    --set alertmanager.persistentVolume.storageClass="gp2",server.persistentVolume.storageClass="gp2"
kubectl --namespace=prometheus port-forward deploy/prometheus-server 9090
