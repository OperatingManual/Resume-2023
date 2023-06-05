<#
.SYNOPSIS
Updates the UserPrincipalName (UPN) of a user using Microsoft Graph API cmdlets and retrieves the updated user. This simply wraps the standard command in event logging for automation.

.DESCRIPTION
This script retrieves a user using the old UserPrincipalName (UPN), updates the UPN to a new value, and retrieves the user again using the new UPN. The changes are performed using Microsoft Graph API cmdlets. The script logs the start of the update, the updated user information, and any errors that occur during the process.

.PARAMETER OldUPN
Specifies the old UserPrincipalName (UPN) of the user to update.

.PARAMETER NewUPN
Specifies the new UserPrincipalName (UPN) to set for the user.

.PARAMETER LogName
Specifies the name of the event log to write the changes and errors to. Default is "Application".

.EXAMPLE
Update-MgUserProperty -OldUPN "olduser@domain.com" -NewUPN "newuser@domain.com"

This example updates the UserPrincipalName of the user from "olduser@domain.com" to "newuser@domain.com" using Microsoft Graph API cmdlets.

.NOTES
Author: Tyler Tourot
Date: 06/05/2023

.LINK
Script Repository: https://github.com/OperatingManual/Resume-2023
#>

function Update-SSDOMgUserProperty {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$OldUPN,

        [Parameter(Mandatory = $true)]
        [string]$NewUPN,

        [string]$LogName = "Application"
    )

    $LogSourceName = "TBD" # Must be initialized and set once. Initialization should occur during server build.

    # Begin logging
    $LogEntry = "$(Get-Date -Format 'yyyy/MM/dd HH:mm:ss') - Starting update for UserPrincipalName: $OldUPN"
    Write-EventLog -LogName $LogName -Source $LogSourceName -EventId 3000 -EntryType Information -Message $LogEntry

    try {

        # Update UserPrincipalName
        Update-MgUser -UserId $OldUPN -UserPrincipalName $NewUPN

        # Retrieve user using the new UPN
        $UpdatedUser = Get-MgUser -UserId $NewUPN

        # Log the updated user information
        $LogEntry = "$(Get-Date -Format 'yyyy/MM/dd HH:mm:ss') - User updated. New UserPrincipalName: $NewUPN"
        Write-EventLog -LogName $LogName -Source $LogSourceName -EventId 3000 -EntryType Information -Message $LogEntry

        # Return the updated user
        $UpdatedUser
    }
    catch {
        $LogEntry = "$(Get-Date -Format 'yyyy/MM/dd HH:mm:ss') - Error occurred while updating user: $_"
        Write-EventLog -LogName $LogName -Source $LogSourceName -EventId 1000 -EntryType Error -Message $LogEntry
        throw
    }
}


