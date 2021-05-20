# Reference:
# https://www.powershellgallery.com/packages/AADInternals/0.4.4/Content/ADFS_utils.ps1

function Get-DomainAdmins
{
    $DomainName = (Get-WmiObject Win32_ComputerSystem).Domain
    $arr = ($DomainName).split('.')
    $DNDomain = [string]::Join(",", ($arr | % { "DC={0}" -f $_ }))

    # Create LDAP Search 
    $ADSearch = New-Object System.DirectoryServices.DirectorySearcher
    $ADSearch.SearchRoot = "LDAP://$DomainName/$DNDomain"
    $ADSearch.Filter=" (&(objectCategory=user)(memberOf=CN=Domain Admins,CN=Users,$DNDomain))"
    $ADUsers=$ADSearch.FindAll()
    $Results = @()
    ForEach($ADUser in $ADUsers){
        If($ADUser){
            $Object = New-Object PSObject -Property @{ 
                Samaccountname = ($ADUser.Properties).samaccountname
                ObjectGuid  = ([guid]($ADUser.Properties).objectguid[0]).guid
            }
            $Results += $Object
        }
    }
    # Display results
    $Results | Format-Table Samaccountname,ObjectGuid
}