locals {

  vnet_resource_group_name  = var.create_virtual_network_resource_group ? azurerm_resource_group.vnet_rg[0].name : var.vnet_resource_group_name
  subnet_id                 = var.create_virtual_network ? azurerm_subnet.subnet[0].id : data.azurerm_subnet.subnet[0].id
  win_ip_address            = var.create_public_access ? azurerm_windows_virtual_machine.winvm.*.public_ip_address[0] : azurerm_windows_virtual_machine.winvm.private_ip_address
  linux_ip_address          = var.create_public_access ? azurerm_linux_virtual_machine.linuxvm.*.public_ip_address[0] : azurerm_linux_virtual_machine.linuxvm.private_ip_address
  ssh_source_address_prefix = var.mgmt_ssh_source_address_prefix == "" ? data.http.ifconfig.body : var.mgmt_ssh_source_address_prefix
  rdp_source_address_prefix = var.mgmt_rdp_source_address_prefix == "" ? data.http.ifconfig.body : var.mgmt_rdp_source_address_prefix
  win_check                 = data.external.os.result.os == "Windows" ? 1 : 0
  source_image_references = [
    {
      "key" : "RedHat",
      "publisher" : "RedHat",
      "offer" : "RHEL"
      "sku" : "8.2"
      "version" : "latest"
    },
    {
      "key" : "Ubuntu",
      "publisher" : "canonical",
      "offer" : "0001-com-ubuntu-server-focal"
      "sku" : "20_04-lts"
      "version" : "latest"
    }
  ]
}