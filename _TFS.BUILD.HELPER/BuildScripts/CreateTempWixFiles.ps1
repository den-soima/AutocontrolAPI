param([Parameter(Position=0,mandatory=$true)][string]$SetupFolder, [Parameter(Position=1,mandatory=$true)][string]$SetupInputDir)

if(Test-Path $SetupInputDir -PathType Container){ 
$SetupInputDirInfo = Get-ChildItem $SetupInputDir -Force | Measure-Object
if($SetupInputDirInfo.Count -ne 0)
{
Write-Host "Old build result found, delete SetupInput Dir"
Get-ChildItem -Path $SetupInputDir -Include * -File -Recurse | foreach {$_.Delete()}
}
}

if(-Not (Test-Path $SetupInputDir -PathType Container)){ 
New-Item -ItemType directory -Path "$SetupInputDir"
}
if(-Not (Test-Path $SetupInputDir\Wix -PathType Container)){ 
New-Item -ItemType directory -Path "$SetupInputDir\Wix"
}
if(-Not (Test-Path $SetupInputDir\Wix\Frontends -PathType Container)){ 
New-Item -ItemType directory -Path "$SetupInputDir\Wix\Frontends"
}

Copy-Item $SetupFolder\Directories.wxs $SetupInputDir\Wix\Directories.wxs -Force
Copy-Item $SetupFolder\Product.wxs $SetupInputDir\Wix\Product.wxs -Force