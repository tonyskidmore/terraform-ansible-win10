locals {

  vnet_resource_group_name = var.create_virtual_network_resource_group ? azurerm_resource_group.vnet_rg[0].name : var.vnet_resource_group_name
  subnet_id                = var.create_virtual_network ? azurerm_subnet.subnet[0].id : data.azurerm_subnet.subnet[0].id
  win_ip_address           = var.create_public_access ? azurerm_windows_virtual_machine.winvm.*.public_ip_address[0] : azurerm_windows_virtual_machine.winvm.private_ip_address
  linux_ip_address         = var.create_public_access ? azurerm_linux_virtual_machine.linuxvm.*.public_ip_address[0] : azurerm_linux_virtual_machine.linuxvm.private_ip_address

}