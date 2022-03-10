function Export-SLAzureData {
    <#
    .SYNOPSIS

    Exports security events to the console or as JSON files from a Microsoft 365 Advanced Hunting platform or a Log Analytics Workspace backing up an Azure Sentinel instance.

    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None

    .DESCRIPTION

    Export-SLAzureData is a simple PowerShell wrapper for the M365 Advanced hunting and Log Analytics API to export security events
    and alerts as JSON files to share the telemetry generated after simulating adversary techniques.

    .PARAMETER ClientId

    Azure AD application ID with the right permissions to query the Microsoft 365 advanced hunting and Log Analytics API.

    .PARAMETER ClientSecret

    Azure AD application client secret (Password) to use while getting an access token for the Microsoft 365 advanced hunting and Log Analytics API.

    .PARAMETER TenantId

    Azure AD tenant ID

    .PARAMETER Query

    The KQL query to run and filter data to export.

    .PARAMETER WorkspaceId

    ID of the workspace. This is Workspace ID from the Properties blade in the Azure portal.

    .PARAMETER OutputPath

    The path or name of the file to export events to.

    .LINK

    https://docs.microsoft.com/en-us/microsoft-365/security/defender-endpoint/exposed-apis-create-app-webapp?view=o365-worldwide
    https://docs.microsoft.com/en-us/microsoft-365/security/defender-endpoint/run-advanced-query-api?view=o365-worldwide
    https://docs.microsoft.com/en-us/microsoft-365/security/defender-endpoint/apis-intro?view=o365-worldwide
    https://dev.loganalytics.io/
    https://docs.microsoft.com/en-us/rest/api/loganalytics/dataaccess/query/get
    #>

    [CmdletBinding(DefaultParameterSetName = 'M365')]
    Param (
        [Parameter(ParameterSetname='M365', Position = 0, Mandatory = $True)]
        [Parameter(ParameterSetname='LA')]
        [ValidateNotNullOrEmpty()]
        [String] $ClientId,

        [Parameter(ParameterSetname='M365', Position = 1, Mandatory = $true)]
        [Parameter(ParameterSetname='LA')]
        [ValidateNotNullOrEmpty()]
        [String] $ClientSecret,

        [Parameter(ParameterSetname='M365', Position = 2, Mandatory = $true)]
        [Parameter(ParameterSetname='LA')]
        [ValidateNotNullOrEmpty()]
        [String] $TenantId,

        [Parameter(ParameterSetname='LA', Mandatory=$false)]
        [String] $WorkspaceId,

        [Parameter(ParameterSetname='M365', ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory=$true)]
        [Parameter(ParameterSetname='LA')]
        [ValidateNotNullOrEmpty()]
        [String] $Query,

        [Parameter(ParameterSetname='M365', Mandatory=$false)]
        [Parameter(ParameterSetname='LA')]
        [String] $OutputPath
    )

    BEGIN {
        # Set Current Directory (PS Session Only)
        [Environment]::CurrentDirectory=(Get-Location -PSProvider FileSystem).ProviderPath

        # Set API URL
        switch ($PsCmdlet.ParameterSetName) {
            "M365" {
                $resource = "https://api.securitycenter.microsoft.com"
                $scope = "$resource/.default"
                $apiUri = "$resource/api/advancedqueries/run"
                $queryProperty = "Query"
            }
            "LA" {
                $resource = 'https://api.loganalytics.io'
                $scope = "$resource/.default"
                $apiUri = "$resource/v1/workspaces/$WorkspaceId/query"
                $queryProperty = "query"
            }
        }

        $body = @{
            client_id = $ClientId
            client_secret = $ClientSecret
            scope = $scope
            grant_type = 'client_credentials'
        }
        Write-Verbose $body.Values
        $TokenUrl = "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token"
        $params = @{
            "Method"="Post"
            "Uri"=$TokenUrl
            "Body"=$body
        }
        Write-Verbose $params.Values
        $response = $(Invoke-RestMethod @params)

        $AllEvents = @()
    }
    PROCESS {
        $Querybody = @{ $queryProperty = $Query }
        $HttpHeaders = @{
            'Content-Type' = 'application/json'
            Authorization = "$($response.token_type) $($response.access_token)"
        }
        Write-Verbose $HttpHeaders.Values
        $HTTPParams = @{
            Method = 'Post'
            Uri = $apiUri
            Body = $($QueryBody | ConvertTo-Json -Compress)
            Headers = $HttpHeaders
        }
        Write-Verbose $HttpParams.Values
        $QueryResponse = $(Invoke-RestMethod @HTTPParams)
        switch ($PsCmdlet.ParameterSetName) {
            "M365" {
                $AllEvents += $QueryResponse.Results
            }
            "LA" {
                $headerRow = $null
                $headerRow = $QueryResponse.tables.columns | Select-Object name
                $columnsCount = $headerRow.Count

                foreach ($row in $QueryResponse.tables.rows) {
                    $data = new-object PSObject
                    for ($i = 0; $i -lt $columnsCount; $i++) {
                        if ($row[$i]) {
                            $data | add-member -membertype NoteProperty -name $headerRow[$i].name -value $row[$i]
                        }
                    }
                    $AllEvents += $data
                    $data = $null
                }
            }
        }
    }
    END {
        if ($OutputPath)
        {
            Write-Verbose "[+] Exporting all events to $OutputPath"
            $utf8NoBom = New-Object System.Text.UTF8Encoding $false
            $AllEvents | ForEach-Object {
                $line = ConvertTo-Json $_ -Compress
                if (!(Test-Path $OutputPath))
                {
                    [System.IO.File]::WriteAllLines($OutputPath, $line, [System.Text.UTF8Encoding]($False))
                }
                else
                {
                    [System.IO.File]::AppendAllLines($OutputPath, [string[]]$line, [System.Text.UTF8Encoding]($False))
                }
            }
        }
        else {
            write-verbose "[+] Returning all events"
            return $AllEvents
        }
    }
}