<#
.SYNOPSIS
  Get the MFA Methods for the supplied user

.DESCRIPTION
  This function builds an object with the status of each type of MFA for the supplier user.
  There is then an overall `status` that is "enabled" when a user has some form of MFA on their account.

.PARAMETER UserId
  The GUID of the user to get Authentication Methods for.

.PARAMETER Exclude
  An array of authentication methods to exclude from the output.

.PARAMETER NonMFAMethods
  An array of authentication methods that don't count as MFA for the `enabled` flag in the return. Defaults to `"password"`

.EXAMPLE
  Get-MtUserAuthMethod -UserId $userId
  # Get the mfa mthods for $userId

  Get-MtUaserAuthMethod -UserId $userId -Exclude "phone"
  # Get the auth methods fro $userId excluding "phone"

#>
Function Get-MtUserAuthMethod {
  param(
    [Parameter(Mandatory = $true)] $UserId,
    [Parameter()]
    [String[]]$Exclude = @(),
    [Parameter()]
    [String[]]$NonMFAMethods = @("password")
  )
  process{
    Write-Verbose "Get authentication methods for user"
    [array]$mfaData = Get-MgUserAuthenticationMethod -UserId $userId

    $returnData = [PSCustomObject][Ordered]@{
      userId = $userId
      enabled = $false
      methods = @()
    }

    $allMethods = @()

    ForEach ($method in $mfaData){
      <#if(-not ($method.AdditionalProperties["@odata.type"] -eq "#microsoft.graph.passwordAuthenticationMethod")){
        Write-Verbose "The user has a non-password authentication method attached to thier account."
        $returnData.enabled = $true
      }#>

      $allMethods += $method.AdditionalProperties["@odata.type"] -replace "#microsoft.graph.", "" -replace "AuthenticationMethod", ""
    }

    $filtered = @()

    ForEach($method in $allMethods){
      if(-not ($Exclude -contains $method)){
        $filtered += $method
      }

      if(-not ($NonMFAMethods -contains $method)){
        $returnData.enabled = $true
      }
    }

    $returnData.methods = $filtered

    return $returnData
  }
}