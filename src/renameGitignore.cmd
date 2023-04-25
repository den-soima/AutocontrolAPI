echo off

IF EXIST ".gitignore" (
  GOTO exists
) ELSE (
  RENAME templateGitIgnorationFile.txt .gitignore
  start /b "" cmd /c del "%~f0"&exit /b  
)
EXIT

:exists
SET choice=
SET /p choise=Override gitignore ? [N]:
IF NOT '%choice%'=='' SET choise=%choise:~0,1%
IF '%choise%'=='Y' GOTO override
IF '%choise%'=='y' GOTO override
start /b "" cmd /c del "%~f0"&exit /b
EXIT

:override
del .gitignore
RENAME templateGitIgnorationFile.txt .gitignore
start /b "" cmd /c del "%~f0"&exit /b
