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
variable "mgmt_source_address_prefix" {
  type        = string
  description = "Source address for NSG rule to allow management access (RDP/SSH)"
  default     = ""
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
}

variable "linux_vm_name" {
  type        = string
  description = "Linux VM name"
  default     = "linux-01"
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

variable "linux_image_publisher" {
  type        = string
  description = "Linux source image reference publisher"
  default     = "RedHat"
}

variable "linux_image_offer" {
  type        = string
  description = "Linux source image reference offer"
  default     = "RHEL"
}

variable "linux_image_sku" {
  type        = string
  description = "Linux source image reference sku"
  default     = "8.2"
}

variable "linux_image_version" {
  type        = string
  description = "Linux source image reference version"
  default     = "latest"
}
