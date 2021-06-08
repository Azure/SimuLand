Function Get-MyMailMessages
{
    param (
        [Parameter(Mandatory=$True)]
        [string] $AccessToken
    )

    $Uri = "https://graph.microsoft.com/v1.0/me/messages"
    $Header = @{
        Authorization = "Bearer $AccessToken"
    }
    Invoke-RestMethod -Uri $Uri -Headers $Header -Method GET -ContentType "application/json"
}