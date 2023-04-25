# **************************************************************************************************************
# This script builds Plant it Base Module Service Projects . 						
# Then creates a a setup using build result as input.															
#																												
# Execute this script on a developer machine in the folder where it was created by the Module Service Template  
# The created installer will be located at .\SetupOutput\de-de\Plant_iT_base_module_Moddy.msi			
#                                      and .\SetupOutput\en-en\Plant_iT_base_module_Moddy.msi																												#
# **************************************************************************************************************

# Set Alias for the WiX-Tools for Setup building.

# ****************************************************************************
# - PREPARE STEP: CWD set to path of ps1 script								  
#   WHY?: It´s needed because the script is working a lot with relative paths 
# ****************************************************************************

$PS1ScriptFolder = Split-Path (Get-Variable MyInvocation -Scope Script).Value.MyCommand.Path

Write-Host "Set current working directory to Module folder: $PS1ScriptFolder\..\..\src"

Set-Location -Path "$PS1ScriptFolder\..\..\src"

#↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓#
#――――――――――――――――――――――――――――――――――――――――――#
# START: Prepare Common Variables
#――――――――――――――――――――――――――――――――――――――――――#
#↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑#

$SetupFolder = "$PS1ScriptFolder\.."

[string]$mBuild_Setup_Input_Directory = $Env:Build_Setup_Input_Directory

if($mBuild_Setup_Input_Directory)
{
    [string]$SetupInputDir = $mBuild_Setup_Input_Directory
}
else
{
    [string]$SetupInputDir = "$SetupFolder\SetupInput"
}

[string]$mBuild_Setup_Output_Directory = $Env:Build_Setup_Output_Directory

if($mBuild_Setup_Output_Directory)
{
    [string]$mSetupOutputDir = $mBuild_Setup_Output_Directory
}
else
{
    [string]$mSetupOutputDir = "$SetupFolder\SetupOutput"
}

[string]$ModuleName = $Env:BASEMODULE_IDENT_NAME
if([string]::IsNullOrEmpty($ModuleName)){
$ModuleName = (Get-ChildItem .\ *.sln -Recurse -File).BaseName}

$SetupInputModuleDir = "$SetupInputDir\Module"
[string]$mSetupInputPowershellDir = "$SetupInputDir\Powershell"
[string]$mSetupInputDirEngineeringScripts = "$SetupInputModuleDir\DeploymentArtifacts\EngineeringScripts"
[string]$mSetupInputDirModuleConfiguration = "$SetupInputModuleDir\Config"
[string]$mSetupInputDirModuleFile = "$SetupInputModuleDir\DeploymentArtifacts"
[string]$TFS_BUILD_SETUPFILE_CORENAME = "Plant_iT_base_module_$ModuleName"

[string]$mBuild_Tools_Root = $Env:Build_Tools_Root

if($mBuild_Tools_Root){
    [string] $BuildToolsDir = $mBuild_Tools_Root}
else{
    [string] $BuildToolsDir = "C:\ProLeiT\SDK\3RDParty"}

Set-Alias heat   "$BuildToolsDir\WiX3.14\bin\heat.exe"
Set-Alias candle "$BuildToolsDir\WiX3.14\bin\candle.exe" 
Set-Alias light  "$BuildToolsDir\WiX3.14\bin\light.exe"


if([string]::IsNullOrEmpty($ModuleName)) {
Write-Error "No module found !"
return
}
else{

Write-Host "Modul $ModuleName found."

}

#↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓#
#――――――――――――――――――――――――――――――――――――――――――#
# START: Prepare Setup Input Dir
#――――――――――――――――――――――――――――――――――――――――――#
#↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑#

& "$PS1ScriptFolder\..\..\_TFS.BUILD.HELPER\BuildScripts\CreateTempWixFiles.ps1" -SetupFolder "$SetupFolder" -SetupInputDir "$SetupInputDir"

#↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓#
#――――――――――――――――――――――――――――――――――――――――――#
# START: Build dotnet core Backend
#――――――――――――――――――――――――――――――――――――――――――#
#↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑#


Write-Host "Build $ModuleName.sln with the command: dotnet publish $ModuleName.sln -c debug -r win10-x64 --self-contained -o $SetupFolder\SetupInput\Modul"

dotnet publish $ModuleName.sln -c debug -r win10-x64 --self-contained -o "$SetupInputModuleDir"

#↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓#
#――――――――――――――――――――――――――――――――――――――――――#
# START: Search for Frontends
#――――――――――――――――――――――――――――――――――――――――――#
#↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑#

$ClientAppDirs = Get-ChildItem .\ ClientApp -Recurse -Directory

ForEach($ClientAppDir in $ClientAppDirs){
$FrontendServiceName = $ClientAppDir.Parent -replace ".Host", ""


Write-Host "Frontend found in the Project: $FrontendServiceName" 


#↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓#
#――――――――――――――――――――――――――――――――――――――――――#
# START: Search for node_modules directory of Frontends, start NPM install if not available
#――――――――――――――――――――――――――――――――――――――――――#
#↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑#
if(Get-ChildItem $ClientAppDir.Fullname node_modules -Directory){}
else
{
Write-Host "node_modules for $FrontendServiceName not found, starting npm install"
Set-Location -Path $ClientAppDir.FullName
npm install 

if($LASTEXITCODE -igt 0)
{
Write-Error "npm install for $FrontendServiceName failed."
return $LASTEXITCODE
}

}

#↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓#
#――――――――――――――――――――――――――――――――――――――――――#
# START: Build Frontend
#――――――――――――――――――――――――――――――――――――――――――#
#↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑#


Write-Host "Build Frontend for Project: $FrontendServiceName"


$ClientAppDirFullname = $ClientAppDir.FullName
& "$PS1ScriptFolder\..\..\_TFS.BUILD.HELPER\BuildScripts\BuildLocalizedAngularApps.ps1" -scriptExecutionDir "$ClientAppDirFullname" -fromTranslationDir "$PS1ScriptFolder" -toTranslationDir "$PS1ScriptFolder" -moduleName $ModuleName -serviceName $FrontendServiceName -mergeXliffPath "$PS1ScriptFolder\..\..\_TFS.BUILD.HELPER\Tools\MergeXliff\MergeXliff.exe"

$SetupInputFrontendComponentGroupName = "cgrp_Files_" + $FrontendServiceName + "Frontend"

& "$PS1ScriptFolder\..\..\_TFS.BUILD.HELPER\BuildScripts\AddFrontendServiceDirectory.ps1" -FrontendServiceName "$FrontendServiceName" -WixInputDir "$SetupInputDir\Wix"

& "$PS1ScriptFolder\..\..\_TFS.BUILD.HELPER\BuildScripts\CreateWixObjForFrontend.ps1" -FrontendServiceName "$FrontendServiceName" -WixInputDir "$SetupInputDir\Wix"


Write-Host "Add the new Service to the Product.wsx"

## Add new Service to Product.wxs

& "$PS1ScriptFolder\..\..\_TFS.BUILD.HELPER\BuildScripts\AddFrontendServiceProduct.ps1" -SetupInputFrontendComponentGroupName "$SetupInputFrontendComponentGroupName" -WixInputDir "$SetupInputDir\Wix"


}


#↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓#
#――――――――――――――――――――――――――――――――――――――――――#
# START: Build the Setup
#――――――――――――――――――――――――――――――――――――――――――#
#↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑#


Write-Host "Set current working directory to Setup folder: $SetupFolder"


Set-Location -Path "$SetupFolder"

# **************************************************************
# - WORKING PART
# **************************************************************
#
# Delete unnecessary files from Setup input directory
del "$SetupFolder\SetupInput\*.pdb"
del "$SetupFolder\SetupInput\*.TestApp*.*"
del "$SetupFolder\SetupInput\*.UnitTests*.*"
del "$SetupFolder\SetupInput\*\*.TestPlatform*.*"


# **************************************************************
# - WiX PART
# **************************************************************
#
# Harvesting all files from the drop folder.
# Parameters:
# -cg Name of component group files will be added to
# -dr directory files will be installed to
# C:\Tools\WiX3.11\bin\heat.exe dir "$mSetupInputDir" `
heat dir "$SetupInputModuleDir" `
		-cg cgrp_Files_Binaries `
		-dr DIR_BASEMODULE_BIN `
		-gg -g1 -scom -sreg -srd `
		-var "var.DropFolder" `
		-out .\Components\cgrp_Files_Binaries.wxs

heat dir "$mSetupInputDirEngineeringScripts" `
		-cg cgrp_Files_Engineeringscripts `
		-dr dir_PROJECT_ENGINEERING_MODULE `
		-gg -g1 -scom -sreg -srd `
		-var "var.DropFolderEngineeringscripts" `
		-out .\Components\cgrp_Files_Engineeringscripts.wxs


heat dir "$mSetupInputDirModuleConfiguration" `
	-cg cgrp_Files_ConfigFileBackup `
	-dr dir_BASETEMPLATE_PROJECT_CONFIG_DIR_FOR_MODULE `
	-gg -g1 -scom -sreg -srd `
	-var "var.DropFolderModuleConfiguration" `
	-out .\Components\cgrp_Files_ModuleConfigurationBackups.wxs







# Compile to .wixobj
#C:\Tools\WiX3.11\bin\candle.exe `
candle `
			-arch "x64" `
			$SetupFolder\SetupInput\Wix\Product.wxs `
			$SetupFolder\SetupInput\Wix\Directories.wxs `
			.\ComponentConfigFilesGroups.wxs `
			.\ComponentGroups.wxs `
			.\ComponentRegistryGroups.wxs `
			.\Dialogs\PlantiT_WelcomeDlg.wxs `
			.\Dialogs\WixUI_Mondo_Custom.wxs `
			.\Components\cgrp_Files_ModuleConfigurationBackups.wxs `
			.\Components\cgrp_Files_Engineeringscripts.wxs `
			.\Components\cgrp_Files_Binaries.wxs `
			-ext WixUIExtension `
			-ext WixNetFxExtension `
            -dBASEMODULE_IDENT_NAME="$ModuleName" `
			-dSETUPFILECORENAME="$TFS_BUILD_SETUPFILE_CORENAME" `
			-dDropFolderModuleFile="$mSetupInputDirModuleFile" `
			-dDropFolderModuleConfiguration="$mSetupInputDirModuleConfiguration" `
			-dDropFolderEngineeringscripts="$mSetupInputDirEngineeringScripts" `
			-dDropFolder="$SetupInputModuleDir" `
			-out .\Wixobj\    # directory must exist

# Link all files created in the previous step
# German-Locale
#C:\Tools\WiX3.11\bin\light.exe   .\Wixobj\*.wixobj `
light .\Wixobj\*.wixobj `
			-spdb `
			-dDropFolder="$SetupInputModuleDir" `
			-ext WixUIExtension `
			-ext WixNetFxExtension `
			-cultures:de-de `
			-loc de-de\Plant_iT_base_module_$ModuleName.wxl `
			-dWixUILicenseRtf="Resources\License_de-DE.rtf" `
			-out "$mSetupOutputDir\de-de\$TFS_BUILD_SETUPFILE_CORENAME.msi"

# English-Locale
#C:\Tools\WiX3.11\bin\light.exe   .\Wixobj\*.wixobj `
light .\Wixobj\*.wixobj `
			-spdb `
			-dDropFolder="$SetupInputModuleDir" `
			-ext WixUIExtension `
			-ext WixNetFxExtension `
			-cultures:en-us `
			-loc en-us\Plant_iT_base_module_$ModuleName.wxl `
			-dWixUILicenseRtf="Resources\License_en-US.rtf" `
			-out "$mSetupOutputDir\en-us\$TFS_BUILD_SETUPFILE_CORENAME.msi"


