# terraform-ansible-win10
## Terraform Ansible and Windows 10 Development

### Overview

The purpose of this repository is to highlight a few interesting topics in regards to Azure, Terraform, Ansible and a few general development areas, namely:

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


### Prerequisites

* A Windows system with Terraform CLI installed (tested with Windows 10 21H1 / Terraform v1.0.11 )
* A valid Azure subscription
* Permissions in the subscription to create the required resources
* SSH executable (to establish SSH connection to the Ansible host)
* [Terraform Authenticated to Azure](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs#authenticating-to-azure)
* Able to run PowerShell scripts (if running on Windows)

````bash

terraform apply -var="mgmt_source_address_prefix=80.193.188.37"

````

````bash

git clone https://github.com/tonyskidmore/terraform-ansible-win10.git
cd terraform-ansible-win10
terraform init
terraform plan -out tfplan
terraform apply tfplan

````

### Useful References
Terraform [Get Started - Azure](https://learn.hashicorp.com/collections/terraform/azure-get-started)  
[Terraform with Azure](https://docs.microsoft.com/en-us/azure/developer/terraform/overview)  
[Terraform on Azure documentation](https://docs.microsoft.com/en-us/azure/developer/terraform/)  
