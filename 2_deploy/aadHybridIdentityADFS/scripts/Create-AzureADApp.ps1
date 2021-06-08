# Reference:
# https://stackoverflow.com/a/61458391
# Ataykov https://stackoverflow.com/users/605134/astaykov
# https://docs.microsoft.com/en-us/powershell/azure/create-azure-service-principal-azureps?view=azps-5.3.0
Function Create-AzureADApp
{
    param (
        [Parameter(Mandatory=$True)]
        [string] $appName,

        [Parameter(Mandatory=$false)]
        [switch] $password,

        [Parameter(Mandatory=$false)]
        [switch] $createSp,
    )
    # Check Module is installed
    if (Get-Module -ListAvailable -Name AzureAD) {
        if (!(Get-Module "AzureAD")) {
            Import-Module AzureAD
        } 
    } 
    else {
        Install-Module AzureAD
        Import-Module AzureAD
    }

    # create your new application
    Write-Output -InputObject ('Creating App Registration {0}' -f $appName)
    if (!(Get-AzureADApplication -SearchString $appName)) {
        $app = New-AzureADApplication -DisplayName $appName -Homepage "https://localhost/$appName" -ReplyUrls "https://localhost/$appName" -IdentifierUris "https://localhost/$appName" 
        $app

        if ($Password)
        {
            # create a password (spn key)
            $appPwd = New-AzureADApplicationPasswordCredential -ObjectId $app.ObjectId
            $appPwd
        }

        # create SPN for App Registration
        Write-Output -InputObject ('Creating SPN for App Registration {0}' -f $appName)

        if ($createSp)
        {
            # create a service principal for your application
            # you need this to be able to grant your application the required permission
            $appSp = New-AzureADServicePrincipal -AppId $app.AppId

            if ($password)
            {
                $appSpPwd = New-AzureADServicePrincipalPasswordCredential -ObjectId $appSp.ObjectId
                $appSpPwd
            }
        }
    }
    else {
        Write-Output -InputObject ('App Registration {0} already exists' -f $appName)
        $app = Get-AzureADApplication -SearchString $appName
    }
    #endregion

    return $app
}