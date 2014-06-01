Import-Module "$PSScriptRoot\Get-AdminStatus"

$pathsToAddToPath = @("C:\Program Files (x86)\Git\bin", "C:\chocolatey\bin")

foreach ($path in $pathsToAddToPath)
{
	if ($env:Path -notlike "*" + $path + "*")
	{
		$env:Path += ";"
		$env:Path += $path
	}
}

Import-Module "$PSScriptRoot\posh-git"
#. "$PSScriptRoot\posh-git\profile.example.ps1"
. "$PSScriptRoot\prompt.ps1"

. "$PSScriptRoot\powershell-ise-solarized\Solarize-PSISE-AddOnMenu.ps1" -Apply -Dark

$psISE.Options.FontName = "Source Code Pro for Powerline"
$psISE.Options.FontSize = 8

if (-not $alreadyStarted)
{
    set-location $HOME
    $alreadyStarted = $true
}

function reload-profile
{
    push-location
    . $profile
    pop-location
}