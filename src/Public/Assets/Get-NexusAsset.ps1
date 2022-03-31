<#
  Name: Get-NexusAsset
  Description: List Assets or details of a single asset
  Returns: Asset or list of assets

  Changelog
  ============================================
  [31 MAR 2022]
  * Created function
#>

function Get-NexusAsset {
  [CmdletBinding(DefaultParameterSetName = "Asset")]
  param(
    [Parameter(Mandatory, ParameterSetName = "Repository")]
    [string]$Repository,

    [Parameter(Mandatory, ParameterSetName = "Asset")]
    [Alias("Asset")]
    [string]$AssetId,

    [Parameter(ParameterSetName = "Repository")]
    [switch]$NoContinuationToken
  )

  begin {
    $slug = "v1/assets"

    if (-not $script:Hostname) {
      throw "No server configured, must call Set-NexusServer first."
    }
  }

  process {
    Write-Verbose "PSCmdlet.ParameterSetName is $($PSCmdlet.ParameterSetName)"
    switch ($PSCmdlet.ParameterSetName) {
      "Repository" {
        $slug = "{0}?repository=$Repository" -f $slug
        Write-Verbose "Slug is of Repo"
      }

      "Asset" {
        $slug = "$slug/$AssetId"
        Write-Verbose "Slug is of Asset"
      }
    }
    Write-Verbose "Slug: $slug"
    
    $params = @{
      Method = 'GET'
      Uri = "$($script:Uri)/$slug"
      Headers = $script:Header
      ContentType = 'application/json'
      UseBasicParsing = $true
    }

    try {
      $req = Invoke-RestMethod @params

      while ($req.continuationToken -and ($NoContinuationToken -eq $false)) {
        $params.Uri = "$($script:Uri)/$slug&continuationToken=$($req.continuationToken)"
        $req.continuationToken = $null
        
        $req += Invoke-RestMethod @params
      }

      return $req
    }
    catch {
      [int]$reqError = $_.Exception.Response.StatusCode
      switch ($reqError) {
        403 {
          return [PSCustomObject]@{
            StatusCode = $reqError
            message = "Insufficient permissions"
          }
        }

        404 { 
          return [PSCustomObject]@{
            StatusCode = $reqError
            message = "Asset not found"
          }
        }

        422 {
          return [PSCustomObject]@{
            StatusCode = $reqError
            message = "Malformed request"
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