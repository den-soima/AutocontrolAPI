param([Parameter(Position=0,mandatory=$true)][string]$FrontendServiceName, [Parameter(Position=1,mandatory=$true)][string]$WixInputDir)


$SetupInputDirFrontend = $ClientAppDir.Parent.FullName + "\wwwroot" 
$SetupInputFrontendComponentGroupName = "cgrp_Files_" + $FrontendServiceName + "Frontend"
$SetupInputFrontendDropFolder = "var.DropFolderFrontend"
$SetupInputFrontendHeatFileDir = $WixInputDir + "\Frontends\cgrp_Files_" + $FrontendServiceName + "Frontend.wxs"
$WwwrootIdName = "DIR_PITWEBAPPROOT_MODULESERVICE_" + $FrontendServiceName + "_wwwroot"

heat dir "$SetupInputDirFrontend" `
		-cg $SetupInputFrontendComponentGroupName `
		-dr $WwwrootIdName `
		-gg -g1 -scom -sreg -srd `
		-var $SetupInputFrontendDropFolder `
		-out $SetupInputFrontendHeatFileDir

#↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓#
#――――――――――――――――――――――――――――――――――――――――――#
# START: Compile new WSX-File to Wixobj
#――――――――――――――――――――――――――――――――――――――――――#
#↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑#

candle `
			-arch "x64" `
			$SetupInputFrontendHeatFileDir `
			-dDropFolderFrontend="$SetupInputDirFrontend" `
			-out $SetupFolder\Wixobj\    # directory must exist