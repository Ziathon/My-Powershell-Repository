# Script:    MailboxStats.ps1 
# Purpose:    Get some statistics for every mailbox 
# Author:    Nuno Mota 
# Date:        Feb 2009 
# Downloaded Version:  April 2015 
# Latest version: Jan 2020 (Alberto Nunes): Remove values related with DB and MBX Limits
 
 
# Incorporate this into ForEach to make it more efficient if there are too many mailboxes 
$mbxs = Get-Mailbox -ResultSize Unlimited -Filter {RecipientTypeDetails -ne "DiscoveryMailbox"} | Where {$_.Alias -notlike "extest_*"} | Select Identity, PrimarySmtpAddress, EmailAddresses, EmailAddressPolicyEnabled, OrganizationalUnit, Database 
 
[Array] $mbxCol = @() 
[Int] $intCount = $mbxs.Count 
[Int] $intSucceeded = 0 
 
ForEach ($mbx in $mbxs) { 
    Write-Progress -Activity "Checking $intCount Mailboxes" -Status "Mailboxes Successfully Processed: $intSucceeded" 
 
    # Get Mailbox statistics 
    $mbxStats = Get-MailboxStatistics $mbx.Identity | Select DisplayName, LastLogonTime, DatabaseName, ItemCount, TotalItemSize
 
    $mbxSize = [Math]::Round($mbxStats.TotalItemSize.Value.ToKB(), 0) 
    # Get the statistics for Sent and Deleted Items 
    $mbxSentStats = Get-MailboxFolderStatistics $mbx.Identity | Where {$_.FolderPath -eq "/Sent Items"} | Select ItemsInFolderAndSubfolders, @{name="SentItemsSize";expression={$_.FolderAndSubfolderSize.ToKB()}} 
    $mbxDeletedStats = Get-MailboxFolderStatistics $mbx.Identity | Where {$_.FolderPath -eq "/Deleted Items"} | Select ItemsInFolderAndSubfolders, @{name="DeletedItemsSize";expression={$_.FolderAndSubfolderSize.ToKB()}} 
    $mbxJunkStats = Get-MailboxFolderStatistics $mbx.Identity | Where {$_.FolderPath -eq "/Junk Email"} | Select ItemsInFolderAndSubfolders 
 
    $mbxObj = New-Object PSObject -Property @{ 
        "Display Name" = $mbxStats.DisplayName 
        "Last Logon Time" = $mbxStats.LastLogonTime 
        "Logon (7d)"    = If ($mbxStats.LastLogonTime) { If (((Get-Date) - $mbxStats.LastLogonTime).Days -le 7) {"Yes"} Else {""} } Else {""} 
        "Logon (30d)"    = If ($mbxStats.LastLogonTime) { If (((Get-Date) - $mbxStats.LastLogonTime).Days -le 30) {"Yes"} Else {""} } Else {""} 
        "Logon Never"    = If (!$mbxStats.LastLogonTime) {"Yes"} Else {""} 
        "Mailbox Size (KB)" = $mbxSize 
        "Item Count" = $mbxStats.ItemCount 
        "Total Sent Items" = $mbxSentStats.ItemsInFolderAndSubfolders 
        "Sent Items Size (KB)" = [Math]::Round($mbxSentStats.SentItemsSize, 0) 
        "Total Deleted Items" = $mbxDeletedStats.ItemsInFolderAndSubfolders 
        "Deleted Items Size (KB)" = [Math]::Round($mbxDeletedStats.DeletedItemsSize, 0) 
        "Total Junk Items" = $mbxJunkStats.ItemsInFolderAndSubfolders 
        Database = $mbxStats.DatabaseName 
        "Primary Email Address" = $mbx.PrimarySmtpAddress 
        "Email Addresses" = $mbx.EmailAddresses -join ";" 
        "Email Address Policy" = $mbx.EmailAddressPolicyEnabled 
        OU = $mbx.OrganizationalUnit 
    } 
     
    $mbxCol += $mbxObj 
    $intSucceeded++ 
} 
 
#$mbxCol 
$mbxCol | Select "Display Name", "Last Logon Time", "Mailbox Size (KB)", "Item Count", "Total Sent Items", "Sent Items Size (KB)", "Total Deleted Items", "Deleted Items Size (KB)", "Total Junk Items", Database, "Primary Email Address", "Email Addresses", "Email Address Policy", "Logon (7d)", "Logon (30d)", "Logon Never", OU | Export-Csv .\"MailboxStats_$(Get-Date -f 'yyyyMMdd').csv" -NoType