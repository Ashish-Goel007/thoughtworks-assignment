echo "Creating Infra from terraform"
terraform init
terraform plan -out prod.plan
terraform apply prod.plan

echo "Run Ansible Playbook to deploy mediaWiki"
ansible-playbook playbook.yaml -i inventory.txt