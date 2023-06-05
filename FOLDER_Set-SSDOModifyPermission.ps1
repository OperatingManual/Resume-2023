<#
.SYNOPSIS
Sets modify permissions on a folder for a specified user and logs changes to the Application event log.

.DESCRIPTION
This advanced function sets modify permissions on a specified folder for a specified user and logs the changes to the Application event log. The function also logs the current ACLs and the new ACLs after the changes have been made.

.PARAMETER FolderPath
Specifies the path of the folder to modify.

.PARAMETER UserName
Specifies the name of the user to grant modify permissions to.

.PARAMETER LogName
Specifies the name of the event log to write changes to. Default is "Application".

.EXAMPLE
Set-ModifyPermission -FolderPath "Z:\TestFolder" -UserName "user01" -LogName "Security"

This example sets modify permissions on the "Z:\TestFolder" folder for the "user01" user and logs changes to the "Security" event log.

.NOTES
Author: Tyler Tourot
Date: 6/5/2023

.LINK
Script Repository: https://github.com/OperatingManual/Resume-2023
#>

function Set-SSDOModifyPermission {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateScript({Test-Path $_ -PathType 'Container'})]
        [string]$FolderPath,

        [Parameter(Mandatory = $true, Position = 1)]
        [string]$UserName,

        [string]$LogName = "Application"
    )

    # Initialize logging
    $LogSourceName = "TBD" # Must be initialized and set once. Initialization should occur during server build.
    $logEntry = "$(Get-Date -Format 'yyyy/MM/dd HH:mm:ss') - Starting ACL modification for $FolderPath"
    Write-EventLog -LogName $LogName -Source $LogSourceName -EventId 3000 -EntryType Information -Message $logEntry

    try {
        # Get the existing ACLs and log them
        $acl = Get-Acl $FolderPath
        $logEntry = "$(Get-Date -Format 'yyyy/MM/dd HH:mm:ss') - Current ACLs: $($acl.Access | Out-String)"
        Write-EventLog -LogName $LogName -Source $LogSourceName -EventId 3000 -EntryType Information -Message $logEntry

        # Create the new rule and add it to the ACL
        $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($UserName, "Modify", "ContainerInherit, ObjectInherit", "None", "Allow")
        $acl.SetAccessRule($rule)
        Set-Acl $FolderPath $acl

        # Log the new ACLs
        $logEntry = "$(Get-Date -Format 'yyyy/MM/dd HH:mm:ss') - New ACLs: $($acl.Access | Out-String)"
        Write-EventLog -LogName $LogName -Source $LogSourceName -EventId 3000 -EntryType Information -Message $logEntry
    }
    catch {
        $logEntry = "$(Get-Date -Format 'yyyy/MM/dd HH:mm:ss') - Error modifying ACLs: $_"
        Write-EventLog -LogName $LogName -Source $LogSourceName -EventId 1000 -EntryType Error -Message $logEntry
        throw
    }
}