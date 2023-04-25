<#
Assumed project structure
-------------------------
For sample module "webportal" with sample service "home".


home.Host
    - ClientApp
        - src
            - app
    - wwwroot


Assumed structure of the translation directory
-----------------------------------------------
(after fetching the artifacts)

$FROM_TRANSLATE
    - Translate
        - de
            kendo.xlf (traget texts in german)
        - en
            webportal_home.xlf (target texts in proleit-english)
            kendo.xlf (kendo texts in proleit-english)
        - fr (es, pt, ...)
            webportal_home.xlf (target texts in proleit-english)
            kendo.xlf (kendo texts in proleit-english)

Script execution
----------------
Script has to be executed in the Client App directory.
#>

param(
    [Parameter(Mandatory=$true, HelpMessage="Location, where the script should be exceuted - typically the ClienApp directory")]
    [string]$scriptExecutionDir,
    [Parameter(Mandatory=$true, HelpMessage="Directory containing the translations fetched FROMTRANSLATE.")]
    [string]$fromTranslationDir = $(Join-Path -Path $scriptExecutionDir -ChildPath "src/translation" ),
    [Parameter(Mandatory=$true, HelpMessage="Directory containing the translations created by XI18N.")]
    [string]$toTranslationDir,
    [Parameter(Mandatory=$true, HelpMessage="The Techname of the module to be built.")]
    [string]$moduleName,
    [Parameter(Mandatory=$true, HelpMessage="The Techname of the service to be built.")]
    [string]$serviceName,
    [Parameter(Mandatory=$false, HelpMessage="The output folder for the angular builds relative to the <scriptExecutionDir>, typically the wwwroot of the module service. Default:/../wwwroot")]
    [string]$wwwroot = "../wwwroot",
    [Parameter(Mandatory=$false, HelpMessage="Path to the MergeXliff.exe (including filename and extension).")]
    [string]$mergeXliffPath = $(Join-Path -Path $PSScriptRoot -ChildPath "../Tools/MergeXliff/MergeXliff.exe"),
    [Parameter(Mandatory=$false, HelpMessage="Name of the source translatione files (json + xlf)")]
    [string]$translationFileName = $moduleName + "_" + $serviceName,
    [Parameter(Mandatory=$false, HelpMessage="Mode to build DEV or RTM")]
    [string]$BuildMode = "DEV"
)


Write-Host Using the following parameters:
Write-Host scriptExecutionDir = $scriptExecutionDir
Write-Host fromTranslationDir = $fromTranslationDir
Write-Host toTranslationDir = $toTranslationDir
Write-Host moduleName = $moduleName
Write-Host serviceName = $serviceName
Write-Host wwwroot = $wwwroot
Write-Host mergeXliffPath = $mergeXliffPath
Write-Host translationFileName = $translationFileName

## REGION: Helper functions
function SaveAngularJSON(){
	$angularJsonPath = "$scriptExecutionDir\angular.json"
	$angularJsonSavePath = "$scriptExecutionDir\BACKUP_angular.json"
	if(Test-Path -Path $angularJsonSavePath)
	{
		Remove-Item -path $angularJsonSavePath -recurse -force
	}
	Copy-Item $angularJsonPath -Destination $angularJsonSavePath
}

function RestoreAngularJSON(){
	$angularJsonPath = "$scriptExecutionDir\angular.json"
	$angularJsonSavePath = "$scriptExecutionDir\BACKUP_angular.json"
	Copy-Item $angularJsonSavePath -Destination $angularJsonPath 
	Remove-Item -path $angularJsonSavePath
}

function WriteWarningOrErrorAndExit([string]$message) {
    if ( $BuildMode -Eq "RTM") {
        Write-Error $message
        Write-Error "Script runs in RTM-Mode and will not continue."
        Exit
    } else {
        Write-Warning $message
        Write-Warning "Script runs not in RTM-Mode and will continue."
    }
    Write-Host "Setting i18nMissingTranslation to $i18nMissingTranslation"
}
function RemoveLocaleInAngularJson([string]$locale) {
    $angularJsonPath = "$scriptExecutionDir\angular.json"
    $angularJsonContent = Get-Content $angularJsonPath -raw | ConvertFrom-Json

    Write-Host "Remove element i18n.locales.$locale in angular.json."
    $angularJsonContent.projects.PSObject.Properties.Value[0].i18n.locales.PSObject.Properties.Remove($locale)
    $angularJsonContent | ConvertTo-Json -depth 100 | set-content $angularJsonPath
}
function CountLocalesInAngularJSON() {
    $angularJsonPath = "$scriptExecutionDir\angular.json"
    $angularJsonContent = Get-Content $angularJsonPath -raw | ConvertFrom-Json

    $angularLocales = $angularJsonContent.projects.PSObject.Properties.Value[0].i18n.locales.PSObject.Properties
    $count = 0
    ForEach ($locale in $angularLocales) {
        $count ++
    }
    $count
}

function ReplaceStringInFiles([string]$targetDirectory, [string]$sourceString, [string]$targetString) {
    ForEach ( $ngFile in (Get-ChildItem $targetDirectory -File)) {
        Write-Host "Replacing every string in $targetDirectory\$ngFile with $sourceString by $targetString."
        (Get-Content $targetDirectory\$ngFile).replace($sourceString, $targetString) | Set-Content $targetDirectory\$ngFile
    } 
}

## ENDREGION: Helper functions


################################################################
# Preparation                                                  #
################################################################

Set-Location $scriptExecutionDir

# Make moduleName and serviceName all lower case as needed later in URIs.
$moduleName = $moduleName.ToLower()
$serviceName = $serviceName.ToLower()

# create temp angular.json
SaveAngularJSON

# create output directory
if (-Not(Test-Path -Path $wwwroot)) {
    New-Item -ItemType Directory -Name $wwwroot
}

# create Translations directory for execution
if (-Not(Test-Path -Path $scriptExecutionDir/Translations)) {
    New-Item -ItemType Directory -Path $scriptExecutionDir -Name Translations
}

# Error if translations are missing during RTM-Build
if ( $BuildMode -Eq "RTM") {
    $i18nMissingTranslation = "error" 
} else {
    $i18nMissingTranslation = "ignore"
}
Write-Host "i18nMissingTranslation: $i18nMissingTranslation"

$defaultLocales = "de","en","es","fr","nl","pt","ru","zh"
Write-Host "defaultLocales: $defaultLocales"

###########################################################################
# Prepare XLF-File for every locale                                       #
#    - for DE: fetch I18N-Result before                                   #
#    - for DE, EN,ES,FR ... merge kendo.xlf and $translationFilename.xlf  # 
#                                                                         #
# Translation-Target needs to be like defined in angular.json             #
#      - Translation/de/webportal_home.xlf                                #
#      - Translation/en/webportal_home.xlf                                #
#      - [...]                                                            #
###########################################################################

# fetch I18N-Result for de
$deFromTranslation =  "$fromTranslationDir/TRANSLATE/de/$translationFileName.xlf"
$deToTranslation = "$toTranslationDir/$translationFileName.xlf"

if (Test-Path -Path $fromTranslationDir/TRANSLATE/de) {
    if (Test-Path -Path $deToTranslation) {
        Copy-Item $deToTranslation -Destination $deFromTranslation
        (Get-Content $deFromTranslation -Encoding UTF8).replace("<source>", "<target>").replace("</source>", "</target>") | Set-Content $deFromTranslation -Encoding UTF8
    } else {
        WriteWarningOrErrorAndExit("XLF-File for de does not exist in FROMTRANSLATE.")
    }
} else {
    WriteWarningOrErrorAndExit("de in FROMTRANSLATE-Path does not exist.")
}

# prepare xlf-file for every locale and disable locale in angular.json (if XLF does not exist)
ForEach ($locale in $defaultLocales) {

    if (-Not(Test-Path -Path $fromTranslationDir/TRANSLATE/$locale/$translationFileName.xlf)) {
        WriteWarningOrErrorAndExit("Required XLF-File for locale $locale missing.")   
        RemoveLocaleInAngularJson -locale $locale 
    } else {  

        if (-Not(Test-Path -Path $scriptExecutionDir/Translations/$locale)) {
            New-Item -ItemType Directory -Path $scriptExecutionDir/Translations -Name $locale
        }    

        $kendoFilePath = "$fromTranslationDir/TRANSLATE/$locale/kendo.xlf"
        $baseFilePath = "$fromTranslationDir/TRANSLATE/$locale/$translationFileName.xlf"
        $i18nFilePath = "$scriptExecutionDir/Translations/$locale/$translationFileName.xlf"
        
        if (Test-Path $kendoFilePath) {
            
            Write-Host Merging xlf files for locale $locale.
            & $mergeXliffPath --out $i18nFilePath --in1 $baseFilePath --in2 $kendoFilePath

        } else {
            WriteWarningOrErrorAndExit("kendo.xlf for locale $($locale) missing")
            Write-Warning "Using $translationFileName.xlf without merge of kendo text file."
            Copy-Item $baseFilePath -Destination $i18nFilePath
        }
    }
}

if (CountLocalesInAngularJSON -gt 0) {

    # Build localized with placeholder in deploy url
    $deployUrlPlaceholder = "deployUrlLanguagePlaceholder"
    npm run ng_build -- `
        --configuration=production `
        --deployUrl=/$moduleName/$serviceName/$deployUrlPlaceholder/ `
        --baseHref=/$moduleName/$serviceName/ `
        --outputPath=$wwwroot/ `
        --deleteOutputPath=false `
        --localize=true `
        --i18nMissingTranslation=$i18nMissingTranslation ` 

    # Post process: remove invalid build result and replace deployUrlLanguagePlaceholder
    if (Test-Path -Path $wwwroot/zxx) {
        Write-Host "Remove item $wwwroot/zxx" 
        Remove-Item -path "$wwwroot/zxx" -recurse        
    }
    ForEach ($locale in $defaultLocales) {
    if (Test-Path -Path $wwwroot\$locale) {
        ReplaceStringInFiles -targetDirectory "$wwwroot\$locale" -sourceString $deployUrlPlaceholder -targetString $locale
    }
    }

} else {

    # no localized build if no locales available in angular.json
    npm run ng_build -- `
        --configuration=production `
        --deployUrl=/$moduleName/$serviceName/de/ `
        --baseHref=/$moduleName/$serviceName/ `
        --outputPath=$wwwroot/de/ `
        --deleteOutputPath=false `
}

# Clean up tmp folders
if (Test-Path -Path $scriptExecutionDir/Translations) {
    Remove-Item -path "$scriptExecutionDir/Translations" -recurse  
}

RestoreAngularJSON

# Return to the directory where the script is located
Set-Location $PSScriptRoot