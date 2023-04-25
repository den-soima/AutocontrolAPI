# *****************************************************************************
# This script creates a setup for Plant iT base, using the files currently in the dropfolder.
#
# Execute this script on a developer machine in the folder where the setup solution is located.
# The created installer will be located at .\Installer\Plant_iT_base_module_POC_DetailedScheduling.msi
#
# Eingangsparameter fuer Pfadangaben auf dem Buildserver
# Die Eingangsparameter entsprechen den "environment variables" des Buildtemplates
#
# [switch]$Disable                        aktivieren/deaktivieren des Scripts
# [string]$TF_BUILD_TOOLS_ROOT            Verzeichnis mit Build-Tools (Parameter am Build)  | Default = $Env wird vom BuildAgent gesetzt
# **************************************************************
#
param([string]$ModuleIdentName, [string]$BuildToolsRoot, [string]$SetupInputDirectory, [string]$FrontendInputDir, [string]$PowershellInput, [string]$SetupOutputDirectory,  [switch]$Devbuild)


# **************************************************************
# - PREPARE STEP: CWD auf der PS1-Pfad setzen.
#   WARUM: Wird gebraucht fuer Aufruf aus Buildagenten, weil
#          Skript intensiv mit relativen Pfaden arbeitet.
#   - Sonst muss Arbeitsverzeichnis im Build-Schritt festgelegt
#     werden und damit gaebe es eine Fehlerquelle mehr.
# **************************************************************
#
$PS1ScriptFolder = Split-Path (Get-Variable MyInvocation -Scope Script).Value.MyCommand.Path
$SetupProjFolder = "$PS1ScriptFolder\.."

Write-Host "Set current working directory relative to PS1-file folder: ($PS1ScriptFolder) ==> ($SetupProjFolder)"
Set-Location -Path "$SetupProjFolder"

# **************************************************************
# - PREPARE STEP: Init "constant" variables
# **************************************************************
#

# [string]$TFS_BUILD_SETUPFILE_BUNDLE_EXE = $TFS_BUILD_SETUPFILE_CORENAME + "_Setup.exe"

# **************************************************************
# - PREPARE STEP: Set params and command aliases
# **************************************************************
#
# Die Parameter immer aus den environments besorgen
[string]$BASEMODULE_IDENT_NAME = $Env:BASEMODULE_IDENT_NAME      # - "ConfigMgmt" waere hier ein Defaultwert
[string]$TFS_BUILD_TOOLS_ROOT = $Env:Build_Tools_Root
[string]$TFS_BUILD_INPUT_SETUP = "$Env:Build_Setup_Input_Directory"        # - frueher $Env:Build_Setup_Input_Directory
[string]$TFS_BUILD_INPUT_SETUP_FRONTEND = "$Env:Build_Setup_Frontend_Input_Directory"
[string]$TFS_BUILD_INPUT_SETUP_CONFIG = "$TFS_BUILD_INPUT_SETUP\Config"
[string]$TFS_BUILD_INPUT_SETUP_MODULEFILE = "$TFS_BUILD_INPUT_SETUP\DeploymentArtifacts"
[string]$TFS_BUILD_INPUT_SETUP_ENGINEERINGSCRIPTS = "$TFS_BUILD_INPUT_SETUP\DeploymentArtifacts\EngineeringScripts"
#[string]$TFS_BUILD_INPUT_SETUP_POWERSHELL = "$Env:Build_Setup_Input_Powershell"
[string]$TFS_BUILD_OUTPUT_SETUP = $Env:Build_Setup_Output_Directory            # - frueher $Env:Build_Setup_Output_Directory
[string]$TFS_DEVBUILD = $Env:TFS_DEVBUILD


If(-not ([string]::IsNullOrEmpty($TFS_BUILD_TOOLS_ROOT)))
{
    Write-Host "Environment-Variable <Build_Tools_Root>: " $TFS_BUILD_TOOLS_ROOT
}
ElseIf (-not ([string]::IsNullOrEmpty($BuildToolsRoot))) 
{
    $TFS_BUILD_TOOLS_ROOT = $BuildToolsRoot
    Write-Host "Parameter <BuildToolsRoot>: " $TFS_BUILD_TOOLS_ROOT
}
Else {
 Write-Host "Error: Erwarteter Inputparameter fehlt: <BuildToolsRoot>" -foregroundcolor red -backgroundcolor yellow
 exit 1;

}

If(-not ([string]::IsNullOrEmpty($TFS_BUILD_INPUT_SETUP)))
{
    Write-Host "Environment-Variable <BUILD_INPUT_SETUP>: " $TFS_BUILD_INPUT_SETUP
}
ElseIf (-not ([string]::IsNullOrEmpty($SetupInputDirectory))) 
{
    $TFS_BUILD_INPUT_SETUP = $SetupInputDirectory
    Write-Host "Parameter <SetupInputDirectory>: " $TFS_BUILD_INPUT_SETUP   
}
Else 
{
    Write-Host "Error: Erwarteter Inputparameter fehlt: <SetupInputDirectory>" -foregroundcolor red -backgroundcolor yellow
    exit 1;
}


If (-not ([string]::IsNullOrEmpty($TFS_BUILD_OUTPUT_SETUP))) 
{
   Write-Host "Parameter <OutputDir>: " $TFS_BUILD_OUTPUT_SETUP
 }
   ElseIf (-not ([string]::IsNullOrEmpty($SetupOutputDirectory))) {
        $TFS_BUILD_OUTPUT_SETUP = $SetupOutputDirectory
        Write-Host "Parameter <SetupOutputDirectory>: " $TFS_BUILD_OUTPUT_SETUP   
	
} Else {
    Write-Host "ERROR: Erwartete Inputparameter fehlt: <SetupOutputDirectory>" -foregroundcolor red -backgroundcolor yellow
    # TODO(ALM): !!!Fire build error here!!!
    exit 1;
}

If (-not ([string]::IsNullOrEmpty($BASEMODULE_IDENT_NAME))) 
{
   Write-Host "Parameter <ModuleIdentName>: " $BASEMODULE_IDENT_NAME
 }
    ElseIf (-not ([string]::IsNullOrEmpty($ModuleIdentName))) 
    {
        $BASEMODULE_IDENT_NAME = $ModuleIdentName
        Write-Host "Parameter <ModuleIdentName>: " $BASEMODULE_IDENT_NAME   
	}
Else {
    Write-Host "ERROR: Erwartete Inputparameter fehlt: <ModuleIdentName>" -foregroundcolor red -backgroundcolor yellow
    # TODO(ALM): !!!Fire build error here!!!
    exit 1;
}

if(-not ([string]::IsNullOrEmpty($TFS_BUILD_INPUT_SETUP_FRONTEND)))
{
Write-Host "Parameter <FrontendInputDir>: " $TFS_BUILD_INPUT_SETUP_FRONTEND
}
ElseIf (-not ([string]::IsNullOrEmpty($FrontendInputDir)))
{
$TFS_BUILD_INPUT_SETUP_FRONTEND = $FrontendInputDir
Write-Host "Parameter <FrontendInputDir>: " $TFS_BUILD_INPUT_SETUP_FRONTEND
}
Else{
Write-Host "ERROR: Erwartete Inputparameter fehlt: <FrontendInputDir>" -foregroundcolor red -backgroundcolor yellow
}

#If (-not ([string]::IsNullOrEmpty($TFS_BUILD_INPUT_SETUP_POWERSHELL))) 
#{
#   Write-Host "Parameter <PowershellInput>: " $TFS_BUILD_INPUT_SETUP_POWERSHELL
#}
#    ElseIf (-not ([string]::IsNullOrEmpty($PowershellInput))) {
#        $TFS_BUILD_INPUT_SETUP_POWERSHELL = $PowershellInput
#        Write-Host "Parameter <PowershellInput>: " $TFS_BUILD_INPUT_SETUP_POWERSHELL  
#	}
#Else {
#    Write-Host "ERROR: Erwartete Inputparameter fehlt: <PowershellInput>" -foregroundcolor red -backgroundcolor yellow
#    # TODO(ALM): !!!Fire build error here!!!
#    exit 1;
#}

If (-not ([string]::IsNullOrEmpty($TFS_DEVBUILD))) 
{
   Write-Host "Parameter <Devbuild>: " $TFS_DEVBUILD
}
    ElseIf ($Devbuild) {
        $TFS_DEVBUILD = "true"
        Write-Host "Parameter <Devbuild>: " $TFS_DEVBUILD  
	}

[string]$TFS_BUILD_SETUPFILE_CORENAME = "Plant_iT_base_module_$BASEMODULE_IDENT_NAME"

# Aliases fuer verwendete WiX-Tools setzen, damit diese Tools aus dem ausgecheckten Ordner kommen (installationsfrei)
Set-Alias heat   "$TFS_BUILD_TOOLS_ROOT\WiX3.11\bin\heat.exe"
Set-Alias candle "$TFS_BUILD_TOOLS_ROOT\WiX3.11\bin\candle.exe" 
Set-Alias light  "$TFS_BUILD_TOOLS_ROOT\WiX3.11\bin\light.exe"



# **************************************************************
# - WORKING PART
# **************************************************************
#
# Input-Ordner kann noch compile-Dateien enthalten, daher einige entfernen
# Parameters:
del "$TF_BUILD_INPUT_SETUP\*.pdb"
del "$TF_BUILD_INPUT_SETUP\*.TestApp*.*"
del "$TF_BUILD_INPUT_SETUP\*.UnitTests*.*"
del "$TF_BUILD_INPUT_SETUP\*\*.TestPlatform*.*"

# **************************************************************
# - WiX PART
# **************************************************************
#
# Harvesting all files from the drop folder.
# Parameters:
# -cg Name of component group files will be added to
# -dr directory files will be installed to
# C:\Tools\WiX3.11\bin\heat.exe dir "$TFS_BUILD_INPUT_SETUP_BIN" `

heat dir "$TFS_BUILD_INPUT_SETUP_CONFIG" `
	-cg cgrp_Files_ConfigFiles `
	-dr dir_BASETEMPLATE_PROJECT_CONFIG_DIR_FOR_MODULE `
	-gg -g1 -scom -sreg -srd `
	-var "var.DropFolderModuleConfiguration" `
	-out .\Components\cgrp_Files_ModuleConfigurations.wxs

heat dir "$TFS_BUILD_INPUT_SETUP_CONFIG" `
	-cg cgrp_Files_ConfigFileBackup `
	-dr dir_PROJECT_CONFIG_DIR_FOR_MODULE `
	-gg -g1 -scom -sreg -srd `
	-var "var.DropFolderModuleConfiguration" `
	-t .\stylesheet.xslt `
	-out .\Components\cgrp_Files_ModuleConfigurationBackups.wxs

heat dir "$TFS_BUILD_INPUT_SETUP_ENGINEERINGSCRIPTS" `
    -cg cgrp_Files_Engineeringscripts `
    -dr dir_PROJECT_ENGINEERING_MODULE `
    -gg -g1 -scom -sreg -srd `
    -var "var.DropFolderEngineeringscripts" `
    -out .\Components\cgrp_Files_Engineeringscripts.wxs



#heat dir "$TFS_BUILD_INPUT_SETUP_POWERSHELL" `
#    -cg cgrp_Files_Powershell `
#    -dr DIR_BASEPOWERSHELL_BIN `
#    -gg -g1 -scom -sreg -srd `
#    -var "var.DropFolderPowershell" `
#    -out .\Components\cgrp_Files_Powershell.wxs

heat dir "$TFS_BUILD_INPUT_SETUP" `
    -cg cgrp_Files_Binaries `
    -dr DIR_BASEMODULE_BIN `
    -gg -g1 -scom -sreg -srd `
    -var "var.DropFolder" `
    -out .\Components\cgrp_Files_Binaries.wxs



# Compile to .wixobj

#      .\Components\cgrp_Files_Powershell.wxs `
#      -dDropFolderPowershell="$TFS_BUILD_INPUT_SETUP_POWERSHELL" `
#C:\Tools\WiX3.11\bin\candle.exe `
candle `
      -arch "x64" `
      .\Product.wxs `
      .\Directories.wxs `
      .\ComponentGroups.wxs `
      .\ComponentRegistryGroups.wxs `
      .\Components\cgrp_Files_Engineeringscripts.wxs `
      .\Components\cgrp_Files_Binaries.wxs `
      .\Components\cgrp_Files_ModuleConfigurations.wxs `
      .\Components\cgrp_Files_ModuleConfigurationBackups.wxs `
      .\Dialogs\WixUI_Mondo_Custom.wxs `
      .\Dialogs\PlantiT_WelcomeDlg.wxs `
      -ext WixUIExtension `
      -ext WixNetFxExtension `
      -dBASEMODULE_IDENT_NAME="$BASEMODULE_IDENT_NAME" `
      -dSETUPFILECORENAME="$TFS_BUILD_SETUPFILE_CORENAME" `
      -dDropFolder="$TFS_BUILD_INPUT_SETUP" `
	  -dDropFolderEngineeringscripts="$TFS_BUILD_INPUT_SETUP_ENGINEERINGSCRIPTS" `
      			-dDropFolderModuleFile="$TFS_BUILD_INPUT_SETUP_MODULEFILE" `
			-dDropFolderModuleConfiguration="$TFS_BUILD_INPUT_SETUP_CONFIG" `
      -out .\Wixobj\    # directory must exist


# Link all files created in the previous step
# German-Locale
#C:\Tools\WiX3.11\bin\light.exe   .\Wixobj\*.wixobj `
light .\Wixobj\*.wixobj `
      -spdb `
      -ext WixUIExtension `
      -ext WixNetFxExtension `
      -cultures:de-de `
      -loc de-de\$TFS_BUILD_SETUPFILE_CORENAME.wxl `
      -dWixUILicenseRtf="Resources\License_de-DE.rtf" `
      -out "$TFS_BUILD_OUTPUT_SETUP\de-de\$TFS_BUILD_SETUPFILE_CORENAME.msi"

if([string]::IsNullOrEmpty($TFS_DEVBUILD))
{
# English-Locale
#C:\Tools\WiX3.11\bin\light.exe   .\Wixobj\*.wixobj `
light .\Wixobj\*.wixobj `
      -spdb `
      -ext WixUIExtension `
      -ext WixNetFxExtension `
      -cultures:en-us `
      -loc en-us\$TFS_BUILD_SETUPFILE_CORENAME.wxl `
      -dWixUILicenseRtf="Resources\License_en-US.rtf" `
      -out "$TFS_BUILD_OUTPUT_SETUP\en-us\$TFS_BUILD_SETUPFILE_CORENAME.msi"
}
