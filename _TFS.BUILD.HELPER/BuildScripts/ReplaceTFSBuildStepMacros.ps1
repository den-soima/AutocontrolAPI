# *****************************************************************************
# 
# NAME   : ReplaceTFSBuildStepMacros.ps1
#
# PURPOSE: Sucht und ersetzt bis zu vier Macros, die in Sourcecode oder Begleitdateien hinterlegt sind.
#          Die Namen der Macros und ihre Werte werden im Build-Schritt übergeben (daher "TFSBuildStep")
#        - Auf diese Weise werden z.B. Macros ersetzt, die für Produkt-Brand (brewmaxx,...)
#          oder PLC-Ausrichtung (SI/RO/...) verwendet werden.
#          Für Ersetzung der allgemeingültigen Macros muss Buildschritt mit "engen Verwandten"
#          namens "ReplaceTFSBuildCommonMacros.ps1" eingefuegt werden.
#
# COMMENT: Wenn neue Umgebungsvariablen und Extensions Gruppen hinzugefügt werden müssen dann nach "TODO Umgebungvariablen" 
#          bzw. "TODO Ersetzungsgruppen" suchen.
#
# PARAMS:
#   - RootDir                 : Basisverzeichnis, in dem zu manipulierende Dateien abgelegt sind
#   - FilePatterns            : Dateienendungen mit denen gesucht werden soll. Es ist möglich eine Gruppe zu übergeben, 
#                               die in die im Skript speziell ausgewertet werden muss. Aktuell Mögliche Gruppen: ISO, SQL, WIX
#   - IsRecursive             : Schalter, ob Dateien auch in Unterverzeichnissen gesucht werden.
#   - FullLog                 : Erweitertes Logging. Welche Umgebungsvariablen wurden in welchen Dateien ersetzt
#   - Macro[1-4]Name          : Name der Macro-Variable (Text), die in Dateien ersetzt wird.
#                               Beispiel: Macro1Name="$(PLCPLATFORM)"
#   - Macro[1-4]Value         : Wert der Macro-Variable (Text). Damit werden alle Treffer von Macro[1-4]Name ersetzt
#                               Beispiel: Macro1Value="Rockwell"
#
# Beispiele für $FilePatterns:
#     1.a) $FilePatterns = "ISO"  ==> Steht für "*.cmd;*.inf;*.ini;*.txt"
#     1.b) $FilePatterns = "SQL"  ==> Steht für "*.sql;*.tsq"
#   ODER
#     2.a) $FilePatterns = "*.sql"
#     2.b) $FilePatterns = "MyFile*.js"
#
# Hinweis: Array von Strings werden bei der Übergabe mit , getrennt. - FilePatterns "*.cmd","*.inf"
#
# Autor: ProLeiT
#
#  - V1.3 (2019-07-16): TME - FIX: Default Encoding ist nicht mehr ASCII sondern ANSI.
#  - V1.2 (2019-07-15): ARJ - FIX/Hardering: Get-Content/Set-Content wird mit "-LiteralPath" statt "-Path" aufgerufen (Robuster bei Dateinamen mit Sonderzeichen).
#  - V1.0 (2019-03-xx): TME - Erste Version
# **************************************************************
#
param([string]$RootDir
    , [Bool]$IsRecursive = $true
    , [Bool]$FullLog = $false
    , [String[]]$FilePatterns = @("*.txt")
    , [string]$Macro1Name = ""
    , [string]$Macro1Value = ""
    , [string]$Macro2Name = ""
    , [string]$Macro2Value = ""
    , [string]$Macro3Name = ""
    , [string]$Macro3Value = ""
    , [string]$Macro4Name = ""
    , [string]$Macro4Value = ""
)

function Get-FileEncoding {
    param ( [string] $FilePath )

    [byte[]] $BOM = Get-Content -Encoding byte -ReadCount 4 -TotalCount 4 -LiteralPath $FilePath
    if ($BOM.Length -lt 2)
        {  $encoding = '' }  #- Leere Dateien oder fast leere Dateien ignorieren
    elseif ( $BOM.Length -ge 3 -and $BOM[0] -eq 0xef -and $BOM[1] -eq 0xbb -and $BOM[2] -eq 0xbf )
        { $encoding = 'UTF8' }  
    elseif ($BOM.Length -ge 2 -and $BOM[0] -eq 0xfe -and $BOM[1] -eq 0xff)
        { $encoding = 'BigEndianUnicode' }
    elseif ($BOM.Length -ge 2 -and $BOM[0] -eq 0xff -and $BOM[1] -eq 0xfe)
         { $encoding = 'Unicode' }
    elseif ($BOM.Length -ge 4 -and $BOM[0] -eq 0 -and $BOM[1] -eq 0 -and $BOM[2] -eq 0xfe -and $BOM[3] -eq 0xff)
        { $encoding = 'BigEndianUTF32' } 
    elseif ($BOM.Length -ge 4 -and $BOM[0] -eq 0xff -and $BOM[1] -eq 0xfe -and $BOM[2] -eq 0 -and $BOM[3] -eq 0)
        { $encoding = 'UTF32' } 
    elseif ($BOM.Length -ge 3 -and $BOM[0] -eq 0x2b -and $BOM[1] -eq 0x2f -and $BOM[2] -eq 0x76)
        { $encoding = 'UTF7'}
    else
        { $encoding = 'default' }  # - Default Encoding ANSI
    return $encoding
}

# **************************************************************
# - PREPARE PART: PARAMETER INITIALISIEREN
# **************************************************************
[string]$BUILD_ROOT_DIR = $RootDir

[string[]]$BUILD_FILE_PATTERN = $FilePatterns


[string]$TFSSTEP_MACRO_1_NAME     = "";
[string]$TFSSTEP_MACRO_1_VALUE    = $Macro1Value;

[string]$TFSSTEP_MACRO_2_NAME     = "";
[string]$TFSSTEP_MACRO_2_VALUE    = $Macro2Value;

[string]$TFSSTEP_MACRO_3_NAME     = "";
[string]$TFSSTEP_MACRO_3_VALUE    = $Macro3Value;

[string]$TFSSTEP_MACRO_4_NAME     = "";
[string]$TFSSTEP_MACRO_4_VALUE    = $Macro4Value;

if($Macro1Name) {$TFSSTEP_MACRO_1_NAME = '$(' + $Macro1Name + ')'};
if($Macro2Name) {$TFSSTEP_MACRO_2_NAME = '$(' + $Macro2Name + ')'};
if($Macro3Name) {$TFSSTEP_MACRO_3_NAME = '$(' + $Macro3Name + ')'};
if($Macro4Name) {$TFSSTEP_MACRO_4_NAME = '$(' + $Macro4Name + ')'};


# **************************************************************


Write-Host "INPUT Param (RootDir): $RootDir"
Write-Host "INPUT Param (IsRecursive): $IsRecursive"
Write-Host "INPUT Param (FullLog): $FullLog"
Write-Host "INPUT Param (BUILD_FILE_PATTERN): $BUILD_FILE_PATTERN"
Write-Host "INPUT Param (TFSSTEP_MACRO_1_NAME): $TFSSTEP_MACRO_1_NAME"
Write-Host "INPUT Param (TFSSTEP_MACRO_1_VALUE): $TFSSTEP_MACRO_1_VALUE"
Write-Host "INPUT Param (TFSSTEP_MACRO_2_NAME): $TFSSTEP_MACRO_2_NAME"
Write-Host "INPUT Param (TFSSTEP_MACRO_2_VALUE): $TFSSTEP_MACRO_2_VALUE"
Write-Host "INPUT Param (TFSSTEP_MACRO_3_NAME): $TFSSTEP_MACRO_3_NAME"
Write-Host "INPUT Param (TFSSTEP_MACRO_3_VALUE): $TFSSTEP_MACRO_3_VALUE"
Write-Host "INPUT Param (TFSSTEP_MACRO_4_NAME): $TFSSTEP_MACRO_4_NAME"
Write-Host "INPUT Param (TFSSTEP_MACRO_4_VALUE): $TFSSTEP_MACRO_4_VALUE"
Write-Host " "



# **************************************************************
# - WORKING PART
# **************************************************************
#

# ****************************************************************************************************************************
#TODO Umgebungvariablen: Hier alle Umgebungsvariablen die ersetzt werden sollen als Key-Value Paare hinzufügen
# ****************************************************************************************************************************
$enviromentVariables = @{}
if($Macro1Name){$enviromentVariables["$TFSSTEP_MACRO_1_NAME"] = $TFSSTEP_MACRO_1_VALUE}
if($Macro2Name){$enviromentVariables["$TFSSTEP_MACRO_2_NAME"] = $TFSSTEP_MACRO_2_VALUE}
if($Macro3Name){$enviromentVariables["$TFSSTEP_MACRO_3_NAME"] = $TFSSTEP_MACRO_3_VALUE}
if($Macro4Name){$enviromentVariables["$TFSSTEP_MACRO_4_NAME"] = $TFSSTEP_MACRO_4_VALUE}
 
                                        
# ****************************************************************************************************************************
#TODO Ersetzungsgruppen: Um Übergabeparameter zu sparen Gruppen für die Dateiendungen hinzufügen
# ****************************************************************************************************************************
if ($BUILD_FILE_PATTERN.Count -eq 1)
{
    if($BUILD_FILE_PATTERN[0] -eq "ISO")
    {
        $BUILD_FILE_PATTERN=@("*.txt",
                              "*.sql",
                              "*.sqlcmd",
                              "*.ps1",
                              "*.cmd",
                              "*.inf",
                              "*.ini")
    }
    elseif($BUILD_FILE_PATTERN[0] -eq "SQL")
    {
        $BUILD_FILE_PATTERN=@("*.ps1",
                              "*.cmd",
                              "*.sql",
                              "*.sqlcmd",
                              "*.tsq")
    }
    elseif($BUILD_FILE_PATTERN[0] -eq "WEB")
    {
        $BUILD_FILE_PATTERN=@("*.ts",
                              "*.tsx",
                              "*.js",
                              "*.html",
                              "*.css")
    }
    elseif($BUILD_FILE_PATTERN[0] -eq "WIX")
    {
        $BUILD_FILE_PATTERN=@("*.ps1",
                              "*.cmd",
                              "*.config",
                              "*.sql",
                              "*.sqlcmd",
                              "*.wxs",
                              "*.wxi",
                              "*.wxl")
    }
}


if($IsRecursive)
{
    $files = (Get-ChildItem $BUILD_ROOT_DIR -Recurse -Include $BUILD_FILE_PATTERN).FullName 
}
else
{
    $files = (Get-ChildItem $BUILD_ROOT_DIR -Include $BUILD_FILE_PATTERN).FullName
}

Write-Host "Liste der geänderten Dateien"
Foreach ($file in $files)
{
    $encoding = Get-FileEncoding $file
    $replaced = $false
    if($encoding -eq "")
    {
        continue
    }

    # Get-Content hat als Default Encoding ANSI, lässt es aber nicht zu -Encoding ANSI zu übergeben
    if($encoding -eq "default")
    {
        $lines = Get-Content -LiteralPath $file -Raw
    }
    else
    {
        $lines = Get-Content -Encoding $encoding -LiteralPath $file -Raw
    }
    if($FullLog)
    {
        Write-Host "Start: " $file
        Write-Host "Ersetzte Umgebungsvariablen:" 
    }

    Foreach($enviromentVariable in $enviromentVariables.GetEnumerator())
    {
        if($lines.Contains($enviromentVariable.Name))
        {        
            $lines = $lines.Replace($enviromentVariable.Name, $enviromentVariable.Value)
            $replaced = $true
            if($FullLog)
            {
                Write-Host $enviromentVariable.Key ==> $enviromentVariable.Value
            }
            
        }
    }    
    if($replaced)
    {
        $lines | Set-Content -Encoding $encoding -LiteralPath $file
        Write-Host "Datei geändert: $file"
    }
}




# **************************************************************
# - CLEANUP PART
# **************************************************************
#
# - Saubermachen (z.B. TEMP folder entfernen, falls leer)
#
Write-Host "CLEANUP STEP: START "
Write-Host " "

Write-Host "CLEANUP STEP: END "
Write-Host " "


exit 0

