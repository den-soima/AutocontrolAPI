set unitTestProject=%1
set outputFile=%2
set searchDirectory=%3
set assemblyNameOfProjectToTest=%4

D:\CodeCoverage\openCover\OpenCover.Console.exe ^
-target:"c:\Program Files\dotnet\dotnet.exe" ^
-targetargs:"test -f netcoreapp2.1 -c Release %unitTestProject% --no-restore /nodereuse:false" ^
-mergeoutput ^
-hideskipped:File ^
-output:%outputFile% ^
-oldStyle ^
-filter:"+[%assemblyNameOfProjectToTest%]*" ^
-searchdirs:%searchDirectory% ^
-register:user

