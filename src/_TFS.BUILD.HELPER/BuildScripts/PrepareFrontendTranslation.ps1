<#
Prepare all frontend texts for translation:
    - one .xlf file
#>

param(
    [Parameter(Mandatory=$true, HelpMessage="Location, where the Module Solution is localated")]
    [string]$sourceDir,
    [Parameter(Mandatory=$true, HelpMessage="Directory for collecting texts to be translated. Typically: `$(Build_ResultFolder_TRANSLATE)")]
    [string]$translationDir,
    [Parameter(Mandatory=$false, HelpMessage="Path to the SPlitXliff.exe (without filename).")]
    [string]$splitXliffPath = $(Join-Path -Path $PSScriptRoot -ChildPath "../Tools/SplitXliff/"),
    [Parameter(Mandatory=$false, HelpMessage="Name of the target translatione files (json + xlf)")]
    [string]$translationFileName = $moduleName + "_" + $serviceName
)
$ClientAppDirs = Get-ChildItem $sourceDir ClientApp -Recurse -Directory

ForEach($ClientAppDir in $ClientAppDirs){

$moduleName = (Get-ChildItem $sourceDir *.sln -Recurse -File).BaseName
$serviceName = $ClientAppDir.Parent -replace ".Host", ""
[string]$translationFileName = $moduleName + "_" + $serviceName
	
Write-Host Using the following parameters:
Write-Host scriptExecutionDir = $scriptExecutionDir
Write-Host translationDir = $translationDir
Write-Host serviceName = $serviceName
Write-Host splitXliffPath = $splitXliffPath
Write-Host translationFileName = $translationFileName

Set-Location $ClientAppDir


# Xlf file
# 1. Generate the file. It contains texts in german (written by us) and english (written by Kendo).
# 2. Split in two files, each having only one source language.
#    Output of the split too is $translation dir (for both files)
#    The kendo and mixed file are not sent to TechDoc team because they are blacklisted.

Write-Host Running ng extract-i18n
npm run ng_extract-i18n -- --out-file="$translationDir\$($translationFileName)_mixed.xlf"


Write-Host Split Xliff

$inFile = "$translationDir/$($translationFileName)_mixed.xlf"
$outDe = "$translationDir/$($translationFileName).xlf"
$outEn = "$translationDir/$($translationFileName)_kendo.xlf"

Set-Location $splitXliffPath
& .\SplitXliff.exe --in $inFile --outDe $outDe --outEn $outEn

Set-Location $PSScriptRoot
}
