variable "location" {
  type        = string
  description = "Azure location"
  default     = "UK South"
}

variable "create_resource_group" {
  type        = bool
  description = "Flag to set whether resource group should be created or use an existing resource group data source"
  default     = true
}

variable "create_virtual_network" {
  type        = bool
  description = "Flag to set whether virtual network should be created or use an existing vnet data source"
  default     = true
}

variable "create_public_access" {
  type        = bool
  description = "Flag to set whether to create remote management network security group"
  default     = true
}

variable "create_virtual_network_resource_group" {
  type        = bool
  description = "Flag to set whether virtual network resource group should be created"
  default     = false
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name"
  default     = "rg-terraform-ansible-win10"
}

variable "vnet_resource_group_name" {
  type        = string
  description = "Azure Vnet resource group name"
  default     = "rg-terraform-ansible-win10"
}

variable "vnet_name" {
  type        = string
  description = "Azure Vnet name"
  default     = "vnet-terraform-ansible-win10"
}

variable "vnet_address_space" {
  type        = list(string)
  description = "Azure Vnet address space (if creating new vnet)"
  default     = ["192.168.0.0/16"]
}

variable "subnet_name" {
  type        = string
  description = "Azure subnet name"
  default     = "snet-terraform-ansible-win10"
}

variable "subnet_address_prefix" {
  type        = list(string)
  description = "Azure subnet address prefix (if creating new vnet)"
  default     = ["192.168.1.0/24"]
}

# defaults to automatic detection
variable "mgmt_ssh_source_address_prefix" {
  type        = string
  description = "Source address for NSG rule to allow management access (SSH)"
  default     = ""
}

# defaults to automatic detection
variable "mgmt_rdp_source_address_prefix" {
  type        = string
  description = "Source address for NSG rule to allow management access (RDP)"
  default     = ""
}

variable "win_vm_deploy" {
  type        = number
  description = "Whether to deploy the Windows 10 VM"
  default     = 1
}

variable "win_vm_name" {
  type        = string
  description = "Windows 10 VM name"
  default     = "win10-01"
}

variable "win_vm_size" {
  type        = string
  description = "Windows VM size"
  default     = "Standard_D2s_v5"
}

variable "win_vm_admin_username" {
  type        = string
  description = "Windows VM admin user"
  default     = "adminuser"
}

variable "win_vm_admin_password" {
  type        = string
  description = "Windows VM admin password"
  default     = "D3vPassw0rd1234!"
  sensitive   = true
}

variable "linux_vm_name" {
  type        = string
  description = "Linux VM name"
  default     = "linux-01"
}

variable "rdp_windows_width" {
  type        = string
  description = "Windows RDP windows width setting"
  default     = "1600"
}

variable "rdp_windows_height" {
  type        = string
  description = "Windows RDP windows height setting"
  default     = "1200"
}

variable "linux_vm_size" {
  type        = string
  description = "Linux VM size"
  default     = "Standard_B2s"
}

variable "linux_vm_admin_username" {
  type        = string
  description = "Linux VM admin user"
  default     = "adminuser"
}

variable "linux_source_image_reference" {
  type        = string
  description = "Linux source image reference"
  default     = "RedHat"
  validation {
    condition     = contains(["RedHat", "Ubuntu", "Debian"], var.linux_source_image_reference)
    error_message = "The linux_source_image_reference must be a valid value."
  }
}

variable "windev_ansible_role_repo" {
  type        = string
  description = "URL of the windev role used for configuring the Windows dev machine"
  default     = "https://github.com/tonyskidmore/ansible-role-windev.git"
}
