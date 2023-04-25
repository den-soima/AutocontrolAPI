<#
Fetch the translated .resx files from FromTranslate
and copy them to the appropriate location in the source.
#>


param(
    [Parameter(Mandatory=$true, HelpMessage="Location, where the script should be exceuted, i.e. the directory containing the .sln file.
                                            Typically: `$(build.sourcesDirectory)\src\Module ")]
    [string]$scriptExecutionDir,
    [Parameter(Mandatory=$true, HelpMessage="Directory containing translated .resx files. Typically: `$(Build_ResultFolder_FROMTRANSLATE)\TRANSLATE")]
    [string]$translationDir,
    [Parameter(Mandatory=$true, HelpMessage="The Techname of the module to be built. Typically: `$(BASEMODULE_IDENT_NAME)")]
    [string]$moduleName
)

Write-Host Copying all translated .resx for this module to the sources directory.
Write-Host Using the following parameters:
Write-Host scriptExecutionDir = $scriptExecutionDir
Write-Host translationDir = $translationDir
Write-Host moduleName = $moduleName


Set-Location $scriptExecutionDir


# Loop over all .resx in the solution and copy the corresponding translated files to the
# source directory where the original file is located.
foreach ($originalFile in Get-ChildItem . -Filter "*.resx" -File -Recurse) {
    Write-Host Searching tranlsations for $originalFile.FullName

    # Create the file name in the same way as when copying to ToTranslate.
    $relPath = Resolve-Path -Path $originalFile.FullName -Relative
    $flattenedName = $moduleName + $relPath.TrimStart(".").Replace("\", "&")

    # Fetch the translated version of this file
    $translatedFiles = Get-ChildItem -Path $translationDir -File -Filter $flattenedName -Recurse
     
    if ($translatedFiles.Count -eq 0) {
        Write-Host No translations found for this file.
    }

    # Copy all translated files to the directory the original files is located (with locale id appended to the filename).
    foreach ($translatedFile in $translatedFiles) {
        $locale = $translatedFile.Directory.Name
        Write-Host Found translation for $locale.

        # Create Targetname: UserMgmt&IdentityProvider&Resources&Views.Home.Index -> Views.Home.Index.en.resx
        $targetName = $translatedFile.BaseName + "." + $locale + ".resx"
        $targetNameSplit = $targetName.Split("&")
        $targetName = $targetNameSplit[$targetNameSplit.length - 1]

        # Prepare copy statement and copy
        $targetDir = Split-Path -Path $originalFile.FullName
        $targetPath = Join-Path -Path $targetDir -ChildPath $targetName

        Copy-Item $translatedFile.FullName -Destination $targetPath
        
        Write-Host Copied $translatedFile.FullName to $targetPath.
    }
}

Write-Host Copying translated resources successful.
Set-Location $PSScriptRoot
