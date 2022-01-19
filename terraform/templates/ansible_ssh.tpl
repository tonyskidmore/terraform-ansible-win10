ssh -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" ${ansible_user}@${linux_vm_ip} -i ~/.ssh/terraform_ansible_win10_pem
