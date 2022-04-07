<#
  Name: Set-NexusServer
  Description: Sets the Globals implicity used by the other PSNexus cmdlets
  Credits: Some *inspiration* taken from https://github.com/steviecoaster/NexuShell
  Returns: N/A

  Changelog
  ============================================
  [25 MAR 2022]
  * Created function
#>

function Set-NexusServer {
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "")]
  
  [CmdletBinding()]
  param(
    [Parameter(Mandatory, Position = 0)]
    [Alias("Server", "Uri", "Url")]
    [ValidateScript({ -not [string]::IsNullOrWhitespace($_) })]
    [string]$Hostname,
    
    [Parameter(Mandatory, Position = 1)]
    [System.Management.Automation.PSCredential]
    $Credential,
    
    [string]$Port = 8081,
    [switch]$UseSSL
  )

  process {
    $script:Protocol = $UseSSL ? 'https' : 'http'

    $script:Port = $Port
    $script:Hostname = $Hostname.TrimEnd('/')
    
    $credPair = "{0}:{1}" -f $Credential.UserName,$Credential.GetNetworkCredential().Password
    $encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($credPair))

    $script:Header = @{ Authentication = "Basic $encodedCreds" }
    $script:Credential = $Credential
    $script:Uri = "$($script:Protocol)://$($script:Hostname):$($script:Port)/service/rest"

    Write-Verbose $script:Hostname

    # Verify connection
    try {
      $uri = "$($script:Uri)/v1/status"
      $params = @{
        Method = 'GET'
        Uri = $uri
        Headers = $script:Header
        ContentType = 'application/json'
        UseBasicParsing = $true
      }

      Write-Verbose $params

      $req = Invoke-RestMethod @params
      return [PSCustomObject]@{
        Connected = $true
        Server = $script:Hostname
        Token = $encodedCreds
      }
    }
    catch {
      [int]$reqError = $_.Exception.Response.StatusCode
      switch ($reqError) {
        503 { 
          return [PSCustomObject]@{
            StatusCode = $reqError
            message = "Unavailable to service requests"
          }
        }

        default { 
          return [PSCustomObject]@{
            StatusCode = $reqError
            message = "Unknown error: $responseCode"
          }
        }
      }
    }
  }
}
