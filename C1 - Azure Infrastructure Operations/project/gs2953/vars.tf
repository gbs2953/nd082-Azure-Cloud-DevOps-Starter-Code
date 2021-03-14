variable "prefix" {
  description = "The prefix used for all resources in this example"
  type        = string

  default = "UdacityProject1"

}

variable "location" {
  description = "The Azure location where all resources in this example should be created"
  type        = string

  default = "northcentralus"

}

variable "vms_in_availability_set" {
  type        = number
  description = "Number of VMs in the set."

  default = 2
  validation {
    condition = var.vms_in_availability_set >= 2 && var.vms_in_availability_set <= 5
    error_message = "The number of VMs in the availability set must be at least 2, and no more than 5 (for cost reasons)."
  }
}

variable "vnet_address_space" {
  type        = string
  description = "Slash notation representation for virtual network"

  default = "10.0.0.0/16"
}

variable "subnet_address_space" {
  type        = string
  description = "Slash notation representation for subnet"

  default = "10.0.1.0/24"
}

variable "vm_sku" {
  type        = string
  description = "SKU for the vm size"

  default = "Standard_B1s"	// "Standard_F2"
}

variable "custom_image_name" {
  description = "The name of the Custom Image to provision this Virtual Machine from."
  type        = string

  default = "Proj1PackerImage"
}

variable "tags" {
  description = "The tags to associate with your network and subnets."
  type        = map(string)

  default = {
    git_id = "gbs2953",
    project = "Udacity DevOps Engr - Project 1"
  }
}
