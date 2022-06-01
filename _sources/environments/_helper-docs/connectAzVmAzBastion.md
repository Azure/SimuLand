# Connect to Azure VM via Azure Bastion

## Pre-Requirements
* Azure subscription
* Azure virtual machine
    * Azure bastion set up

## Connect via Azure Bastion
1.	Browse to [Azure Portal](https://portal.azure.com/)
2.	Resource Groups > `RESOURCE GROUP` (Where you deployed your virtual machines).

![](../../images/deploy/helper_docs/connectAzVmAzBastion/2021-05-19_01_resource_group.png)

3.	Click on the Azure VM you want to connect to > Connect > Bastion.

![](../../images/deploy/helper_docs/connectAzVmAzBastion/2021-05-19_02_azure_vm.png)

4.	Select `Use Bastion`

![](../../images/deploy/helper_docs/connectAzVmAzBastion/2021-05-19_03_azure_vm_use_bastion.png)

5.	Enter Administrator or domain credentials to connect to the Azure VM.

![](../../images/deploy/helper_docs/connectAzVmAzBastion/2021-05-19_04_azure_vm_bastion.png)

6.	If this is your first time accessing an Azure VM via Azure bastion, you might have to allow or block a few browser features.

![](../../images/deploy/helper_docs/connectAzVmAzBastion/2021-05-19_05_browser_features.png)

7.	You are now ready to use your virtual machine via Azure Bastion.

![](../../images/deploy/helper_docs/connectAzVmAzBastion/2021-05-19_06_azure_vm_bastion_connected.png)
