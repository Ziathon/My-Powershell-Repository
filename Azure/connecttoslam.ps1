Select-AzureRmSubscription -Subscription  'cc0034f0-af9e-4f49-ab20-8e06417e5420' -TenantId 'a1cfe44a-682e-4a95-8e72-d03b9b5887aa'

New-AzurermRoleDefinition -InputFile "C:\Powershell Scripts\Azure\RBAC Role.json"