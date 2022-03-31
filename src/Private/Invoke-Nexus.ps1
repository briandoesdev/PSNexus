<#
  Name: Invoke-Nexus
  Description: 
  Returns: 

  Changelog
  ============================================
  [29 MAR 2022]
  * Created function
#>

function Invoke-Nexus {
  param (
    [Parameter(Mandatory)]
    [Alias("UriSlug")]
    [string]$Endpoint
  )

  if (-not $Global:NexusBaseUrl) {
    return @{
      Message = "Missing Nexus Server! Use Set-NexusServer to connect to Nexus."
    }
  }
}