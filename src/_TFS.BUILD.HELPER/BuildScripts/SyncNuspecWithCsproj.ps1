param(
[Parameter(Mandatory=$true)]
[string] $sourceDirectory
)


############# Helper functions ############

$versionMarker = "$" + "SyncWithCsProjVersion" + "$"
$BuildServerNuspecFileSuffix = ".buildserver.nuspec"

function GetVersionFromCsProj
{
    Param ([string] $nuspecFile, [string]$dependencyId)    
    $filter = "*.csproj"    
    $p = [System.IO.Path]::GetFileNameWithoutExtension($nuspecFile)

    if ($p -ne "")
    {
        $filter = "$p.csproj"
    }

    $dir = Split-Path -Parent $nuspecFile     
       
    $csproj = Get-ChildItem -Path $dir -Filter $filter

    $csProjCount = $csproj.Count

    if ($csProjCount -ne 1)
    {
        throw "Could not resolve dependency version: Corresponding .csproj file for $nuspecFile not found (or multiple matching .csproj files found)."
    }

    $csproj = $csproj.FullName
    [xml]$projXml = Get-Content $csproj
    foreach ($reference in $projXml.GetElementsByTagName("PackageReference"))    
    {
        $ref = $reference.Include
        $version = $reference.Version

        if ($ref -eq $dependencyId)
        {
            return $version
        }
    }
    throw "Could not resolve dependency version for package $dependencyId. No matching reference found within $csproj"
}


function ProcessNuSpec
{
    Param ([string] $nuspecFile)    
    Write-Host "Analyzing .nuspec file " -NoNewline; Write-Host $nuspecFile -ForegroundColor DarkYellow
    
    [xml]$nuspecXml = Get-Content $nuspecFile
    
    foreach ($dependency in $nuspecXml.GetElementsByTagName("dependency"))    
    {
        $version = $dependency.version
        $id = $dependency.id
        
        if ($version -eq $versionMarker)
        {
            Write-Host "Resolving version for dependency " -NoNewline; Write-Host $id  -ForegroundColor Green -NoNewline; Write-Host " from corresponding .csproj file..."

            $csprojVersion = GetVersionFromCsProj $nuspecFile $id
            Write-Host "Found matching dependency version: " -NoNewline; Write-Host $csprojVersion -ForegroundColor Green             
            $dependency.version = $csprojVersion
        }
    }

    $tgtFile = $nuspecFile + $BuildServerNuspecFileSuffix
    Write-Host "Saving sync'd .nuspec as " -NoNewline; Write-Host $tgtFile -ForegroundColor DarkYellow
    $nuspecXml.Save($tgtFile)
}

############ Main ############

$nuspecFiles = Get-ChildItem -Path $sourceDirectory -Recurse -Filter "*.nuspec" -File

foreach ($file in $nuspecFiles) 
{
    if (-Not $file.FullName.EndsWith($BuildServerNuspecFileSuffix))
    {
        ProcessNuSpec $file.FullName
    }
}