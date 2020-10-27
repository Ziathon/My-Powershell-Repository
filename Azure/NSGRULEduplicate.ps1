#name of NSG that you want to copy 
$nsgOrigin = "fac-azp-we-nsg-pms-01" 
#name new NSG  
$nsgDestination = "fac-azp-uks-nsg-pms-01" 
#Resource Group Name of source NSG 
$rgName = "fac-azp-we-rg-pms-01" 
#Resource Group Name when you want the new NSG placed 
$rgNameDest = "fac-azp-uks-rg-pms-01" 
 
$nsg = Get-AzNetworkSecurityGroup -Name $nsgOrigin -ResourceGroupName $rgName 
$nsgRules = Get-AzNetworkSecurityRuleConfig -NetworkSecurityGroup $nsg 
$newNsg = Get-AzNetworkSecurityGroup -name $nsgDestination -ResourceGroupName $rgNameDest 
foreach ($nsgRule in $nsgRules) { 
    Add-AzNetworkSecurityRuleConfig -NetworkSecurityGroup $newNsg -Name $nsgRule.Name -Protocol $nsgRule.Protocol -SourcePortRange $nsgRule.SourcePortRange -DestinationPortRange $nsgRule.DestinationPortRange -SourceAddressPrefix $nsgRule.SourceAddressPrefix -DestinationAddressPrefix $nsgRule.DestinationAddressPrefix -Priority $nsgRule.Priority -Direction $nsgRule.Direction -Access $nsgRule.Access 
} 
Set-AzNetworkSecurityGroup -NetworkSecurityGroup $newNsg 