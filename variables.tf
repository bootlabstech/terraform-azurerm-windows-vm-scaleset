variable "location" {
  type = string

}
variable "resource_group_name" {
  type = string

}
variable "admin_password" {
  type = string

}
variable "admin_username" {
  type = string

}
variable "no_of_instances" {
  type = string

}
variable "sku" {
  type = string

}
variable "ip_name" {
  type = string
  default = "internal"

}
variable "name" {
  type = string

}
variable "subnet_id" {
  type = string

}
variable "caching" {
  type = string
  default = "ReadWrite"

}
variable "storage_account_type" {
  type = string
  default = "Standard_LRS"

}
variable "disk_size_gb" {
  type = string

}

variable "source_image_id" {
  type    = string
  default = "/subscriptions/29c1919d-1602-46ca-b8eb-3bb0433f31fd/resourceGroups/rsg-dev-golden-image-ci-01/providers/Microsoft.Compute/galleries/windowgolden/images/window-image-golden/versions/20.11.2024"

}
variable "license_type" {
  type = string

}

# nsg
# azurerm_network_security_rule
variable "nsg_rules" {
  type = map(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_address_prefix      = string
    source_port_range          = string
    destination_address_prefix = string
    destination_port_range     = string
  }))
  default = {
    "https" = {
      access                     = "Allow"
      destination_address_prefix = "*"
      destination_port_range     = "443"
      direction                  = "Inbound"
      name                       = "allow-https"
      priority                   = 100
      protocol                   = "Tcp"
      source_address_prefix      = "*"
      source_port_range          = "*"
    }
  }
}