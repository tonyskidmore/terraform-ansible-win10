output "azurerm_client_config" {
  value       = data.azurerm_client_config.current
  description = "Azure client configuration"
}

output "my_ip_address" {
  value       = data.http.ifconfig.body
  description = "Source IP address from online service"
}

output "winvm_private_ip" {
  value       = try(azurerm_windows_virtual_machine.winvm[0].private_ip_address, null)
  description = "Windows VM private IP address"
}

output "linuxvm_private_ip" {
  value       = azurerm_linux_virtual_machine.linuxvm.private_ip_address
  description = "Linux VM private IP address"
}

output "winvm_public_ip" {
  value       = try(azurerm_windows_virtual_machine.winvm.*.public_ip_address[0], null)
  description = "Windows VM public IP address"
}

output "linuxvm_public_ip" {
  value       = azurerm_linux_virtual_machine.linuxvm.*.public_ip_address[0]
  description = "Linux VM public IP address"
}

output "detected_os" {
  value       = data.external.os.result.os
  description = "Detected OS"
}

output "next_step" {
  value       = "./ansible_ssh.cmd"
  description = "Next command to run"
}
