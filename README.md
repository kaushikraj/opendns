Update-OpenDns cmdlet is a Powershell cmdlet to update your OpenDns settings through the command line. 

[OpenDNS](https://www.opendns.com/) provides Domain Name System resolution services—with content filtering feature. Unfortunately, OpenDns website is not the most user friendly. This program provides a simple command line for updating filter levels.

## Pre-req

Powershell version 7.2

## Set up

1. Download the code in a folder (via git or zip download)
2. Open a Powershell window and load the cmdlet

        PS>. .\src\od.ps1

## Execution
In the Powershell window, execute the Update-OpenDns cmdlet

    PS>Update-OpenDns -Username <opendns-username> -Config <config file>
	
Username: The username that you have registered at OpenDns
Config: The configuration to be applied in OpenDns

The cmdlet will prompt to enter OpenDns password. Enter your OpenDns password to run the command.

### Configuration syntax

The configuration needs to be in json format.

**FilterLevel**: Required property.
**Categories**: Optional for all except for "custom" FilterLevel

#### FilterLevel

OpenDns has four pre-defined filter levels (High, Moderate, Low, None) or you can set a custom filter level. More information on filter levels can be found in "ADJUSTING WEB CONTENT FILTERING" section [here](https://support.opendns.com/hc/en-us/articles/227988047-Web-Content-Filtering-and-Security).
  

#### Categories

Categories is an optional property except when FilterLevel is set to **custom**. Supported custom categories are listed in the `./src/lib/filtercategory.ps1` file.

## Known Issues
1. Multiple Network: If you have registered multiple networks in OpenDns, this cmdlet will not work.

## Copyright and License
Copyright 2021 Kaushik Raj. Code released under MIT license.