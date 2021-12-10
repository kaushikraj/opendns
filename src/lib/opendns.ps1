class OpenDns {
	[string]$UserName = $null;
	[bool] $IsSignedIn = $false;
	[string[]] $NetworkIds = $null;
	
	
	#private properties
	[string] hidden $Token = $null;
	hidden $SecurePassword = $null;
	hidden $session =  $null;
	
	# for debug purpose only
	hidden $lastResponse = $null

	OpenDns([string]$UserName, $SecurePassword){
		$this.UserName = $UserName;
		$this.SecurePassword = $SecurePassword;
		
		
		$this.session =  New-Object Microsoft.PowerShell.Commands.WebRequestSession
		
		#initialize the token
		$this.InitializeToken()
	}
	
	[bool] SignIn(){
		$this.IsSignedIn = $this.trySignIn();
		if ($this.IsSignedIn){
			$this.initNetworkIds();
		}
		return $this.IsSignedIn
	}
	
	[string] getNetworkId(){
		$networkId = $null;
		
		if ($this.NetworkIds -ne $null){
			$networkId = $this.NetworkIds[0];
		}
		
		return $networkId;
	}
	
	[object] Block([OpenDnsConfig] $config){
		$networkId = $this.getNetworkId()
		
		$block_body = @{
			"action"="save_blocking_categories"
			"return"= "/settings/$networkId/content_filtering"
			"n"= $networkId
		}
		
		# build the categories
		if ($config.Categories -ne $null){
			foreach($cat in $config.Categories)
			{
				$value = [int] $cat;
				$key = [string]::Format("dt_category[{0}]", $value);
				
				$block_body[$key] = $value;
			}
		}
		
		$response = Invoke-WebRequest  -Uri $([OpenDnsUrls]::AjaxUrl) -Method 'POST' -Body $block_body  -WebSession $this.session
		$this.lastResponse = $response
		
		return $this.parseAjaxResponse($response)
	}
	
	[object] SaveBundle([OpenDnsConfig] $config){
		$networkId = $this.getNetworkId()
		$unlock_body = @{
			"bundle"="none"
			"action"="save_bundle"
			"n"= $networkId
		}
		
		$response = Invoke-WebRequest -Uri $([OpenDnsUrls]::AjaxUrl) -Method 'POST' -Body $unlock_body  -WebSession $this.session
		
		$this.lastResponse = $response
		
		return $this.parseAjaxResponse($response)
	}
	
	#private methods
	
	[void] InitializeToken(){
		# get the token for sign-in
		$response = Invoke-WebRequest -Uri $([OpenDnsUrls]::LoginUrl) -WebSession $this.session
		$this.lastResponse = $response
		
		if ($response.InputFields -ne $null) {
			$tokenfield = $response.InputFields.FindByName("formtoken");
			if ($tokenfield -ne $null){
				$this.Token = $tokenfield.value
			}
		}
	}
	
	[void] initNetworkIds() {
		$response = Invoke-WebRequest -Uri $([OpenDnsUrls]::SettingUrl) -WebSession $this.session		
		$this.lastResponse = $response
		
		$idsInput = $response.InputFields.FindByName("origin_id[]")
		if ($idsInput -ne $null){
			$this.NetworkIds = $idsInput.value.Split(",")
		}
	}
	
	[string] getPlainTextPassword() {
		$pwd = $null;
		if ($this.SecurePassword -ne $null) {
			$pwd =[Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($this.SecurePassword))
		}
		
		return $pwd
	}
	
	[bool] trySignIn() {
	
		$pwd = $this.getPlainTextPassword();
	
		$login_body = @{
			"username" = $this.UserName
			"password" = $pwd
			"return_to" = [OpenDnsUrls]::ReturnToUrl
			"formtoken" = $this.Token
		}
		
		$logged = $false
		
		$response = Invoke-WebRequest -Uri $([OpenDnsUrls]::LoginUrl) -Method 'POST' -Body $login_body  -WebSession $this.session
		$this.lastResponse = $response
		
		if ($response -ne $null) {	
			#checking if the login was success
			#presence of username in response is not success
			if ($response.InputFields -ne $null){
				$found = $response.InputFields.FindByName("username");
				$logged = -not $found;
			} else {
				$logged = $true
			}
		}
	
		return $logged
	}
	
	[object] parseAjaxResponse($response){
		$success = $false
		$message = $null
		
		# check for success
		if ($response.StatusCode -eq 200){
			$json = $response.Content | ConvertFrom-Json
			if ($json.success -eq $true){
				$success = $true
				$message = $json.message
			}
		}
	
		return $success, $message
	}
}