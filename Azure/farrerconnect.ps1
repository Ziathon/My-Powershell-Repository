$Cred = Get-Credential
Connect-AzAccount -Credential $Credential
Select-AzSubscription -SubscriptionName Production -TenantId 74e4aa4c-4391-4886-9bcc-a1311519a485