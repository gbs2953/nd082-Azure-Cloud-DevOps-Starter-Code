# Azure Infrastructure Operations Project: Deploying a scalable IaaS web server in Azure

### Introduction
This project allows the user to:
    1) Build a custom image using the included Packer template.
    2) Deploy Azure infrastructure using the included Terraform template which
         deploys a website with a load balancer running on virtual machines
         using the above custom Packer image.

### Getting Started
1. Clone this repository

2. Edit the vars.tf file to check the following variable values
     and modify as appropriate.
       1) "prefix"
       2) "location"
       3) "vms_in_availability_set"
       4) "vnet_address_space"
       5) "subnet_address_space"
       6) "vm_sku"
       7) "custom_image_name"
       8) "tags"

### Dependencies
1. Create an [Azure Account](https://portal.azure.com) 
2. Install the [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
3. Install [Packer](https://www.packer.io/downloads)
4. Install [Terraform](https://www.terraform.io/downloads.html)

### Instructions
1. Create a Service Principal for use in the Azure Command Line Interface (CLI)
       as well as authentication
       for Packer and Terraform/Azure Resource Manager.
  a. Set environment variables as follows:
    - ARM_CLIENT_ID=<user/name from "az account list" cli output>
    - ARM_CLIENT_SECRET=<password output from the Service Principal create>
    - ARM_TENANT_ID=<tenantId from "az account list" cli output>
    - ARM_SUBSCRIPTION_ID=<Subscription ID from Azure Portal>
2. Create necessary policy definition to deny the creation of resources that
    do not have associated tags.
3. Create an Azure Resource Group
    - This resource group will contain the Packer image and all resources created with the Terraform template.
    - The name must match the value in the Packer template in the next step and
      begin with the value of "prefix" in the vars.tf file in step 5,
      followed by '-RG'.
4. Create custom image using Packer ("packer build proj1packer.json").
5. Customize variables in vars.tf file.
    - "prefix" variable is used as a prefix to all resources created
      (for example, the Resource group is named using the value of "prefix",
      followed by "-RG".  Other resources also begin with the prefix value.)
      "prefix" is defaulted to "UdacityProject1"
    - "location" is the Microsoft Azure region of the resources created.
      "location" is defaulted to "northcentralus"
    - "vms_in_availability_set" is the number of virtual machines in the
       availability set (between 2 and 5).  The default value is 2.
    - "custom_image_name" is the name of the Packer image created in step 4.
       This value must match the "managed_image_name" in the proj1packer.json
       Packer template used in step 4.
      "managed_image_name" has a default value of "Proj1PackerImage".
    - "tags" is the value of the tags that are associated with each resource
       that supports tags using the Azure Resource Manager (ARM).
      "tags" defaults to 'project = "Udacity DevOps Engr - Project 1"'
        + sets an 'author' tag to my name.

### Outputs
=================================================
- Output of terraform apply:
=================================================
Outputs:

azurerm_public_ip = "52.162.179.219"
packer_image = "/subscriptions/aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee/resourceGroups/UdacityProject1-RG/providers/Microsoft.Compute/images/Proj1PackerImage"[0m
=================================================
- Output of packer build CLI command (Subscription ID altered):
(Subscription ID represented as: "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee")
=================================================
[1;32mazure-arm: output will be in this color.[0m

[1;32m==> azure-arm: Running builder ...[0m
[1;32m==> azure-arm: Getting tokens using client secret[0m
[1;32m==> azure-arm: Getting tokens using client secret[0m
[0;32m    azure-arm: Creating Azure Resource Manager (ARM) client ...[0m
[1;32m==> azure-arm: WARNING: Zone resiliency may not be supported in North Central US, checkout the docs at https://docs.microsoft.com/en-us/azure/availability-zones/[0m
[1;32m==> azure-arm: Creating resource group ...[0m
[1;32m==> azure-arm:  -> ResourceGroupName : 'pkr-Resource-Group-xe2fqkp75s'[0m
[1;32m==> azure-arm:  -> Location          : 'North Central US'[0m
[1;32m==> azure-arm:  -> Tags              :[0m
[1;32m==> azure-arm:  ->> usage : project1[0m
[1;32m==> azure-arm: Validating deployment template ...[0m
[1;32m==> azure-arm:  -> ResourceGroupName : 'pkr-Resource-Group-xe2fqkp75s'[0m
[1;32m==> azure-arm:  -> DeploymentName    : 'pkrdpxe2fqkp75s'[0m
[1;32m==> azure-arm: Deploying deployment template ...[0m
[1;32m==> azure-arm:  -> ResourceGroupName : 'pkr-Resource-Group-xe2fqkp75s'[0m
[1;32m==> azure-arm:  -> DeploymentName    : 'pkrdpxe2fqkp75s'[0m
[1;32m==> azure-arm:[0m
[1;32m==> azure-arm: Getting the VM's IP address ...[0m
[1;32m==> azure-arm:  -> ResourceGroupName   : 'pkr-Resource-Group-xe2fqkp75s'[0m
[1;32m==> azure-arm:  -> PublicIPAddressName : 'pkripxe2fqkp75s'[0m
[1;32m==> azure-arm:  -> NicName             : 'pkrnixe2fqkp75s'[0m
[1;32m==> azure-arm:  -> Network Connection  : 'PublicEndpoint'[0m
[1;32m==> azure-arm:  -> IP Address          : '52.237.172.47'[0m
[1;32m==> azure-arm: Waiting for SSH to become available...[0m
[1;32m==> azure-arm: Connected to SSH![0m
[1;32m==> azure-arm: Provisioning with shell script: /tmp/packer-shell201133891[0m
[1;31m==> azure-arm: + echo Hello, World![0m
[1;32m==> azure-arm: Querying the machine's properties ...[0m
[1;32m==> azure-arm:  -> ResourceGroupName : 'pkr-Resource-Group-xe2fqkp75s'[0m
[1;32m==> azure-arm:  -> ComputeName       : 'pkrvmxe2fqkp75s'[0m
[1;32m==> azure-arm:  -> Managed OS Disk   : '/subscriptions/aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee/resourceGroups/pkr-Resource-Group-xe2fqkp75s/providers/Microsoft.Compute/disks/pkrosxe2fqkp75s'[0m
[1;32m==> azure-arm: Querying the machine's additional disks properties ...[0m
[1;32m==> azure-arm:  -> ResourceGroupName : 'pkr-Resource-Group-xe2fqkp75s'[0m
[1;32m==> azure-arm:  -> ComputeName       : 'pkrvmxe2fqkp75s'[0m
[1;32m==> azure-arm: Powering off machine ...[0m
[1;32m==> azure-arm:  -> ResourceGroupName : 'pkr-Resource-Group-xe2fqkp75s'[0m
[1;32m==> azure-arm:  -> ComputeName       : 'pkrvmxe2fqkp75s'[0m
[1;32m==> azure-arm: Capturing image ...[0m
[1;32m==> azure-arm:  -> Compute ResourceGroupName : 'pkr-Resource-Group-xe2fqkp75s'[0m
[1;32m==> azure-arm:  -> Compute Name              : 'pkrvmxe2fqkp75s'[0m
[1;32m==> azure-arm:  -> Compute Location          : 'North Central US'[0m
[1;32m==> azure-arm:  -> Image ResourceGroupName   : 'UdacityProject1-RG'[0m
[1;32m==> azure-arm:  -> Image Name                : 'Proj1PackerImage'[0m
[1;32m==> azure-arm:  -> Image Location            : 'North Central US'[0m
[1;32m==> azure-arm: Removing the created Deployment object: 'pkrdpxe2fqkp75s'[0m
[1;32m==> azure-arm: 
==> azure-arm: Cleanup requested, deleting resource group ...[0m
[1;32m==> azure-arm: Resource group has been deleted.[0m
[1;32mBuild 'azure-arm' finished after 5 minutes 53 seconds.[0m

==> Wait completed after 5 minutes 53 seconds

==> Builds finished. The artifacts of successful builds are:
--> azure-arm: Azure.ResourceManagement.VMImage:

OSType: Linux
ManagedImageResourceGroupName: UdacityProject1-RG
ManagedImageName: Proj1PackerImage
ManagedImageId: /subscriptions/aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee/resourceGroups/UdacityProject1-RG/providers/Microsoft.Compute/images/Proj1PackerImage
ManagedImageLocation: North Central US

=================================================
