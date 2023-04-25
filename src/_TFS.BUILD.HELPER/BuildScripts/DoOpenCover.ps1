param([string]$SourceDir, [string]$OpenCoverBatDir)

Foreach($item In Get-ChildItem -Filter *.UnitTests.csproj -Path "$SourceDir" -Recurse)
{
    $basename = $item | % {$_.BaseName}
    $path = $item.DirectoryName
    $fullpath = $item | % {$_.FullName}
    cmd.exe /c "$OpenCoverBatDir\openCoverCall.bat" $fullpath $SourceDir\$basename.xml $path\bin '*'
}