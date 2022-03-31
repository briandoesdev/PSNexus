<#
  Name: Get-NexusRepository
  Description: Gets details of a specified repositoru.
    * If no repo name is provided, it gets a list of all repos.
  Returns: Details of specified repo OR list of all repos

  Changelog
  ============================================
  [25 MAR 2022]
  * Created function
#>

function Get-NexusRepository {
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSPossibleIncorrectComparisonWithNull", "")]

  param(
    [Alias("Name")]
    [string]$Repository
  )

  begin {
    $slug = "v1/repositories"

    if (-not $script:Hostname) {
      throw "No server configured, must call Set-NexusServer first."
    }
  }

  process {
    if(-not [string]::IsNullOrWhiteSpace($Repository)) {
      $slug = "$slug/$Repository"
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

      Write-Verbose "Item count: $($req.Count)"
      return $req
    }
    catch {
      [int]$reqError = $_.Exception.Response.StatusCode
      switch ($reqError) {
        401 {
          return [PSCustomObject]@{
            StatusCode = $reqError
            message = "Authentication required"
          }
        }

        403 {
          return [PSCustomObject]@{
            StatusCode = $reqError
            message = "Insufficient permissions"
          }
        }

        404 { 
          return [PSCustomObject]@{
            StatusCode = $reqError
            message = "Repository $Repository does not exist"
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