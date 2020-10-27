# connect to your account 
Connect-AzAccount

# voer de namen in: 1- Resource Group, 2- Location, 3- VM name 
$resource_group = "Create_RG"
$location = "westeurope"
$VM_Name = "Nieuwe_VM" #maake een nieuwe 

# maakt een nieuwe gebruikersenam en wachtwoord
$userpassword = "Mysupersecurepassword"
$password = ConvertTo-SecureString $userpassword -AsPlainText -Force
$credlogin = New-Object System.Management.Automation.PSCredential ('userName', $password)

#maakt een nieuwe RG
New-AzResourceGroup -Name $resource_group -Location $location

#maakt een nieuwe Sub-network
$subnet = New-AzVirtualNetworkSubnetConfig -name mysubnet -AddressPrefix 192.168.1.0/24

#maakt een nieuwe VNet
$vnet = New-AzVirtualNetwork -ResourceGroupName $resource_group -Location $location -name myvnet  -AddressPrefix  192.168.1.0/16 -Subnet $subnet

#maakt een nieuwe openbaar IP en specifieer een DNS 
$pip = New-AzPublicIpAddress -ResourceGroupName $resource_group -Location $location -Name "mypublicdns$(get-random)" -AllocationMethod Static -IdleTimeoutInMinutes 4

#maakt een regel voor de inkomende networkbeveilligingsgroup port 22
$nsgRuleSSH = New-AzNetworkSecurityRuleConfig -Name myNetworkSecurityGroupRuleSSH  -Protocol Tcp `
  -Direction Inbound -Priority 1000 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * `
  -DestinationPortRange 22 -Access Allow

#maakt een nieuwe networkbeveilligingsgroup 
$nsg= New-AzNetworkSecurityGroup -ResourceGroupName $resource_group -Location $location -Name myNetworkSecurityGroup -SecurityRules $nsgRuleSSH

# maakt een NIC en associeren met de openbaar IP en NIC
$nic = New-AzNetworkInterface -name mynic -ResourceGroupName $resource_group -Location $location -SubnetId $vnet.$subnet[0].id -PublicIpAddressId $pip.Id -NetworkSecurityGroupId $nsg.Id

# maakt een nieuwe VM
$vmconfig= New-AzVMConfig -VMName $VM_Name -VMSize Standard_D1 | Set-AzVMOperatingSystem -Linux -ComputerName $vmName -Credential $cred -DisablePasswordAuthentication | set-AzVMSourceImage -PublisherName Canonical -Offer UbuntuServer -Skus 14.04.2-LTS -Version latest | Add-AzVMNetworkInterface -Id $nic.Id

# Configure SSH Keys
$sshPublicKey = Get-Content "$env:USERPROFILE\.ssh\id_rsa.pub"
Add-AzVMSshPublicKey -VM $vmconfig -KeyData $sshPublicKey -Path "/home/azureuser/.ssh/authorized_keys"

# Create a virtual machine
New-AzVM -ResourceGroupName $resourceGroup -Location $location -VM $vmConfig
