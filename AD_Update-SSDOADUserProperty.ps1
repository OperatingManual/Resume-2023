<#
.SYNOPSIS
Updates the properties of an Active Directory user account with a new SAM account name and logs the changes to the specified event log.

.DESCRIPTION
This function updates the SAM account name, display name, given name, surname, and user principal name (UPN) of an Active Directory user account. The old and new UPNs are logged to the specified event log.

.PARAMETER NewSamAccountName
Specifies the new SAM account name for the user.

.PARAMETER OldSamAccountName
Specifies the old SAM account name of the user. If the old sAMAccountName is unknown use the new sAMAccountName for this parameter.

.PARAMETER FirstName
Specifies the first name of the user.

.PARAMETER LastName
Specifies the last name of the user.

.PARAMETER UPNSuffix
Specifies the UPN suffix to be added to the SAM account name.

.PARAMETER LogName
Specifies the name of the event log to write changes to. Default is defined in the script.

.EXAMPLE
Update-ADUserProperty -NewSamAccountName "newusername" -OldSamAccountName "oldusername" -FirstName "John" -LastName "Doe" -UPNSuffix "@domain.com" -LogName "Security"

This example updates the SAM account name, display name, given name, surname, and UPN of the "oldusername" user account to "newusername" and logs the changes to the "Security" event log.

.NOTES
Author: Tyler Tourot
Date: 6/5/2023

.LINK
Script Repository: https://github.com/OperatingManual/Resume-2023
#>
function Update-ADUserProperty {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$NewSamAccountName,

        [Parameter(Mandatory = $true)]
        [string]$OldSamAccountName,

        [Parameter(Mandatory = $true)]
        [string]$FirstName,

        [Parameter(Mandatory = $true)]
        [string]$LastName,

        [Parameter(Mandatory = $true)]
        [ValidateSet("@DOMAIN.edu", "@student.DOMAIN.edu")]
        [string]$UPNSuffix,

        [string]$LogName = "Application"
    )
    $LogSourceName = "TBD" # Must be initialized and set once. Initialization should occur during server build.
    $NewUPN = $NewSamAccountName + $UPNSuffix
    $DisplayName = $FirstName + " " + $LastName

    # Initialize logging
    $LogEntry = "$(Get-Date -Format 'yyyy/MM/dd HH:mm:ss') - Starting update for $OldSamAccountName"
    Write-EventLog -LogName $LogName -Source $LogSourceName -EventId 3000 -EntryType Information -Message $LogEntry

    try {
        # Update the user properties
        $UserProperties = @{
            EmailAddress = $NewUPN
            UserPrincipalName = $NewUPN
            Surname = $LastName
            DisplayName = $DisplayName
            GivenName = $FirstName
            Verbose = $true
        }

        Get-ADUser -Identity $NewSamAccountName
        $NewSamAccountName | Set-ADUser @UserProperties
        Get-ADUser -Identity $NewSamAccountName

        # Log the old and new UPNs
        $LogEntry = "$(Get-Date -Format 'yyyy/MM/dd HH:mm:ss') - Updated $OldSamAccountName with new properties $($UserProperties | Out-String)"
        Write-EventLog -LogName $LogName -Source $LogSourceName -EventId 3000 -EntryType Information -Message $LogEntry
    }
    catch {
        $LogEntry = "$(Get-Date -Format 'yyyy/MM/dd HH:mm:ss') - Error updating user properties: $_"
        Write-EventLog -LogName $LogName -Source $LogSourceName -EventId 1000 -EntryType Error -Message $LogEntry
        throw
    }
}
