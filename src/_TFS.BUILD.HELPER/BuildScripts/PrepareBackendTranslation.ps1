<#
Prepare backend texts (.resx files) to be translated.

Flatten names and copy to $translate folder.

ATTENTION: this script has to be executed BEFORE copying translated artifacts!
The translated .resx files are copied to the same resources folder as the original ones. This step copies ALL files from this folder to ToTranslate.
In consequence, if the translated files are copied before this stept, they would end up in ToTranslate.
#>

param(
    [Parameter(Mandatory=$true, HelpMessage="Location, where the script should be exceuted, i.e. the directory containing the .sln file.
                                            Typically: `$(build.sourcesDirectory)\src\Module ")]
    [string]$scriptExecutionDir,
    [Parameter(Mandatory=$true, HelpMessage="Directory for collecting texts to be translated. Typically: `$(Build_ResultFolder_TRANSLATE)")]
    [string]$translationDir,
    [Parameter(Mandatory=$true, HelpMessage="The Techname of the module to be built. Typically: `$(BASEMODULE_IDENT_NAME)")]
    [string]$moduleName
)

Write-Host Using the following parameters:
Write-Host scriptExecutionDir = $scriptExecutionDir
Write-Host translationDir = $translationDir
Write-Host moduleName = $moduleName

Write-Host Copying all .resx files to ToTranslate directory.


Set-Location $scriptExecutionDir

foreach ($file in Get-ChildItem . -Filter "*.resx" -File -Recurse) {
    # Create a unique file name: Take the file path (relative from the solution folder) and replace
    # each \ by &. In addition, prepend the module name. 
    $relPath = Resolve-Path -Path $file.FullName -Relative
    $newName = $moduleName + $relPath.TrimStart(".").Replace("\", "&")
    Copy-Item $file.FullName -Destination $translationDir\$newname
    Write-Host Copied $file.FullName as $newname to $translationDir
}

Write-Host Copying resources to ToTranslate successful.

# Return to the directory where the script is located
Set-Location $PSScriptRoot
