data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "rg" {
  count    = var.create_resource_group ? 1 : 0
  name     = var.resource_group_name
  location = var.location
}

data "azurerm_resource_group" "rg" {
  count = var.create_resource_group ? 0 : 1
  name  = var.resource_group_name
}

resource "azurerm_resource_group" "vnet_rg" {
  count    = var.create_virtual_network_resource_group ? 1 : 0
  name     = var.vnet_resource_group_name
  location = var.location
}

data "azurerm_resource_group" "vnet_rg" {
  count = var.create_resource_group ? 0 : 1
  name  = var.resource_group_name
}

resource "azurerm_virtual_network" "vnet" {
  count               = var.create_virtual_network ? 1 : 0
  name                = var.vnet_name
  location            = var.create_resource_group ? azurerm_resource_group.rg[0].location : data.azurerm_resource_group.rg[0].location
  resource_group_name = var.create_resource_group ? azurerm_resource_group.rg[0].name : data.azurerm_resource_group.rg[0].name
  address_space       = var.vnet_address_space

}

resource "azurerm_subnet" "subnet" {
  count                = var.create_virtual_network ? 1 : 0
  name                 = var.subnet_name
  resource_group_name  = local.vnet_resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet[0].name
  address_prefixes     = var.subnet_address_prefix
}

data "azurerm_virtual_network" "vnet" {
  count               = var.create_virtual_network ? 0 : 1
  name                = var.vnet_name
  resource_group_name = var.vnet_resource_group_name
}

data "azurerm_subnet" "subnet" {
  count                = var.create_virtual_network ? 0 : 1
  name                 = var.subnet_name
  virtual_network_name = data.azurerm_virtual_network.vnet[0].name
  resource_group_name  = var.vnet_resource_group_name
}

data "http" "ifconfig" {
  url = "https://ifconfig.me/ip"
}

resource "azurerm_network_interface" "nic" {
  name                = "nic-${var.win_vm_name}"
  location            = azurerm_resource_group.rg[0].location
  resource_group_name = azurerm_resource_group.rg[0].name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = local.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.create_public_access ? element(azurerm_public_ip.pip.*.id, 0) : null
  }
}

resource "azurerm_public_ip" "pip" {
  count               = var.create_public_access ? 2 : 0
  name                = "vm-pip-${count.index}"
  location            = azurerm_resource_group.rg[0].location
  resource_group_name = azurerm_resource_group.rg[0].name
  allocation_method   = "Static"
}


resource "azurerm_network_security_group" "nsg" {
  count               = var.create_public_access ? 1 : 0
  name                = "allowRemoteManagement"
  location            = var.create_resource_group ? azurerm_resource_group.rg[0].location : data.azurerm_resource_group.rg[0].location
  resource_group_name = var.create_resource_group ? azurerm_resource_group.rg[0].name : data.azurerm_resource_group.rg[0].name

  security_rule {
    name                       = "allow_ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = local.ssh_source_address_prefix
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_rdp"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = local.rdp_source_address_prefix
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg_assoc" {
  count                     = var.create_public_access ? 1 : 0
  subnet_id                 = local.subnet_id
  network_security_group_id = azurerm_network_security_group.nsg[0].id
}

resource "azurerm_windows_virtual_machine" "winvm" {
  count               = var.win_vm_deploy
  name                = "vm-${var.win_vm_name}"
  resource_group_name = azurerm_resource_group.rg[0].name
  location            = azurerm_resource_group.rg[0].location
  size                = var.win_vm_size
  admin_username      = var.win_vm_admin_username
  admin_password      = var.win_vm_admin_password
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  identity {
    type = "SystemAssigned"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  # az vm image list -f "Windows-10" --all -otable
  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-10"
    sku       = "20h2-ent-g2"
    version   = "latest"
  }
}

# linux:
# publisher                  = "Microsoft.Azure.Extensions"
# type                       = "CustomScript"
resource "azurerm_virtual_machine_extension" "win_custom_script" {
  count                      = var.win_vm_deploy
  name                       = "winrm"
  virtual_machine_id         = azurerm_windows_virtual_machine.winvm[0].id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.10"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
      "fileUris": ["https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1"],
      "commandToExecute": "powershell -ExecutionPolicy Unrestricted -File ConfigureRemotingForAnsible.ps1"
    }
SETTINGS

}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "winvm" {
  virtual_machine_id = azurerm_windows_virtual_machine.winvm[0].id
  location           = azurerm_resource_group.rg[0].location
  enabled            = true

  daily_recurrence_time = "1900"
  timezone              = "UTC"

  notification_settings {
    enabled         = false
    email           = "user@domain"
    time_in_minutes = "60"
    webhook_url     = "https://sample-webhook-url.example.com"
  }
}
resource "azurerm_network_interface" "linuxnic" {
  name                = "nic-${var.linux_vm_name}"
  location            = azurerm_resource_group.rg[0].location
  resource_group_name = azurerm_resource_group.rg[0].name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = local.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.create_public_access ? element(azurerm_public_ip.pip.*.id, 1) : null
  }
}

# https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key
resource "tls_private_key" "linux_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_linux_virtual_machine" "linuxvm" {
  name                = "vm-${var.linux_vm_name}"
  resource_group_name = azurerm_resource_group.rg[0].name
  location            = azurerm_resource_group.rg[0].location
  size                = local.linux_vm_size
  admin_username      = var.linux_vm_admin_username
  custom_data = base64encode(templatefile("${path.module}/templates/ansible.tpl", {
    win_vm_ip                = try(azurerm_windows_virtual_machine.winvm[0].private_ip_address, "")
    ansible_user             = var.win_vm_admin_username
    ansible_password         = var.win_vm_admin_password
    windev_ansible_role_repo = var.windev_ansible_role_repo
    private_key_pem          = base64encode(tls_private_key.linux_ssh.private_key_pem)
    }
  ))
  network_interface_ids = [
    azurerm_network_interface.linuxnic.id,
  ]

  admin_ssh_key {
    username   = var.linux_vm_admin_username
    public_key = tls_private_key.linux_ssh.public_key_openssh
    # public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }


  dynamic "source_image_reference" {

    for_each = [local.source_image_references[index(local.source_image_references.*.key, var.linux_source_image_reference)]]
    content {
      publisher = source_image_reference.value.publisher
      offer     = source_image_reference.value.offer
      sku       = source_image_reference.value.sku
      version   = source_image_reference.value.version
    }
  }

}


resource "local_file" "ssh_priv_key" {
  filename             = pathexpand("~/.ssh/terraform_ansible_win10_pem")
  content              = tls_private_key.linux_ssh.private_key_pem
  directory_permission = "0700"
  file_permission      = "0600"
}

resource "local_file" "ansible_ssh" {
  filename = "${path.module}/ansible_ssh.cmd"
  content = templatefile("${path.module}/templates/ansible_ssh.tpl", {
    linux_vm_ip  = local.linux_ip_address
    ansible_user = var.linux_vm_admin_username
    }
  )
}

# https://aws-blog.de/2021/05/terraform-os-detection.html
data "external" "os" {
  working_dir = path.module
  program     = ["printf", "{\"os\": \"Linux\"}"]
}

resource "null_resource" "create_rdp_file" {
  count = local.win_check
  provisioner "local-exec" {
    command = "Powershell -file ${path.module}/scripts/New-RdpFile.ps1 -Path ${path.module} -FullAddress ${local.win_ip_address} -Username ${var.win_vm_admin_username} -Password ${var.win_vm_admin_password} -DesktopWidth ${var.rdp_windows_width} -DesktopHeight ${var.rdp_windows_height}"
  }

}

resource "null_resource" "destroy_rdp_file" {
  count = local.win_check
  provisioner "local-exec" {
    when    = destroy
    command = "del win_vm.rdp"
  }
}
