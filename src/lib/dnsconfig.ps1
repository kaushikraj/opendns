class OpenDnsConfig {
	[string] $UserName = $null;
	[FilterLevel] $FilterLevel = [FilterLevel]::Unknown
	[FilterCategory[]] $Categories = @();
	
	OpenDnsConfig([PSCustomObject]$config, [string] $username){
		if ($config -eq $null) {
			return;
		}
		
		# config file must have username and filterlevel defined
		if (-not $this.isValidConfig($config)){
			throw "Config file is not a valid configuration file"
		}
		
		$this.UserName = $username;
		
		if ($config.filterlevel -ne $null){
			$this.FilterLevel = [FilterLevel] $config.filterlevel
		}
		
		$cat = $this.isDefined($config, "Categories")
		
		if ($cat -and $config.Categories -ne $null){
			$cc = $config.Categories
			foreach ($c in $cc){
				$v = [FilterCategory] $c;
				$this.Categories += $v;
			}
		}
	}
	
	[bool] isValidConfig([PSCustomObject]$config){
		$valid = $true;
		
		$properties = @("FilterLevel");
		foreach ($property in $properties){
			if (-not $this.isDefined($config, $property)){
				$valid = $false;
			}
		}
		
		return $valid;
	}
	
	[bool] isDefined([PSCustomObject]$config, [string]$propertyName){
		return [bool]($config.PSobject.Properties.name -match $propertyName)
	}
}
