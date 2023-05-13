############################################
######## Default Engineering Script ######## 
############################################

$baseModuleTagName="LmsModule"
$baseProjectPath = (Get-ItemProperty -path "HKLM:\SOFTWARE\ProLeiT\Plant iT base").ProjectPath
$baseEngineeringPath = $baseProjectPath + "engineering\"
$baseModuleEngineeringPath = Join-Path $baseEngineeringPath -ChildPath $baseModuleTagName

$myFQDN=Get-FqdnForPlantiTBase
$baseNodePortnumber=Get-PortForPlantiTBase

## ~EndOfVariableDefinitions

## Register InstalledSoftwareConfiguration-Files
## This is e.g. for Frontends that need to be registered so that they can be available in the Webportal

$installedSoftwareFiles = Get-ChildItem -Path $baseModuleEngineeringPath -Filter "*InstalledSoftware*"

foreach($i in $installedSoftwareFiles)
{
    Write-Host "Import-PiTConfigInstalledSoftware $($i.FullName) $myFQDN $baseNodePortnumber" -Foreground Cyan
    Import-PiTConfigInstalledSoftware $i.FullName $myFQDN $baseNodePortnumber
}

## Create policies for the following groups to receive all permissions in this LmsModule (The group "Administrators" gets all policies automatically)

$AdministratorsGuid = "448c6fe7-cc8f-43a7-8e89-346137ced97f"
$SupervisorsGuid = "52afc690-9cb0-45b5-a0cd-e5d26906c77e"
$UserGuid = "9405128c-60ca-474a-a663-61bbcfba710a"
$PowerUsersGuid = "dbcf89fd-9e83-46ee-8f28-14ec217a5024"

RegisterAllPossiblePoliciesOfModuleForGroups $baseModuleTagName $PowerUsersGuid,$SupervisorsGuid,$UserGuid

##

