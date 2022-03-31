<#
Name: PSNexus
Description: Some desc here tho

Changelog
============================================
[29 MAR 2022]
* Removed $Global: for $script:

[24 MAR 2022]
* Created module
#>

# Set our implicit globals
[string]$Global:NexusBaseUrl = $null;
[string]$Global:NexusAuthToken = $null;

# Script vars
$ScriptPath = Split-Path $MyInvocation.MyCommand.Path

# Load public cmdlets
try {
  $cmdlets = Get-ChildItem "$ScriptPath\Public" -Filter *.ps1 -Exclude *.Test.ps1 -Recurse
  foreach ($cmdlet in $cmdlets) {
    Write-Verbose "Importing $($cmdlet.FullName)"
    . $cmdlet.FullName
  }
}
catch {
  continue
}
