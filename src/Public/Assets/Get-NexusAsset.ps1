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

  [CmdletBinding(DefaultParameterSetName = "Id")]
  param(
    [Parameter(Mandatory, ParameterSetName = "Repo")]
    [string]$Repository,

    [Parameter(ParameterSetName = "Repo")]
    [string]$ContinuationToken = $null,

    [Parameter(Mandatory, ParameterSetName = "Id")]
    [string]$Id
  )

  begin {
    # api endpoint to get assets
    $slug = "v1/assets"

    # basic check to verify server information exists
    if (-not $script:Hostname) {
      throw "No server configured, must call Set-NexusServer first."
    }
  }

  process {
    switch ($PSCmdlet.ParameterSetName) {

      "Repo" {
        try {

          $assets = [System.Collections.Generic.List[object]]::New()
          $params = @{
            Method = 'GET'
            Uri = "$($script:Uri)/$($slug)?repository=$Repository"
            Headers = $script:Header
            ContentType = 'application/json'
            UseBasicParsing = $true
          }

          do {
            # tacky, but it works.
            $params.Uri = "$($script:Uri)/$($slug)?repository=$Repository"

            if ($resp.continuationToken) {
              $params.Uri = "$($params.Uri)&continuationToken=$($resp.continuationToken)"
              $resp.continuationToken = $null
            }
            
            $resp = Invoke-RestMethod @params
            $assets.AddRange($resp.Items)
          } while ($resp.continuationToken)
          
          return [PSCustomObject]@{
            StatusCode = 200
            Items = $assets
          }
        } catch {
          [int]$reqError = $_.Exception.Response.StatusCode
          switch ($reqError) {
            403 {
              $respError = [PSCustomObject]@{
                StatusCode = $reqError
                Message = "Insufficient permissions to list components"
              }
            };

            422 {
              $respError = [PSCustomObject]@{
                StatusCode = $reqError
                Message = "Parameter 'repository' is required"
              }
            };

            default {
              $respError = [PSCustomObject]@{
                StatusCode = $reqError
                Message = "Get-NexusAsset [Repo]: Undocumented error has occurred!"
              }
            };
          }

          return $respError
        }
      };

      "Id" {
        try {
          $params = @{
            Method = 'GET'
            Uri = "$($script:Uri)/$($slug)/$Id"
            Headers = $script:Header
            ContentType = 'application/json'
            UseBasicParsing = $true
          }
          $resp = Invoke-RestMethod @params
  
          return [PSCustomObject]@{
            StatusCode = 200
            Asset = $resp
          }
        } catch {
          [int]$reqError = $_.Exception.Response.StatusCode
          switch ($reqError) {
            403 {
              $respError = [PSCustomObject]@{
                StatusCode = $reqError
                Message = "Insufficient permissions to list components"
              }
            };

            404 {
              $respError = [PSCustomObject]@{
                StatusCode = $reqError
                Message = "Asset not found"
              }
            };

            422 {
              $respError = [PSCustomObject]@{
                StatusCode = $reqError
                Message = "Malformed ID"
              }
            };

            default {
              $respError = [PSCustomObject]@{
                StatusCode = $reqError
                Message = "Get-NexusAsset [Id]: Undocumented error has occurred!"
              }
            };
          }

          return $respError
        }
      };
    }
  }
}
