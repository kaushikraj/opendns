# loads all the library files
$modules = @(
	"urls.ps1",
	"filterlevel.ps1",
	"filtercategory.ps1",
	"dnsconfig.ps1",
	"opendns.ps1"
)

foreach ($module in $modules) {
	$path = Join-Path -Path (Split-Path $MyInvocation.Mycommand.Path) -ChildPath $module -Resolve
	Import-Module $path
}
