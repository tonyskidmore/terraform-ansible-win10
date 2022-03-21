# terraform-ansible-win10
## Terraform Ansible and Windows 10 Development

### Overview

The purpose of this repository is to provide a base VM deployment to support some lab scenarios in regards to development and automation.

The base deployment highlights a few interesting topics in regards to Azure, Terraform, Ansible and a few general development areas, namely:

* Using Terraform to create Windows and Linux VMs
* Using the Azure [Custom Script Extension for Windows](https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-windows) to bootstrap a Windows node for Ansible access
* Using [cloud-init](https://cloud-init.io/) to bootstrap an Azure Linux VM (with Ansible in this case)
* Using Ansible for Windows configuration management
* Using Ansible for Linux configuration management
* Configuring a Windows 10 VM for Terraform and Ansible development, also including:  
    * [VSCode](https://code.visualstudio.com/) and extensions
    * Azure CLI
    * PowerShell Core
    * (Optionally) automated cloning of git repos at deployment time
* Using [Chocolatey](https://chocolatey.org/) with Windows via Ansible
* Windows Subsystem for Linux (installed and configured with Ansible)
* Isolated Python environments with [pipx](https://pypa.github.io/pipx/)
* Shift-left development with [pre-commit](https://pre-commit.com/)

Supporting the following scenarios:

| Scenario                         | Default deployment | Description                                                             |
|----------------------------------|--------------------|-------------------------------------------------------------------------|
| Windows Azure development system |  yes               | Create a Windows 10 Azure development system e.g. Terraform and Ansible |
### Prerequisites

The ideal system to run this on would be a Windows 10 system with all the prerequisites installed.  This will allow for the automatic creation of both the `ansible_ssh.cmd` and the `win_vm.rdp` file that makes it easy to connect to the deployed Linux and Windows VMs.

* A system with Terraform CLI installed and the Azure CLI (tested with Windows 10 21H1 / Terraform v1.0.11 )
* A valid Azure subscription
* Permissions in the subscription to create the required resources
* SSH executable (to establish SSH connection to the Ansible host)
* [Terraform Authenticated to Azure](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs#authenticating-to-azure)
* Able to run PowerShell scripts (if running on Windows)
* When running `terraform destroy` the Windows VM should be powered on


### Deployment

Basic deployment from a Windows 10 system after prerequisites are in place.

````powershell

git clone https://github.com/tonyskidmore/terraform-ansible-win10.git
cd terraform-ansible-win10

# check that you are connected to the correct subscription
az account show

terraform init
terraform plan -out tfplan
terraform apply tfplan

# connect to the deployed Linux VM
./ansible_ssh.cmd

# after cloud-init has completed and files appear in $HOME
# view cloud-init status by:
# tail -f /var/log/cloud-init-output.log
ansible-playbook win_dev.yml

# when done from the original command line location
terraform destroy -auto-approve

````

This can also be run from Azure Cloud Shell (https://shell.azure.com), which will allow access to the Linux VM but will not create the RDP file for Windows access.

````bash

git clone https://github.com/tonyskidmore/terraform-ansible-win10.git
cd terraform-ansible-win10
# check that you are connected to the correct subscription
az account show
terraform init
# https://ipinfo.io/ip to get the external IP of the Windows system you will be connecting
# to the Windows VM from and enter below
terraform plan -var="mgmt_rdp_source_address_prefix=xxx.xxx.xxx.xxx" -out tfplan
terraform apply tfplan
# make a note of the output of "winvm_public_ip" to use for RDP from your windows system

# connect to the deployed Linux VM
./ansible_ssh.cmd
# after cloud-init has completed and files appear in $HOME
# view cloud-init status by:
# tail -f /var/log/cloud-init-output.log

# Use Ansible to configure the Windows 10 VM as a development box
ansible-playbook win_dev.yml

# connect via RDP to the deployed Windows 10 VM using the win_vm_admin_username and win_vm_admin_password credentials

# when done from the original command line location
terraform destroy -auto-approve

````

Without Windows development system:

````bash

terraform plan -var "win_vm_deploy=0" -out tfplan

````

### Useful References
Terraform [Get Started - Azure](https://learn.hashicorp.com/collections/terraform/azure-get-started)  
[Terraform with Azure](https://docs.microsoft.com/en-us/azure/developer/terraform/overview)  
[Terraform on Azure documentation](https://docs.microsoft.com/en-us/azure/developer/terraform/)  
