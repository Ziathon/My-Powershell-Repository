#ASR'd VMs must be running in order to see if NSG is in effect on them
cls
$allobjects = [System.Collections.ArrayList]@()
$vault = Get-azRecoveryServicesVault | out-gridview -outputmode single
Set-azRecoveryServicesAsrVaultContext -Vault $vault | out-null
$ReplicatedItems = Get-azRecoveryServicesAsrFabric | Get-azRecoveryServicesAsrProtectionContainer| Get-azRecoveryServicesAsrReplicationProtectedItem
"Friendlyname,RecoveryVMName,srcIP,dstIP,srcSubnet,dstSubnet,srcIPtype,dstUPtype,srcSize,dstSize,Policy,dstPIP,srcNSG,dstNSG,dstLBBEP,srcAS,dstAS" | out-file c:\temp\replitemsconfig.csv
foreach ($item in $replicateditems)
{
$itemarray = [System.Collections.ArrayList]@()

$srcvm = get-azvm -Name $item.FriendlyName
$srcvmsize = $srcvm.HardwareProfile.VmSize
if ($srcvm.AvailabilitySetReference.id -ne $null) {$srcas = ($srcvm.AvailabilitySetReference.id).split('/')[-1]} else {$srcas = $null}
$srcnicid = $item.NicDetailsList.sourcenicarmid
$srcnicname = $srcnicid.split('/')[-1]
$srcnicrg = $srcnicid.split('/')[4]
$error.clear()
$srcniceffnsgid = (Get-AzEffectiveNetworkSecurityGroup -NetworkInterfaceName $srcnicname -ResourceGroupName $srcnicrg).NetworkSecurityGroup.id
if ($error) {$srcniceffnsg = 'VM stopped'}
else { if ($srcniceffnsgid -eq $null) {$srcniceffnsg = ''}
else {$srcniceffnsg = $srcniceffnsgid.split('/')[-1]} }

$itemip1=$item.nicdetailslist.primarynicstaticipaddress
$itemip2=$item.nicdetailslist.replicanicstaticipaddress
$itemsub1 = $item.nicdetailslist.vmsubnetname
$itemsub2 = $item.nicdetailslist.recoveryvmsubnetname
$itemiptype1 = $item.nicdetailslist.ipaddresstype
$itemiptype2 = $item.nicdetailslist.recoverynicipaddresstype
if ($item.nicdetailslist.RecoveryPublicIPAddressId -ne $null) {$itempip = ($item.nicdetailslist.RecoveryPublicIPAddressId).split('/')[-1]} else {$itempip = $null}
if ($item.nicdetailslist.RecoveryNetworkSecurityGroupId -ne $null) {$itemnsg = ($item.nicdetailslist.RecoveryNetworkSecurityGroupId).split('/')[-1]} else {$itemnsg = $null}
if ($item.nicdetailslist.RecoveryLBBackendAddressPoolId -ne $null) {$itembep = ($item.nicdetailslist.RecoveryLBBackendAddressPoolId).split('/')[-1]} else {$itembep = $null}
if ($item.providerspecificdetails.RecoveryAvailabilitySet -ne $null) {$itemas = ($item.providerspecificdetails.RecoveryAvailabilitySet).split('/')[-1]} else {$itemas = $null}

$itemarray.Add($item.FriendlyName) | out-null
$itemarray.Add($item.RecoveryAzureVMName) | out-null
$itemarray.Add($itemip1) | out-null
$itemarray.Add($itemip2) | out-null
$itemarray.Add($itemsub1) | out-null
$itemarray.Add($itemsub2) | out-null
$itemarray.Add($itemiptype1) | out-null
$itemarray.Add($itemiptype2) | out-null
$itemarray.Add($srcvmsize) | out-null
$itemarray.Add($item.recoveryazurevmsize) | out-null
$itemarray.Add($item.policyfriendlyname) | out-null
$itemarray.Add($itempip) | out-null
$itemarray.Add($srcniceffnsg) | out-null 
$itemarray.Add($itemnsg) | out-null
$itemarray.Add($itembep) | out-null
$itemarray.Add($srcas) | out-null
$itemarray.Add($itemas) | out-null

$allobjects.add($itemarray) | out-null
}
foreach ($singleobject in $allobjects)
{
$singleobject[0]+","+$singleobject[1]+","+$singleobject[2]+","+$singleobject[3]+","+$singleobject[4]+","+$singleobject[5]+","+$singleobject[6]+","+$singleobject[7]+","+$singleobject[8]+","+$singleobject[9]+","+$singleobject[10]+","+$singleobject[11]+","+$singleobject[12]+","+$singleobject[13]+","+$singleobject[14]+","+$singleobject[15]+","+$singleobject[16]+","+$singleobject[17]  | out-file -append c:\temp\replitemsconfig.csv
}
