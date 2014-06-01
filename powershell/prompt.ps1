Push-Location (Split-Path -Path $MyInvocation.MyCommand.Definition -Parent)

# Load posh-git module from current directory
Import-Module .\posh-git

# If module is installed in a default location ($env:PSModulePath),
# use this instead (see about_Modules for more information):
# Import-Module posh-git


# Set up a simple prompt, adding the git prompt parts inside git repos
function global:prompt {
    $realLASTEXITCODE = $LASTEXITCODE

    # Reset color, which can be messed up by Enable-GitColors
    $Host.UI.RawUI.ForegroundColor = $GitPromptSettings.DefaultForegroundColor

    Write-Host(Shrink-Path $pwd.ProviderPath) -nonewline

    Write-VcsStatus

    $global:LASTEXITCODE = $realLASTEXITCODE
    return "> "
}

Enable-GitColors

Pop-Location

Start-SshAgent -Quiet

function Shrink-Path
{
    param
    (
        [Parameter(ParameterSetName="directoryInfo",Position=0)]
        [System.IO.DirectoryInfo]
        [ValidateNotNull()]
        $directoryInfo,

        [Parameter(ParameterSetName="pathInfo",Position=0)]
        [System.Management.Automation.PathInfo]
        [ValidateNotNull()]
        $pathInfo,

        [Parameter(ParameterSetName="stringPath",Position=0)]
        [System.String]
        [ValidateNotNull()]
        $stringPath,

        [int] $Threshold = 40
    )
    
    $pathParts = new-object 'System.Collections.Generic.List[String]'
    $pathToShrink = $null

    switch ($PSCmdlet.ParameterSetName)
    {
        "directoryInfo" { $pathToShrink = $directoryInfo }
        "pathInfo" { $pathToShrink = new-object 'System.IO.DirectoryInfo' -ArgumentList $pathInfo.Path }
        "stringPath" { $pathToShrink = new-object 'System.IO.DirectoryInfo' -ArgumentList $stringPath }
    }

    if ($pathToShrink.FullName.Length -lt $Threshold)
    {
        return $pathToShrink.FullName
    }

    $currentDirInfo = $pathToShrink
    $pathParts.Add($currentDirInfo.Name)
    $currentDirInfo = $currentDirInfo.Parent
    do
    {
        $shrunkPathName = $currentDirInfo.Name.Substring(0,1)
        $pathParts.Insert(0, $shrunkPathName)
        $currentDirInfo = $currentDirInfo.Parent
    }
    until ($currentDirInfo.Name -eq $pathToShrink.Root.Name)

    $pathParts.Insert(0, $currentDirInfo.Root.FullName)
    [System.IO.Path]::Combine($pathParts.ToArray())
}