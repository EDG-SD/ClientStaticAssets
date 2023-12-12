function Usage {
    Write-Output "This is Usage: ";
    Write-Output " from cmd.exe: ";
    Write-Output " powershell.exe SetVersion.ps1 2.8.3.0";
    Write-Output " ";
    Write-Output " from powershell.exe prompt: ";
    Write-Output " .\SetVersion.ps1 2.8.3.0";
    Write-Output " ";
}


function Update-SourceVersion {
    Param([System.IO.FileInfo] $file, [string] $Version = "")

    $newVersion = 'version="' + $Version + '"';  
    $NewQVersion = 'Version="' + $Version + '"';
    $NewVersion = 'Version=' + $Version + '';
    $NewAssyVersion = 'AssemblyVersion("' + $Version + '")';
    $NewFileVersion = 'AssemblyFileVersion("' + $Version + '")';
    $NewAppVersion = 'AppVersion="' + $Version + '"';
    $NewProjVersion = '<Version>' + $Version + '</Version>';


    $o = $file;

    Write-output $o.FullName
    $TmpFile = $o.FullName + ".tmp"
    get-content $o.FullName |
    ForEach-Object { $_ -replace 'version=\("[0-9]+(\.([0-9]+|\*)){1,3}"\)', $newVersion } |
    ForEach-Object { $_ -replace 'AssemblyVersion\("[0-9]+(\.([0-9]+|\*)){1,3}"\)', $NewAssyVersion } |
    ForEach-Object { $_ -replace 'AssemblyFileVersion\("[0-9]+(\.([0-9]+|\*)){1,3}"\)', $NewFileVersion } |
    ForEach-Object { $_ -replace 'AppVersion="[0-9]+(\.([0-9]+|\*)){1,3}"', $NewAppVersion } |
    ForEach-Object { $_ -replace 'Version="[0-9]+(\.([0-9]+|\*)){3,}"', $NewQVersion } |
    ForEach-Object { $_ -replace 'Version=[0-9]+(\.([0-9]+|\*)){3,}', $NewVersion } |
    ForEach-Object { $_ -replace '<Version>[0-9]+(\.([0-9]+|\*)){3,}</Version>', $NewProjVersion } > $TmpFile

    # Preserve UTF-8 encoding of AssemblyInfo tmp file
    $utf8Content = Get-Content $TmpFile -encoding utf8
    [System.IO.File]::WriteAllLines($TmpFile, $utf8Content)
    move-item $TmpFile $o.FullName -force

}

function Update-AllAssemblyInfoFiles ( $version ) {

    Write-Output $version

    if (!$PSScriptRoot) {
        $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent
    }

    $ScriptRootParent = Split-Path -parent $PSScriptRoot
    Write-Output 'ScriptRootParent: ' $ScriptRootParent

    $thisFolder = Join-Path $ScriptRootParent (Split-Path $PSScriptRoot -Leaf)
    Write-Output $thisFolder

    $excludeFolder = Join-Path $ScriptRootParent -ChildPath "TEST";
    Write-Output $excludeFolder


    $files = Get-ChildItem -Recurse -Path $ScriptRootParent -Filter AssemblyInfo.cs |
    Where-Object { $_.DirectoryName -ne $excludeFolder }

    foreach ($file in $files ) {
        Write-Output $file.DirectoryName
        Update-SourceVersion $file $version;
    }

    # Dot Net Core Projects
    $dotNetCoreProjectsToUpdate = @(
        'ClientStaticAssets.csproj'
    )
    
    $projectFile = Get-ChildItem -Recurse -Path $ScriptRootParent -Filter "*.csproj" |
    Where-Object { $dotNetCoreProjectsToUpdate -contains $_.Name }

        
    foreach ($file in $projectFile) {
        Write-Output $file.DirectoryName
        Update-SourceVersion $file $version;
    }

    $readmeFile =  Get-ChildItem -Recurse -Path $ScriptRootParent -Filter Readme.md |
        Where-Object {$_.DirectoryName -ne $excludeFolder } | Select-Object -First 1;

    Update-SourceVersion $readmeFile $version
}

# validate arguments
$r = [System.Text.RegularExpressions.Regex]::Match($args[0], "^[0-9]+(\.[0-9]+){1,3}$");
if ($r.Success) {
    Update-AllAssemblyInfoFiles $args[0];
}
else {
    Write-Output " ";
    Write-Output "Bad Input!"
    Write-Output " ";
    Usage ;
}

