
# ****************************************************************************************************************************
# NAME   : ReplaceTFSBuildCommonMacros.ps1
#
# PURPOSE: Sucht und ersetzt mehrere Macros, die in Sourcecode oder Begleitdateien hinterlegt sind.
#          Typischerweise handelt es sich dabei um PUBLISHPROP_XYZ - Variablen.
#          Auf diese Weise werden fast alle typische "Ersetzungswünsche" im TFSBuild abgedeckt,
#          außer Macros, die für Produkt-Brand (brewmaxx,...) oder PLC-Ausrichtung (SI/RO/...)
#          verwendet werden.
#          Für diese "Sonderersetzungen" müssen Buildschritte mit "engen Verwandten"
#          namens "ReplaceTFSBuildStepMacros.ps1" eingefuegt werden.
#
# COMMENT: Wenn neue Umgebungsvariablen und Extensions Gruppen hinzugefügt werden müssen dann nach "TODO Umgebungvariablen" 
#          bzw. "TODO Ersetzungsgruppen" suchen.
#
# PARAMS:
#   - RootDir                 : Basisverzeichnis, in dem zu manipulierende Dateien abgelegt sind
#   - Extensions              : Dateienendungen mit denen gesucht werden soll. Es ist möglich eine Gruppe zu übergeben, 
#                               die in die im Skript speziell ausgewertet werden muss. Aktuell Mögliche Gruppen: ISO, SQL, WIX
#   - IsRecursive             : Schalter, ob Dateien auch in Unterverzeichnissen gesucht werden.
#   - FullLog                 : Erweitertes Logging. Welche Umgebungsvariablen wurden in welchen Dateien ersetzt
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
#  - V1.3 (2019-07-16): TME - FIX: Default Encoding ist nicht mehr ASCII sondern ANSI.
#  - V1.2 (2019-07-15): ARJ - FIX/Hardering: Get-Content/Set-Content wird mit "-LiteralPath" statt "-Path" aufgerufen (Robuster bei Dateinamen mit Sonderzeichen).
#  - V1.1 (2019-06-12): ARJ - FIX: Sortierung nach Key-Länge bei KV-Paare eingebaut (zuerst zusammengesetzte Keys, danach Bestandteile)
#  - V1.0 (2019-03-xx): TME - Erste Version
# ****************************************************************************************************************************

param (
    [String]$RootDir
   ,[String[]]$FilePatterns=@("*.txt")
   ,[Bool]$IsRecursive = $true
   ,[Bool]$FullLog = $false
    )

function Get-FileEncoding {
    param ( [string] $FilePath )

    [byte[]] $BOM = Get-Content -Encoding byte -ReadCount 4 -TotalCount 4 -LiteralPath $FilePath
    if ($BOM.Length -lt 2)
        { $encoding = '' } # - Leere Dateien oder fast leere Dateien ignorieren
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

[string]$PUBLISHPROP_BUILD_DATE      = $Env:PUBLISHPROP_BUILD_DATE;
[string]$PUBLISHPROP_BUILD_ID        = $Env:PUBLISHPROP_BUILD_ID;
[string]$PUBLISHPROP_BUILD_DEFNAME   = $Env:PUBLISHPROP_BUILD_DEFNAME;
[string]$PUBLISHPROP_BUILD_BRANCH    = $Env:PUBLISHPROP_BUILD_BRANCH;
[string]$PUBLISHPROP_BUILD_CHANGESET = $Env:PUBLISHPROP_BUILD_CHANGESET;


[string]$PUBLISHPROP_RELEASE_DATE    = $Env:PUBLISHPROP_RELEASE_DATE;
[string]$PUBLISHPROP_RELEASE_NUMBER  = $Env:PUBLISHPROP_RELEASE_NUMBER;
[string]$PUBLISHPROP_RELEASE_STATUS  = $Env:PUBLISHPROP_RELEASE_STATUS;


[string]$PUBLISHPROP_VERSION_CURRENTVERSION = $Env:PUBLISHPROP_VERSION_CURRENTVERSION;
[string]$PUBLISHPROP_VERSION_DESCRIPTION    = $Env:PUBLISHPROP_VERSION_DESCRIPTION;
[string]$PUBLISHPROP_VERSION_KEYDESC        = $Env:PUBLISHPROP_VERSION_KEYDESC;
[string]$PUBLISHPROP_VERSION_KEYTEXT        = $Env:PUBLISHPROP_VERSION_KEYTEXT;
[string]$PUBLISHPROP_VERSION_NAME           = $Env:PUBLISHPROP_VERSION_NAME;
[string]$PUBLISHPROP_VERSION_NUMBER         = $Env:PUBLISHPROP_VERSION_NUMBER;

[string]$PUBLISHPROP_VERSION_UPDATEDATE     = $Env:PUBLISHPROP_VERSION_UPDATEDATE;
[string]$PUBLISHPROP_VERSION_UPDATELEVEL    = $Env:PUBLISHPROP_VERSION_UPDATELEVEL;
[string]$PUBLISHPROP_VERSION_UPDATENUMBER   = $Env:PUBLISHPROP_VERSION_UPDATENUMBER;
[string]$PUBLISHPROP_VERSION_UPDATEREVISION = $Env:PUBLISHPROP_VERSION_UPDATEREVISION;

[string]$PUBLISHPROP_PRODUCT_NAME           = $Env:PUBLISHPROP_PRODUCT_NAME;


# - Hier wird "SYSDOC_VERSION_FILENAME_PART" ermittelt ==> Beispiel: "V950" for file name "XyZ_V950_Release-Notes_en.pdf"
#   Aktuelle Festlegung dafür kommt von Kollegen aus TechDoc und stimmt so ab V7.12.
#   In aktuellen Produktversionen kann diese Variable automatisch aus "$PUBLISHPROP_VERSION_KEYTEXT" bestimmt werden, in dem man "." - Zeichen entfernt.
[string]$SYSDOC_VERSION_FILENAME_PART = $PUBLISHPROP_VERSION_KEYTEXT; # - Initial wird VERSION_KEYTEXT genommen (hier steht z.B. "V9.60").
# - Jetzt "." - Zeichen entfernen: Aus "V9.60" wird "V960"
$SYSDOC_VERSION_FILENAME_PART = $SYSDOC_VERSION_FILENAME_PART.Replace(".", "")

# ****************************************************************************************************************************
#TODO Umgebungvariablen: Hier alle Umgebungsvariablen die ersetzt werden sollen als Key-Value Paare angeben
# ****************************************************************************************************************************
$enviromentVariables = @{   '$(PUBLISHPROP_RELEASE_DATE)'=           $PUBLISHPROP_RELEASE_DATE `                  # Beispiel: "2018-07-15"
                          ; '$(PUBLISHPROP_RELEASE_NUMBER)'=         $PUBLISHPROP_RELEASE_NUMBER `                # Beispiel: "20180715"
                          ; '$(PUBLISHPROP_RELEASE_STATUS)'=         $PUBLISHPROP_RELEASE_STATUS `                # Beispiel: "DEVELOP"/"ALPHA"/"PRERELEASE"/"RTM"/...
                          ; '$(PUBLISHPROP_BUILD_DATE)'=             $PUBLISHPROP_BUILD_DATE `                    # Beispiel: "2018-12-18"
                          ; '$(PUBLISHPROP_BUILD_ID)'=               $PUBLISHPROP_BUILD_ID `                      # Beispiel: "20181218.5.19123.27909 TFSYS(IntegrateiT), Branch(master)"
                          ; '$(PUBLISHPROP_BUILD_DEFNAME)'=          $PUBLISHPROP_BUILD_DEFNAME `                 # Beispiel: "Plant iT PCS (V9.60) - SysDoc"
                          ; '$(PUBLISHPROP_BUILD_BRANCH)'=           $PUBLISHPROP_BUILD_BRANCH `                  # Beispiel: "$/abx/xyz/master"
                          ; '$(PUBLISHPROP_BUILD_CHANGESET)'=        $PUBLISHPROP_BUILD_CHANGESET `               # Beispiel: "27909"
                          ;
                          ; '$(PUBLISHPROP_VERSION_CURRENTVERSION)'= $PUBLISHPROP_VERSION_CURRENTVERSION `        # Beispiel: "9.60.4.1"
                          ; '$(PUBLISHPROP_VERSION_DESCRIPTION)'=    $PUBLISHPROP_VERSION_DESCRIPTION `           # Beispiel: "V9.60 CU4 (9.60.4.1)"
                          ; '$(PUBLISHPROP_VERSION_KEYDESC)'=        $PUBLISHPROP_VERSION_KEYDESC `               # Beispiel: "V9.60 CU2"
                          ; '$(PUBLISHPROP_VERSION_KEYTEXT)'=        $PUBLISHPROP_VERSION_KEYTEXT `               # Beispiel: "V9.60"
                          ; '$(PUBLISHPROP_VERSION_NAME)'=           $PUBLISHPROP_VERSION_NAME `                  # Beispiel: "Zeus"
                          ; '$(PUBLISHPROP_VERSION_NUMBER)'=         $PUBLISHPROP_VERSION_NUMBER `                # Beispiel: "9.60" ==> nur als Fallback-Alias für "PRODUCT_VERSION_NUMBER"
                          ;
                          ; '$(PUBLISHPROP_VERSION_UPDATEDATE)'=     $PUBLISHPROP_VERSION_UPDATEDATE `            # Beispiel: "2018-12-15"
                          ; '$(PUBLISHPROP_VERSION_UPDATELEVEL)'=    $PUBLISHPROP_VERSION_UPDATELEVEL `           # Beispiel: CU4"
                          ; '$(PUBLISHPROP_VERSION_UPDATENUMBER)'=   $PUBLISHPROP_VERSION_UPDATENUMBER `          # Beispiel: "4
                          ; '$(PUBLISHPROP_VERSION_UPDATEREVISION)'= $PUBLISHPROP_VERSION_UPDATEREVISION `        # Beispiel: "1"
                          ;
                          ; '$(PUBLISHPROP_PRODUCT_NAME)'=           $PUBLISHPROP_PRODUCT_NAME `                  # Beispiel: "Plant iT connect"
                          ;
                          ; '$(PUBLISHPROP_DEVTEAM_SPRINT)'=         $PUBLISHPROP_DEVTEAM_SPRINT `                # Beispiel: "23"
                          ; '$(PUBLISHPROP_DEVTEAM_NAME)'=           $PUBLISHPROP_DEVTEAM_NAME `                  # Beispiel: "CC2/MES: Team 4711"
                          
                             # ************************************************************
                             # - PART II: Diverse (meistens) an PUBLISHPROP_XYZ angelehnte Macros ersetzen
                             #            Diese Macros wurden gerne in ISO-Builds seit V9.00 verwendet.
                             # ************************************************************
                          ; '$(PRODUCT_RELEASE_DATE)'=               $PUBLISHPROP_RELEASE_DATE `                  # Beispiel: "2018-07-15"
                          ; '$(PRODUCT_RELEASE_NUMBER)'=             $PUBLISHPROP_RELEASE_NUMBER `                # Beispiel: "20180715"
                          ; '$(PRODUCT_RELEASE_STATUS)'=             $PUBLISHPROP_RELEASE_STATUS `                # Beispiel: "DEVELOP"/"ALPHA"/"PRERELEASE"/"RTM"/...
                          ;                                          
                          ; '$(PRODUCT_BUILD_DATE)'=                 $PUBLISHPROP_BUILD_DATE `                    # Beispiel: "2018-12-18"
                          ; '$(PRODUCT_BUILD_ID)'=                   $PUBLISHPROP_BUILD_ID `                      # Beispiel: "20181218.5.19123.27909 TFSYS(IntegrateiT), Branch(master)"
                          ;                                          
                          ; '$(SYSDOC_VERSION_FILENAME_PART)'=       $SYSDOC_VERSION_FILENAME_PART `              # Beispiel: "V950" for file name "XyZ_V950_Release-Notes_en.pdf"
                          ;                                          
                          ; '$(PRODUCT_CURRENTVERSION)'=             $PUBLISHPROP_VERSION_CURRENTVERSION `        # Beispiel: "9.60.4.1"
                          ; '$(PRODUCT_VERSION_DESCRIPTION)'=        $PUBLISHPROP_VERSION_DESCRIPTION `           # Beispiel: "V9.60 CU4 (9.60.4.1)"
                          ; '$(PRODUCT_VERSION_KEYDESC)'=            $PUBLISHPROP_VERSION_KEYDESC `               # Beispiel: "V9.60 CU2"
                          ; '$(PRODUCT_VERSION_KEYTEXT)'=            $PUBLISHPROP_VERSION_KEYTEXT `               # Beispiel: "V9.60"
                          ; '$(PRODUCT_VERSION_NUMBER)'=             $PUBLISHPROP_VERSION_NUMBER `                # Beispiel: "9.60"
                          ; '$(PRODUCT_VERSION)'=                    $PUBLISHPROP_VERSION_NUMBER `                # Beispiel: "9.60" ==> nur als Fallback-Alias für "PRODUCT_VERSION_NUMBER"
                          ;                                          
                          ; '$(PRODUCT_VERSION_UPDATEDATE)'=         $PUBLISHPROP_VERSION_UPDATEDATE `            # Beispiel: "2018-12-15"
                          ; '$(PRODUCT_VERSION_UPDATELEVEL)'=        $PUBLISHPROP_VERSION_UPDATELEVEL `           # Beispiel: CU4"
                          ; '$(PRODUCT_VERSION_UPDATENUMBER)'=       $PUBLISHPROP_VERSION_UPDATENUMBER `          # Beispiel: "4
                          ; '$(PRODUCT_VERSION_UPDATEREVISION)'=     $PUBLISHPROP_VERSION_UPDATEREVISION `        # Beispiel: "1"
                          ;                                          
                          ; '$(PRODUCT_NAME)'=                       $PUBLISHPROP_PRODUCT_NAME `                  # Beispiel: "Plant iT connect"
                          ; '$(PRODUCT_BRAND_NAME)'=                 $PUBLISHPROP_PRODUCT_NAME `                  # - Normalerweile gleich zu $(PRODUCT_NAME), es sei denn Macro wurde vorher mit "ReplaceTFSBuildStepMacro.PS1" ersetzt.
                          
                             # ************************************************************
                             # - PART III: Diverse "Herkunftskennungen", die Integrate in Sourcecode gerne genutzt hat.
                             #             Sie können auch weiterhint so genutzt werden.
                             # ************************************************************
                             #   Zuesrst "GROSSSE KEULE" alias "Sammelherkunft" bestehend aus mehreren Einzelkennungen setzen"
                          ; '<::=TfsVersion>.<::=TfsBuild><::=TfsHint> (<::=TfsDate>)'=       $PUBLISHPROP_BUILD_ID   # Beispiel: "20181218.5.19123.27909 TFSYS(IntegrateiT), Branch(master)"
                          ; '<::=TfsVersion>.<::=TfsBuild><::=TfsHint>'=                      $PUBLISHPROP_BUILD_ID   # Beispiel: "20181218.5.19123.27909 TFSYS(IntegrateiT), Branch(master)"
                             #   Danach weitere "<::=TfsXYZ" - Kennungen einzeln ersetzen"
                          ; '<::=TfsVersion>'=                       $PUBLISHPROP_VERSION_KEYDESC `               # Beispiel: "V9.60 CU2"
                          ; '<::=TfsBuild>'=                         $PUBLISHPROP_RELEASE_NUMBER `                # Beispiel: "20180715"
                          ; '<::=TfsHint>'=                          $PUBLISHPROP_RELEASE_STATUS `                # Beispiel: "DEVELOP"/"ALPHA"/"PRERELEASE"/"RTM"/...
                          ; '<::=TfsDate>'=                          $PUBLISHPROP_BUILD_DATE `                    # Beispiel: "2018-12-18
                          ; '<::=TfsChangeSet>'=                     $PUBLISHPROP_BUILD_CHANGESET `               # Beispiel: "27909"
                         }


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

Write-Host "INPUT Param (RootDir): $RootDir"
Write-Host "INPUT Param (IsRecursive): $IsRecursive"
Write-Host "INPUT Param (FullLog): $FullLog"
Write-Host "INPUT Param (BUILD_FILE_PATTERN): $BUILD_FILE_PATTERN"
Write-Host " "

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

    # - Alle Key/Value - Paare durchgehen und für REPLACE verwenden.
    #   !!! "Sort-Object" nach Länge des Keys wird angewendet, damit längere Keys zuerst gehandelt werden.
    #   !!! Dadurch werden zusammengesetzte Keys (z.B. "<::=TfsVersion>.<::=TfsBuild><::=TfsHint>")
    #   !!! behandelt, bevor ihre einzelne Bestandteile (z.B. "<::=TfsBuild>") in Frage kommen.
    Foreach($enviromentVariable in $enviromentVariables.GetEnumerator() | Sort-Object { $_.Key.Length} -Descending)
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
        $lines | Set-Content -Encoding $encoding -Force -LiteralPath $file
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
