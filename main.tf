resource "azurerm_windows_virtual_machine_scale_set" "windowsscaleset" {

  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  admin_password      = random_password.password.result
  admin_username      = var.admin_username
  instances           = var.no_of_instances
  sku                 = var.sku
  secure_boot_enabled = true
  license_type        = var.license_type
  source_image_id     = var.source_image_id
  depends_on          = [azurerm_network_security_rule.nsg_rules]

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }

  network_interface {
    name                      = var.ip_name
    primary                   = true
    network_security_group_id = azurerm_network_security_group.nsg.id
    ip_configuration {
      name      = var.ip_name
      subnet_id = var.subnet_id
    }

  }
  identity {
    type = "SystemAssigned"
  }

  os_disk {

    caching              = var.caching
    storage_account_type = var.storage_account_type
    disk_size_gb         = var.disk_size_gb

  }
}

resource "azurerm_network_security_group" "nsg" {
  name                = "${var.name}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  lifecycle {
    ignore_changes = [
      tags,
    ]
  }

}


# Creates Network Security Group Default Rules for Virtual Machine
resource "azurerm_network_security_rule" "nsg_rules" {
  for_each                    = var.nsg_rules
  name                        = each.value.name
  priority                    = each.value.priority
  direction                   = each.value.direction
  access                      = each.value.access
  protocol                    = each.value.protocol
  source_address_prefix       = each.value.source_address_prefix
  source_port_range           = each.value.source_port_range
  destination_address_prefix  = each.value.destination_address_prefix
  destination_port_range      = each.value.destination_port_range
  network_security_group_name = azurerm_network_security_group.nsg.name
  resource_group_name         = var.resource_group_name
  depends_on                  = [azurerm_network_security_group.nsg]
}

# Extention for startup ELK script
resource "azurerm_virtual_machine_scale_set_extension" "example" {
  name                         = "${var.name}-s1agent"
  virtual_machine_scale_set_id = azurerm_windows_virtual_machine_scale_set.windowsscaleset.id
  publisher                    = "Microsoft.Compute"
  type                         = "CustomScriptExtension"
  type_handler_version         = "1.10"

  settings   = <<SETTINGS
    {
      "fileUris": ["https://sharedsaelk.blob.core.windows.net/s1-data/s1-agent.ps1"],
      "commandToExecute": "powershell -ExecutionPolicy Bypass -File s1-agent.ps1" 
    }
SETTINGS
  depends_on = [azurerm_windows_virtual_machine_scale_set.windowsscaleset]
}
# Getting existing Keyvault name to store credentials as secrets
data "azurerm_key_vault" "key_vault" {
  name                = var.keyvault_name
  resource_group_name = var.resource_group_name
}

# Creates a random string password for vm default user
resource "random_password" "password" {
  length      = 12
  lower       = true
  min_lower   = 6
  min_numeric = 2
  min_special = 2
  min_upper   = 2
  numeric     = true
  special     = true
  upper       = true

}
# Creates a secret to store DB credentials 
resource "azurerm_key_vault_secret" "vm_password" {
  name         = "${var.name}-vmpwd"
  value        = random_password.password.result
  key_vault_id = data.azurerm_key_vault.key_vault.id

  depends_on = [ azurerm_windows_virtual_machine_scale_set.windowsscaleset ]
}