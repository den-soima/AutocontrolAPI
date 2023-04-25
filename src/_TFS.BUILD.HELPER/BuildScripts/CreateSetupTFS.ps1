param([Parameter(Position=0,mandatory=$true)][string]$SetupInputDir, [Parameter(Position=1,mandatory=$true)][string]$ModuleName, [Parameter(Position=2,mandatory=$true)]$BuildToolsDir, [Parameter(Position=3,mandatory=$true)][string]$SetupFolder, [Parameter(Position=4,mandatory=$true)][string]$SetupOutputDir)
[string]$SetupInputModuleDir = "$SetupInputDir\Module"
[string]$mSetupInputPowershellDir = "$SetupInputDir\Powershell"
[string]$mSetupInputDirEngineeringScripts = "$SetupInputModuleDir\DeploymentArtifacts\EngineeringScripts"
[string]$mSetupInputDirModuleConfiguration = "$SetupInputModuleDir\Config"
[string]$mSetupInputDirModuleFile = "$SetupInputModuleDir\DeploymentArtifacts"
[string]$TFS_BUILD_SETUPFILE_CORENAME = "Plant_iT_base_module_$ModuleName"

Set-Alias heat   "$BuildToolsDir\WiX3.11\bin\heat.exe"
Set-Alias candle "$BuildToolsDir\WiX3.11\bin\candle.exe" 
Set-Alias light  "$BuildToolsDir\WiX3.11\bin\light.exe"

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
del "$SetupInputDir\*.pdb"
del "$SetupInputDir\*.TestApp*.*"
del "$SetupInputDir\*.UnitTests*.*"
del "$SetupInputDir\*.TestPlatform*.*"


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
		-cg cgrp_Files_ConfigFiles `
		-dr dir_BASETEMPLATE_PROJECT_CONFIG_DIR_FOR_MODULE `
		-gg -g1 -scom -sreg -srd `
		-var "var.DropFolderModuleConfiguration" `
		-out .\Components\cgrp_Files_ModuleConfigurations.wxs

heat dir "$mSetupInputDirModuleConfiguration" `
		-cg cgrp_Files_ConfigFileBackup `
		-dr dir_PROJECT_CONFIG_DIR_FOR_MODULE `
		`-gg -g1 -scom -sreg -srd `
		-var "var.DropFolderModuleConfiguration" `
		-t .\stylesheet.xslt `
		-out .\Components\cgrp_Files_ModuleConfigurationBackups.wxs






# Compile to .wixobj
#C:\Tools\WiX3.11\bin\candle.exe `
candle `
			-arch "x64" `
			$SetupInputDir\Wix\Product.wxs `
			$SetupInputDir\Wix\Directories.wxs `
			.\ComponentGroups.wxs `
			.\ComponentRegistryGroups.wxs `
			.\Dialogs\PlantiT_WelcomeDlg.wxs `
			.\Dialogs\WixUI_Mondo_Custom.wxs `
			.\Components\cgrp_Files_ModuleConfigurations.wxs `
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
			-out "$SetupOutputDir\de-de\$TFS_BUILD_SETUPFILE_CORENAME.msi"

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
			-out "$SetupOutputDir\en-us\$TFS_BUILD_SETUPFILE_CORENAME.msi"


