# Author: Roberto Rodriguez @Cyb3rWard0g
# License: GPLv3

Function Update-SvcPrincipalPermissions
{
    param (
        [Parameter(Mandatory=$True)]
        [string] $AppName,

        [Parameter()]
        [string] $RolesSvcPrincipalName,

        [Parameter()]
        [string[]] $RequiredPermissions,

        [Parameter()]
        [ValidateSet("Delegated","Application")]
        [string] $AppPermissionType
    )

    #$spId = az resource list -n $AppName --query [*].identity.principalId --out tsv
    $CleanedAppName = $AppName.Trim() -replace "['`"]", ""
    $spId = az ad sp list --query "[?appDisplayName=='$CleanedAppName'].objectId" -o tsv --all

    # Get application id of app service principal to get roles from
    $CleanedSvcPrincipalName = $RolesSvcPrincipalName.Trim() -replace "['`"]", ""
    $RoleSvcAppId = az ad sp list --query "[?appDisplayName=='$CleanedSvcPrincipalName'].objectId" -o tsv --all
    if (!$RoleSvcAppId) {
        Write-Error "Error looking for Service Principal to get roles from"
        return
    }
    
    # Get all permissions available from the Roles service app
    $PropertyType = Switch ($AppPermissionType) {
        'Delegated' { 'oauth2Permissions'}
        'Application' { 'appRoles' }
    }

    Write-Output "[+] Updating App: Adding Permissions"
    Write-Output "[+] Getting $PropertyType Permissions ($PropertyType) from $CleanedSvcPrincipalName"
    $Permissions = az ad sp show --id $RoleSvcAppId --query "$PropertyType" | ConvertFrom-Json

    # Get Role Assignments
    Write-Output "[+] Getting Role Assignments"
    #$RequiredPermissions = @('email','profile','openid')
    $RoleAssignments = @()
    Foreach ($rp in $RequiredPermissions) {
        $RoleAssignment = $Permissions | Where-Object { $_.Value -eq $rp}
        $RoleAssignments += $RoleAssignment
    }

    Write-Output "[+] Creating Resource Access Object"
    $ResourceAccessObjects = @()
    foreach ($RoleAssignment in $RoleAssignments) {
        $ResourceAccessObjects += [PSCustomObject]@{
            principalId = $spId
            resourceId = $RoleSvcAppId
            appRoleId = $RoleAssignment.Id
        } | ConvertTo-Json -Compress
    }

    $Uri="https://graph.microsoft.com/v1.0/servicePrincipals/$spId/appRoleAssignments"
    foreach ($role in $ResourceAccessObjects) {        
        az rest --method post --uri $Uri --body $role --headers "Content-Type=application/json"
    }
}