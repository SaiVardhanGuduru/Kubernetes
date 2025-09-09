#!/usr/bin/env bash
set -euo pipefail

# 1. Install Terraform
echo "Installing Terraform..."
terraform_version=$(curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | jq -r -M '.current_version')
curl -O "https://releases.hashicorp.com/terraform/${terraform_version}/terraform_${terraform_version}_linux_amd64.zip"
unzip -o terraform_${terraform_version}_linux_amd64.zip
mkdir -p ~/bin
mv terraform ~/bin/
export PATH=$HOME/bin:$PATH
terraform version

# 2. Setup working directory
echo "Preparing working directory..."
sudo mkdir -p /opt/eks
sudo chown cloudshell-user /opt/eks
cd /opt/eks

# 3. Clone the KodeKloud repo
if [ ! -d amazon-elastic-kubernetes-service-course ]; then
  git clone https://github.com/kodekloudhub/amazon-elastic-kubernetes-service-course
fi
cd amazon-elastic-kubernetes-service-course/eks

# 4. Check environment (optional script from repo)
if [ -f check-environment.sh ]; then
  source check-environment.sh
fi

# 5. Run Terraform
echo "Running Terraform..."
terraform init
terraform apply -auto-approve

# 6. Capture Terraform outputs
echo "Retrieving Terraform outputs..."
NodeInstanceRole=$(terraform output -raw NodeInstanceRole)
ClusterName="demo-eks"
Region="us-east-1"

echo "NodeInstanceRole: $NodeInstanceRole"

# 7. Configure kubectl
echo "Configuring kubectl..."
aws eks update-kubeconfig --region "$Region" --name "$ClusterName"

# 8. Download aws-auth configmap
curl -s -O https://s3.us-west-2.amazonaws.com/amazon-eks/cloudformation/2020-10-29/aws-auth-cm.yaml

# 9. Patch aws-auth configmap
echo "Patching aws-auth-cm.yaml with NodeInstanceRole..."
sed -i "s|<ARN of instance role (not instance profile)>|$NodeInstanceRole|g" aws-auth-cm.yaml

# 10. Apply aws-auth configmap
kubectl apply -f aws-auth-cm.yaml

# 11. Verify nodes
echo "Waiting for worker nodes to join..."
sleep 60
kubectl get nodes -o wide
