Function Connect-AzureADApp
{
    <#
    .SYNOPSIS

    Authenticates via an Azure AD Application

    .PARAMETER AppId

    Application Id to authenticate to. This can be the display name of the application of its ID. Example: d3590ed6-52b3-4102-aeff-aad2292ab01c (Microsoft Office)
    
    .PARAMETER AppSecret

    Application secret/password to authenticate with

    .PARAMETER TenantName

    Name of tenant to authenticate with

    .PARAMETER GrantType

    authorization code flow type of grant

    .NOTES
    
    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: GPL-3.0

    Reference:
    https://adamtheautomator.com/microsoft-graph-api-powershell/
    https://docs.microsoft.com/en-us/graph/auth-v2-user
    https://github.com/Gerenios/AADInternals/blob/master/AccessToken_utils.ps1#L764

    .EXAMPLE

    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Position=0,Mandatory=$true)]
        [string]$AppId,

        [Parameter(Position=1,Mandatory=$true)]
        [AllowEmptyString()]
        [string]$AppSecret,

        [Parameter(Position=2,Mandatory=$true)]
        [string]$TenantName,

        [Parameter(Position=3,Mandatory=$true)]
        [ValidateSet("client_credentials","password","saml_token")]
        [string]$GrantType
    )
    DynamicParam {
        if ($GrantType)
        {
            # Adding Dynamic parameters
            if ($GrantType -eq 'password')
            {
                $ParamOptions = @(
                    @{
                    'Name' = 'username';
                    'Mandatory' = $true
                    },
                    @{
                    'Name' = 'password';
                    'Mandatory' = $true
                    }
                )
            }
            elseif ($GrantType -eq 'saml_token')
            {
                $ParamOptions = @(
                    @{
                    'Name' = 'SamlToken';
                    'Mandatory' = $true
                    }
                )  
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
            #Get Application
            [regex]$guidRegex = '(?im)^[{(]?[0-9A-F]{8}[-]?(?:[0-9A-F]{4}[-]?){3}[0-9A-F]{12}[)}]?$'
            if (!($AppId -match $guidRegex))
            {
                $AppDisplayName = $AppId.Trim() -replace "['`"]", ""
                $AppId =  (Get-AzureADServicePrincipal -Filter "DisplayName eq '$AppDisplayName'" -all $true).AppId
            }
            
            if ($GrantType -eq 'client_credentials')
            {
                $body = @{
                    client_id = $AppId
                    scope = 'https://graph.microsoft.com/.default'
                    grant_type = 'client_credentials'
                }
            }
            elseif ($GrantType -eq 'password')
            {
                $body = @{
                    client_id = $AppId
                    scope = 'https://graph.microsoft.com/.default'
                    username = $username
                    password = $password
                    grant_type = 'password'
                }
            }
            else 
            {
                $encodedSamlToken= [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($SamlToken))
                $body = @{
                    client_id = $AppId
                    scope = 'https://graph.microsoft.com/.default'
                    assertion = $encodedSamlToken
                    grant_type = 'urn:ietf:params:oauth:grant-type:saml1_1-bearer'
                }
            }
            if (![string]::IsNullOrEmpty($AppSecret))
            {
                $body.Add('client_secret', $AppSecret)
            }
            write-verbose $body
            
            $apiUrl = "https://login.microsoftonline.com/$TenantName/oauth2/v2.0/token"

            $requestToken = Invoke-RestMethod -uri $apiUrl -Method POST -Body $body -ContentType 'application/x-www-form-urlencoded'
            $requestToken
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
    $DynParam = New-Object System.Management.Automation.RuntimeDefinedParameter($Param.Name, [string], $Collection)
    $DynParam
}