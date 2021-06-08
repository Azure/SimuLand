Function Update-AzureADAppPermissions
{
    <#
    .SYNOPSIS

    Assigns permissions to an Azure AD application. It leverages autocompleter and dynamic parameters

    .PARAMETER AppDisplayName

    Application to update permissions to
    
    .PARAMETER AppServicePrincipalName

    Service principal name of the application

    .PARAMETER RolesSvcPrincipalName

    Service principal name to obtain roles from

    .PARAMETER AppPermissionType
    
    Delegated (Scope) or Application (Role)

    .PARAMETER AppRoles

    An array of roles to be assigned to the application

    .PARAMETER GrantPermissions
    
    Grant permissions yes ($true) or no ($false)

    .PARAMETER MSGraphToken
    
    Microsoft Graph token used to grant OAuth2Permissions to application

    .NOTES
    
    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: GPL-3.0

    Reference:
    - https://stackoverflow.com/a/61458391
    - https://docs.microsoft.com/en-us/graph/api/resources/oauth2permissiongrant?view=graph-rest-1.0
    - https://samcogan.com/provide-admin-consent-fora-azure-ad-applications-programmatically/
    - https://goodworkaround.com/2020/09/07/azure-ad-consenting-to-an-application-with-script-using-graph/

    .EXAMPLE

    PS > Connect-AzureAD -AadAccessToken $token
    PS > Update-AzureADAppPermissions -AppDisplayName AccessoY -AppServicePrincipalName AccessoY -RolesSvcPrincipalName 'Office 365 Exchange Online' -AppPermissions Mail.ReadWrite
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Position=0,Mandatory=$true)]
        [string]$AppDisplayName,

        [Parameter(Position=1,Mandatory=$true)]
        [string]$AppServicePrincipalName,

        [Parameter(Position=2,Mandatory=$true)]
        [ValidateSet("Delegated","Application")]
        [string]$AppPermissionType,

        [Parameter(Position=3,Mandatory=$false)]
        [ValidateSet("True","False")]
        [string]$GrantPermissions="False",

        [Parameter(Position=4,Mandatory=$true)]
        [ArgumentCompleter( {
            param (
                $CommandName,
                $ParameterName,
                $WordToComplete,
                $CommandAst,
                $FakeBoundParameters
            )
            $PropertyType = Switch ($fakeBoundParameters.AppPermissionType) {
                'Delegated' { 'Oauth2Permissions'}
                'Application' { 'AppPermissions' }
            }
            Get-AzureADServicePrincipal -All $true | Where-object {$_.$PropertyType -ne $null}  | Select-Object -ExpandProperty DisplayName | Sort-Object | Where-object {$_ -like "$wordToComplete*"}
        })]
        [string]$RolesSvcPrincipalName
    )
    DynamicParam {
        if ($RolesSvcPrincipalName)
        {
            # Strip single and double quotes from RoleSvcPrincipalName value
            $CleanedSvcPrincipalName = $RolesSvcPrincipalName.Trim() -replace "['`"]", ""
            $PropertyType = Switch ($AppPermissionType) {
                'Delegated' { 'Oauth2Permissions'}
                'Application' { 'AppPermissions' }
            }
            # Adding AppPermissions Dynamic parameter
            $ParamOptions = @(
                @{
                'Name' = 'AppPermissions';
                'Mandatory' = $true;
                'ValidateSetOptions' = (Get-AzureADServicePrincipal -Filter "DisplayName eq '$CleanedSvcPrincipalName'").$PropertyType | Select-Object -ExpandProperty Value
                }
            )
            
            # If permission is delegated and we want to grant admin consent, then we need a MS Graph token
            if ($AppPermissionType -eq 'Delegated' -and $GrantPermissions -eq 'True')
            {
                $TokenOption = @{
                    'Name' = 'MSGraphToken';
                    'Mandatory' = $true
                }
                $ParamOptions = $ParamOptions + @($TokenOption)
            }

            # Adding Dynamic parameter
            $RuntimeParamDic = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            foreach ($Param in $ParamOptions) {
                $RuntimeParam = New-DynamicParam @Param
                $RuntimeParamDic.Add($Param.Name, $RuntimeParam)
            }
            return $RuntimeParamDic
        }
    }
    begin {
        $PsBoundParameters.GetEnumerator() | ForEach-Object { New-Variable -Name $_.Key -Value $_.Value -ea 'SilentlyContinue'}
    }
    process
    {
        try 
        {
            if (Get-Module -ListAvailable -Name AzureAD) {
                if (!(Get-Module "AzureAD")) {
                    Import-Module AzureAD
                } 
            } 
            else {
                Install-Module AzureAD
                Import-Module AzureAD
            }

            $PropertyType = Switch ($AppPermissionType) {
                'Delegated' { 'Oauth2Permissions'}
                'Application' { 'AppRoles' }
            }

            $PermissionType = Switch ($AppPermissionType) {
                'Delegated' { 'Scope'}
                'Application' { 'Role' }
            }

            $CleanedSvcPrincipalName = $RolesSvcPrincipalName.Trim() -replace "['`"]", ""
            $AzADApp =  Get-AzureADApplication -Filter "DisplayName eq '$AppDisplayName'"
            $AzADAppServicePrincipal = Get-AzureADServicePrincipal -Filter "DisplayName eq '$AppServicePrincipalName'"
            $AzADRoleServicePrincipal = Get-AzureADServicePrincipal -Filter "DisplayName eq '$CleanedSvcPrincipalName'"

            # Iterate Permissions array
            Write-Host "[+] Retrieve Role Assignments objects"
            $RoleAssignments = @()
            Foreach ($AppPermission in $AppPermissions) {
                Write-Host "  [+] Role: $AppPermission ($PropertyType)"
                $RoleAssignment = $AzADRoleServicePrincipal.$PropertyType | Where-Object { $_.Value -eq $AppPermission}
                $RoleAssignments += $RoleAssignment
            }

            Write-Host "[+] Creating Resource Access Object"
            $ResourceAccessObjects = New-Object 'System.Collections.Generic.List[Microsoft.Open.AzureAD.Model.ResourceAccess]'
            foreach ($RoleAssignment in $RoleAssignments) {
                Write-Host "  [+] Adding Role: $($RoleAssignment.Value) ($PropertyType)"
                $resourceAccess = New-Object -TypeName "Microsoft.Open.AzureAD.Model.ResourceAccess"
                $resourceAccess.Id = $RoleAssignment.Id
                $resourceAccess.Type = $PermissionType
                $ResourceAccessObjects.Add($resourceAccess)
            }

            $requiredResourceAccess = New-Object -TypeName "Microsoft.Open.AzureAD.Model.RequiredResourceAccess"
            $requiredResourceAccess.ResourceAppId = $AzADRoleServicePrincipal.AppId
            $requiredResourceAccess.ResourceAccess = $ResourceAccessObjects

            # set the required resource access
            Write-Host "[+] Setting Resource Access"
            Set-AzureADApplication -ObjectId $AzADApp.ObjectId -RequiredResourceAccess $requiredResourceAccess
            Start-Sleep -s 1

            if ($PermissionType -eq 'Application')
            {
                # grant the required resource access
                if ($GrantPermissions)
                {
                    foreach ($RoleAssignment in $RoleAssignments) {
                        Write-Output -InputObject ('Granting admin consent for App Role: {0}' -f $($RoleAssignment.Value))
                        New-AzureADServiceAppRoleAssignment -ObjectId $AzADAppServicePrincipal.ObjectId -Id $RoleAssignment.Id -PrincipalId $AzADAppServicePrincipal.ObjectId -ResourceId $AzADRoleServicePrincipal.ObjectId
                        Start-Sleep -s 1
                    }
                }
            }
            else
            {
                if ($GrantPermissions)
                {
                    $body = @{
                        clientId = $AzADAppServicePrincipal.ObjectId
                        consentType = "AllPrincipals"
                        principalId = $null
                        resourceId = $AzADRoleServicePrincipal.ObjectId
                        scope = "$AppPermissions"
                        startTime = "$((get-date).ToString("yyyy-MM-ddTHH:mm:ss:ffZ"))"
                        expiryTime = "$((get-date).AddYears(1).ToString("yyyy-MM-ddTHH:mm:ss:ffZ"))"
                    }
                    $apiUrl = "https://graph.microsoft.com/v1.0/oauth2PermissionGrants"
                    
                    Invoke-RestMethod -uri $apiUrl -Headers @{Authorization = "Bearer $MSGraphToken"} -Method POST -Body $($body | convertto-json) -ContentType "application/json"
                }
            }
        } 
        catch 
        {
            Write-Error $_.Exception.Message
        }
    }
}

function New-DynamicParam {
    [CmdletBinding()]
    [OutputType('System.Management.Automation.RuntimeDefinedParameter')]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,
        [Parameter(Mandatory=$false)]
        [array]$ValidateSetOptions,
        [Parameter()]
        [switch]$Mandatory = $false,
        [Parameter()]
        [switch]$ValueFromPipeline = $false,
        [Parameter()]
        [switch]$ValueFromPipelineByPropertyName = $false
    )

    $Attrib = New-Object System.Management.Automation.ParameterAttribute
    $Attrib.Mandatory = $Mandatory.IsPresent
    $Attrib.ValueFromPipeline = $ValueFromPipeline.IsPresent
    $Attrib.ValueFromPipelineByPropertyName = $ValueFromPipelineByPropertyName.IsPresent

    # Create AttributeCollection object for the attribute
    $Collection = new-object System.Collections.ObjectModel.Collection[System.Attribute]
    # Add our custom attribute
    $Collection.Add($Attrib)
    # Add Validate Set
    if ($ValidateSetOptions)
    {
        $ValidateSet= new-object System.Management.Automation.ValidateSetAttribute($Param.ValidateSetOptions)
        $Collection.Add($ValidateSet)
    }

    # Create Runtime Parameter
    if ($Param.Name -eq 'AppRoles')
    {
        $DynParam = New-Object System.Management.Automation.RuntimeDefinedParameter($Param.Name, [array], $Collection)
    }
    else
    {
        $DynParam = New-Object System.Management.Automation.RuntimeDefinedParameter($Param.Name, [string], $Collection)
    }
    $DynParam
}