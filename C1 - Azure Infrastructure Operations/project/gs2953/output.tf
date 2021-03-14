output "packer_image" {
    value = data.azurerm_image.packer-img.id
}

output "azurerm_public_ip" {
  value = azurerm_public_ip.udacityProject1.ip_address
}
