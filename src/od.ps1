Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

#load the library files
Import-Module $(Join-Path -Path (Split-Path $MyInvocation.Mycommand.Path) -ChildPath "lib/opendns-lib.ps1")

function Update-OpenDns {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory=$true,
                HelpMessage="OpenDns username")] 
		[string]$Username,
		
		[Parameter(Mandatory=$true,
                HelpMessage="Settings configuration to apply.")] 
		[string]$Config
	)
	begin {
				
		Write-Host "[Update-OpenDns] version 1.0"
		if (-not (Test-Path $Config -PathType Leaf)) {
			throw "Unable to load configuration file [$Config]. Please check if it exists."
		}
	}
	process {
		$jsonconfig = Get-Content -Path $Config | ConvertFrom-Json
		
		$dnsconfig = [OpenDnsConfig]::new($jsonconfig, $Username)

		# read password through console.
		$securePwd = Read-Host "Password" -AsSecureString

		$opendns = [OpenDns]::new($username, $securePwd)
		$success = $opendns.SignIn() 

		if (-not $success) {
			Write-Host -ForegroundColor Red "SignIn failed for [$username]"
			return;
		}
		
		# execute the action
		if ($dnsconfig.FilterLevel -eq [FilterLevel]::Custom) {
			#custom setting
			Write-Host "Updating custom settings"
			$update, $message = $opendns.Block($dnsconfig);
		}else{
			#bundle setting
			Write-Host "Updating bundle: $($dnsconfig.FilterLevel)"
			$update, $message = $opendns.SaveBundle($dnsconfig);
		}

		if ($update) {
			Write-Host -ForegroundColor Green $message
		}else {
			Write-Host -ForegroundColor Red "Failed in saving...."
		}
	}
	end {
	}
}