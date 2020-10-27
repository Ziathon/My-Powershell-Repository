'Create Vnet

 New-AzureRmVirtualNetwork -ResourceGroupName TestRG -Name TestVNet `
 -AddressPrefix 192.168.0.0/16 -Location centralus

'Subnet

Add-AzureRmVirtualNetworkSubnetConfig -Name FrontEnd `
 -VirtualNetwork $vnet -AddressPrefix 192.168.1.0/24
