@echo off
setlocal EnableDelayedExpansion
 
set "overwriteGitConfigData=true"
 
set "skipConfig=0"
REM 0==dont skip; 1==skip userConfig; >1==skip
 
 
where git >nul 2>nul && (
echo Git is installed.
) || (
start cmd.exe /k "color 4f & title Error & Echo. & Echo. & Echo Git is not properly installed! & Echo The installation will be canceled. If this is a mistake, remove the initial check from this batch file. & Echo Press any key to close this dialog & Pause > nul & Exit"
Echo Git environment variable wasnt found; Pulling will be canceled
Echo.
Echo Press any key to exit.
Pause > nul
Exit;
)
 
 
for /f i in ('git rev-parse --is-inside-work-tree 2^>^&1') do (
if /I "i"=="true" (
goto success
) else (
echo Current directory isn't a Git repository!
echo By continuing, Git will be set up here.
set /P "input=Press 'y' to continue and configure Git here; 'n' to abort this action: "
 
REM Check if the length of the input at 4th index is empty (3 chars or less) and if it starts with 'y'
set "choice=!input:~0,1!"
if /I "!choice!"=="y" (
if "!input:~3!"=="" (
echo Continuing...
echo Setting Git up in the current directory...
git init
) else (
goto wrongDirError
)
) else (
:wrongDirError
echo Aborting...
echo.
echo Press any key to exit.
pause > nul
exit
)
)
)
 
:success
Echo.
 
if ""=="" (
echo No branch name input provided. Pulling the 'main' branch.
set "branchToPull=main"
)
 
 
set "gitConfigRemoteName=%~2"
 
if "^"==^"" (
echo No input remote repo name provided. Setting to default 'origin'.
set "gitConfigRemoteName=origin"
)
rem Read configurations from the config.txt file
for /F "tokens=1,* delims== " G in (config.txt) do (
if "G"=="gitConfigUser" (
set "gitConfigUser=H"
if "!gitConfigUser!"=="" set "gitConfigUser="
)
if "G"=="gitConfigPassword" (
set "gitConfigPassword=H"
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
if "G"=="gitConfigURL" (
set "gitConfigURL=H"
if "!gitConfigURL!"=="" set "gitConfigURL="
)
)
rem Removing quotes from the config values
set "gitConfigUser=!gitConfigUser:"=!"
set "gitConfigPassword=!gitConfigPassword:"=!"
set "gitConfigURL=!gitConfigURL:"=!"
 
rem Check if the string is a space character and set it to an empty variable; space is always appended >:-( though git should deal with these strings correctly nevertheless
if "^"==^" " set "gitConfigUser="
if "^"==^" " set "gitConfigPassword="
if "^"==^" " set "gitConfigURL="
 
 
rem read current/already defined Git Config to see if theyre blank; not using --global flag!
for /F "delims=" i in ('git config user.name') do set currentGitConfigUser=i
for /F "delims=" i in ('git config user.password') do set currentGitConfigPassword=i
for /F "delims=" i in ('git config --get remote..url') do set currentGitConfigURL=i
 
if "!currentGitConfigUser!"==" " set "currentGitConfigUser="
if "!currentGitConfigPassword!"==" " set "currentGitConfigPassword="
if "!currentGitConfigURL!"==" " set "currentGitConfigURL="
 
if ==0 (
REM do nothing
goto dontSkip
) else if ==1 (
goto skipUserConfig
) else (
goto skipConfig
)
 
:dontSkip
 
REM set TAB="<TAB>"
set "TAB=   "
 
Echo Current User Name: "!currentGitConfigUser!"  Read User Name: "!gitConfigUser!"
Echo Current User PWD: "!currentGitConfigPassword!"  Read User PWD: "!gitConfigPassword!"
Echo.
Echo Pulling from Host with Name: "%gitConfigRemoteName%"
Echo Current URL under this Name: "!currentGitConfigURL!"  Read URL: "!gitConfigURL!"
 
Echo.
Echo.
 
if not "!gitConfigUser!"=="" (
if "!currentGitConfigUser!"=="" (
echo Current local Git Username is not set -> new Name: "!gitConfigUser!"
git config user.name "!gitConfigUser!"
)else (
echo Current local Git Username is already set; if the overwriteGitConfigData flag is true the current Username: "!currentGitConfigUser!" will be set to "!gitConfigUser!"
if "!overwriteGitConfigData!"=="true" (
git config user.name "!gitConfigUser!"&Echo Overwriting successful; Username "!currentGitConfigUser!" changed to "!gitConfigUser!"
REM git config --global --replace-all "!gitConfigUser!"
)
)
)
 
Echo.
Echo.
 
if not "!gitConfigPassword!"=="" (
if "!currentGitConfigPassword!"=="" (
echo Current local Git Password is not set -> new Password: "!gitConfigPassword!"
git config user.password "!gitConfigPassword!"
)else (
 
echo Current local Git Password is already set; if the overwriteGitConfigData flag is true the current Password: "!currentGitConfigPassword!" will be set to "!gitConfigPassword!"
if "!overwriteGitConfigData!"=="true" (
git config user.password "!gitConfigPassword!"&Echo Overwriting successful; Password "!currentGitConfigPassword!" changed to "!gitConfigPassword!"
REM git config --replace-all --global user.password "!gitConfigPassword!"
)
)
)
 
:skipUserConfig
Echo.
Echo.
 
if not "!gitConfigURL!"=="" (
echo get displayed
echo !gitConfigURL!
echo "!currentGitConfigURL!"
 
if "!currentGitConfigURL!"=="" (
echo Current local Git fetch URL is not set -> new URL: "!gitConfigURL!"
git remote add  "!gitConfigURL!"
) else (
echo Current local Git fetch URL is already set; if the overwriteGitConfigData flag is true the current URL: "!currentGitConfigURL!" will be set to "!gitConfigURL!"
if "!overwriteGitConfigData!"=="true" (
git remote add !gitConfigRemoteName! "!gitConfigURL!" & Echo Overwriting successful; URL "!currentGitConfigURL!" changed to "!gitConfigURL!"
)
)
) else (
Echo Either Config.txt url was empty
)
:skipConfig
 
git pull %gitConfigRemoteName% %branchToPull%
 
 
if not %errorlevel% == 0(
Echo.
Echo Git ran into an Error when pulling.
Echo Have you committed your local changes?
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
Echo Resetting uncommited local changes ...
 
git reset --hard
git pull %gitConfigRemoteName% %branchToPull%
 
) else (
goto invalidNumberLength
)
) else (
:invalidNumberLength
Echo Aborting...
Echo.
Echo Press any key to exit.
Pause > nul
Exit
)
)
endlocal
@echo off
setlocal EnableDelayedExpansion
 
set "overwriteGitConfigData=true"
 
set "skipConfig=0"
REM 0==dont skip; 1==skip userConfig; >1==skip
 
 
where git >nul 2>nul && (
echo Git is installed.
) || (
start cmd.exe /k "color 4f & title Error & Echo. & Echo. & Echo Git is not properly installed! & Echo The installation will be canceled. If this is a mistake, remove the initial check from this batch file. & Echo Press any key to close this dialog & Pause > nul & Exit"
Echo Git environment variable wasnt found; Pulling will be canceled
Echo.
Echo Press any key to exit.
Pause > nul
Exit;
)
 
 
for /f i in ('git rev-parse --is-inside-work-tree 2^>^&1') do (
if /I "i"=="true" (
goto success
) else (
echo Current directory isn't a Git repository!
echo By continuing, Git will be set up here.
set /P "input=Press 'y' to continue and configure Git here; 'n' to abort this action: "
 
REM Check if the length of the input at 4th index is empty (3 chars or less) and if it starts with 'y'
set "choice=!input:~0,1!"
if /I "!choice!"=="y" (
if "!input:~3!"=="" (
echo Continuing...
echo Setting Git up in the current directory...
git init
) else (
goto wrongDirError
)
) else (
:wrongDirError
echo Aborting...
echo.
echo Press any key to exit.
pause > nul
exit
)
)
)
 
:success
Echo.
 
if ""=="" (
echo No branch name input provided. Pulling the 'main' branch.
set "branchToPull=main"
)
 
 
set "gitConfigRemoteName=%~2"
 
if "^"==^"" (
echo No input remote repo name provided. Setting to default 'origin'.
set "gitConfigRemoteName=origin"
)
rem Read configurations from the config.txt file
for /F "tokens=1,* delims== " G in (config.txt) do (
if "G"=="gitConfigUser" (
set "gitConfigUser=H"
if "!gitConfigUser!"=="" set "gitConfigUser="
)
if "G"=="gitConfigPassword" (
set "gitConfigPassword=H"
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
if "G"=="gitConfigURL" (
set "gitConfigURL=H"
if "!gitConfigURL!"=="" set "gitConfigURL="
)
)
rem Removing quotes from the config values
set "gitConfigUser=!gitConfigUser:"=!"
set "gitConfigPassword=!gitConfigPassword:"=!"
set "gitConfigURL=!gitConfigURL:"=!"
 
rem Check if the string is a space character and set it to an empty variable; space is always appended >:-( though git should deal with these strings correctly nevertheless
if "^"==^" " set "gitConfigUser="
if "^"==^" " set "gitConfigPassword="
if "^"==^" " set "gitConfigURL="
 
 
rem read current/already defined Git Config to see if theyre blank; not using --global flag!
for /F "delims=" i in ('git config user.name') do set currentGitConfigUser=i
for /F "delims=" i in ('git config user.password') do set currentGitConfigPassword=i
for /F "delims=" i in ('git config --get remote..url') do set currentGitConfigURL=i
 
if "!currentGitConfigUser!"==" " set "currentGitConfigUser="
if "!currentGitConfigPassword!"==" " set "currentGitConfigPassword="
if "!currentGitConfigURL!"==" " set "currentGitConfigURL="
 
if ==0 (
REM do nothing
goto dontSkip
) else if ==1 (
goto skipUserConfig
) else (
goto skipConfig
)
 
:dontSkip
 
REM set TAB="<TAB>"
set "TAB=   "
 
Echo Current User Name: "!currentGitConfigUser!"  Read User Name: "!gitConfigUser!"
Echo Current User PWD: "!currentGitConfigPassword!"  Read User PWD: "!gitConfigPassword!"
Echo.
Echo Pulling from Host with Name: "%gitConfigRemoteName%"
Echo Current URL under this Name: "!currentGitConfigURL!"  Read URL: "!gitConfigURL!"
 
Echo.
Echo.
 
if not "!gitConfigUser!"=="" (
if "!currentGitConfigUser!"=="" (
echo Current local Git Username is not set -> new Name: "!gitConfigUser!"
git config user.name "!gitConfigUser!"
)else (
echo Current local Git Username is already set; if the overwriteGitConfigData flag is true the current Username: "!currentGitConfigUser!" will be set to "!gitConfigUser!"
if "!overwriteGitConfigData!"=="true" (
git config user.name "!gitConfigUser!"&Echo Overwriting successful; Username "!currentGitConfigUser!" changed to "!gitConfigUser!"
REM git config --global --replace-all "!gitConfigUser!"
)
)
)
 
Echo.
Echo.
 
if not "!gitConfigPassword!"=="" (
if "!currentGitConfigPassword!"=="" (
echo Current local Git Password is not set -> new Password: "!gitConfigPassword!"
git config user.password "!gitConfigPassword!"
)else (
 
echo Current local Git Password is already set; if the overwriteGitConfigData flag is true the current Password: "!currentGitConfigPassword!" will be set to "!gitConfigPassword!"
if "!overwriteGitConfigData!"=="true" (
git config user.password "!gitConfigPassword!"&Echo Overwriting successful; Password "!currentGitConfigPassword!" changed to "!gitConfigPassword!"
REM git config --replace-all --global user.password "!gitConfigPassword!"
)
)
)
 
:skipUserConfig
Echo.
Echo.
 
if not "!gitConfigURL!"=="" (
echo get displayed
echo !gitConfigURL!
echo "!currentGitConfigURL!"
 
if "!currentGitConfigURL!"=="" (
echo Current local Git fetch URL is not set -> new URL: "!gitConfigURL!"
git remote add  "!gitConfigURL!"
) else (
echo Current local Git fetch URL is already set; if the overwriteGitConfigData flag is true the current URL: "!currentGitConfigURL!" will be set to "!gitConfigURL!"
if "!overwriteGitConfigData!"=="true" (
git remote add !gitConfigRemoteName! "!gitConfigURL!" & Echo Overwriting successful; URL "!currentGitConfigURL!" changed to "!gitConfigURL!"
)
)
) else (
Echo Either Config.txt url was empty
)
:skipConfig
 
git pull %gitConfigRemoteName% %branchToPull%
 
 
if not %errorlevel% == 0(
Echo.
Echo Git ran into an Error when pulling.
Echo Have you committed your local changes?
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
Echo Resetting uncommited local changes ...
 
git reset --hard
git pull %gitConfigRemoteName% %branchToPull%
 
) else (
goto invalidNumberLength
)
) else (
:invalidNumberLength
Echo Aborting...
Echo.
Echo Press any key to exit.
Pause > nul
Exit
)
)
endlocal
@echo off
setlocal EnableDelayedExpansion
 
set "overwriteGitConfigData=true"
 
set "skipConfig=0"
REM 0==dont skip; 1==skip userConfig; >1==skip
 
 
where git >nul 2>nul && (
echo Git is installed.
) || (
start cmd.exe /k "color 4f & title Error & Echo. & Echo. & Echo Git is not properly installed! & Echo The installation will be canceled. If this is a mistake, remove the initial check from this batch file. & Echo Press any key to close this dialog & Pause > nul & Exit"
Echo Git environment variable wasnt found; Pulling will be canceled
Echo.
Echo Press any key to exit.
Pause > nul
Exit;
)
 
 
for /f i in ('git rev-parse --is-inside-work-tree 2^>^&1') do (
if /I "i"=="true" (
goto success
) else (
echo Current directory isn't a Git repository!
echo By continuing, Git will be set up here.
set /P "input=Press 'y' to continue and configure Git here; 'n' to abort this action: "
 
REM Check if the length of the input at 4th index is empty (3 chars or less) and if it starts with 'y'
set "choice=!input:~0,1!"
if /I "!choice!"=="y" (
if "!input:~3!"=="" (
echo Continuing...
echo Setting Git up in the current directory...
git init
) else (
goto wrongDirError
)
) else (
:wrongDirError
echo Aborting...
echo.
echo Press any key to exit.
pause > nul
exit
)
)
)
 
:success
Echo.
 
if ""=="" (
echo No branch name input provided. Pulling the 'main' branch.
set "branchToPull=main"
)
 
 
set "gitConfigRemoteName=%~2"
 
if "^"==^"" (
echo No input remote repo name provided. Setting to default 'origin'.
set "gitConfigRemoteName=origin"
)
rem Read configurations from the config.txt file
for /F "tokens=1,* delims== " G in (config.txt) do (
if "G"=="gitConfigUser" (
set "gitConfigUser=H"
if "!gitConfigUser!"=="" set "gitConfigUser="
)
if "G"=="gitConfigPassword" (
set "gitConfigPassword=H"
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
if "G"=="gitConfigURL" (
set "gitConfigURL=H"
if "!gitConfigURL!"=="" set "gitConfigURL="
)
)
rem Removing quotes from the config values
set "gitConfigUser=!gitConfigUser:"=!"
set "gitConfigPassword=!gitConfigPassword:"=!"
set "gitConfigURL=!gitConfigURL:"=!"
 
rem Check if the string is a space character and set it to an empty variable; space is always appended >:-( though git should deal with these strings correctly nevertheless
if "^"==^" " set "gitConfigUser="
if "^"==^" " set "gitConfigPassword="
if "^"==^" " set "gitConfigURL="
 
 
rem read current/already defined Git Config to see if theyre blank; not using --global flag!
for /F "delims=" i in ('git config user.name') do set currentGitConfigUser=i
for /F "delims=" i in ('git config user.password') do set currentGitConfigPassword=i
for /F "delims=" i in ('git config --get remote..url') do set currentGitConfigURL=i
 
if "!currentGitConfigUser!"==" " set "currentGitConfigUser="
if "!currentGitConfigPassword!"==" " set "currentGitConfigPassword="
if "!currentGitConfigURL!"==" " set "currentGitConfigURL="
 
if ==0 (
REM do nothing
goto dontSkip
) else if ==1 (
goto skipUserConfig
) else (
goto skipConfig
)
 
:dontSkip
 
REM set TAB="<TAB>"
set "TAB=   "
 
Echo Current User Name: "!currentGitConfigUser!"  Read User Name: "!gitConfigUser!"
Echo Current User PWD: "!currentGitConfigPassword!"  Read User PWD: "!gitConfigPassword!"
Echo.
Echo Pulling from Host with Name: "%gitConfigRemoteName%"
Echo Current URL under this Name: "!currentGitConfigURL!"  Read URL: "!gitConfigURL!"
 
Echo.
Echo.
 
if not "!gitConfigUser!"=="" (
if "!currentGitConfigUser!"=="" (
echo Current local Git Username is not set -> new Name: "!gitConfigUser!"
git config user.name "!gitConfigUser!"
)else (
echo Current local Git Username is already set; if the overwriteGitConfigData flag is true the current Username: "!currentGitConfigUser!" will be set to "!gitConfigUser!"
if "!overwriteGitConfigData!"=="true" (
git config user.name "!gitConfigUser!"&Echo Overwriting successful; Username "!currentGitConfigUser!" changed to "!gitConfigUser!"
REM git config --global --replace-all "!gitConfigUser!"
)
)
)
 
Echo.
Echo.
 
if not "!gitConfigPassword!"=="" (
if "!currentGitConfigPassword!"=="" (
echo Current local Git Password is not set -> new Password: "!gitConfigPassword!"
git config user.password "!gitConfigPassword!"
)else (
 
echo Current local Git Password is already set; if the overwriteGitConfigData flag is true the current Password: "!currentGitConfigPassword!" will be set to "!gitConfigPassword!"
if "!overwriteGitConfigData!"=="true" (
git config user.password "!gitConfigPassword!"&Echo Overwriting successful; Password "!currentGitConfigPassword!" changed to "!gitConfigPassword!"
REM git config --replace-all --global user.password "!gitConfigPassword!"
)
)
)
 
:skipUserConfig
Echo.
Echo.
 
if not "!gitConfigURL!"=="" (
echo get displayed
echo !gitConfigURL!
echo "!currentGitConfigURL!"
 
if "!currentGitConfigURL!"=="" (
echo Current local Git fetch URL is not set -> new URL: "!gitConfigURL!"
git remote add  "!gitConfigURL!"
) else (
echo Current local Git fetch URL is already set; if the overwriteGitConfigData flag is true the current URL: "!currentGitConfigURL!" will be set to "!gitConfigURL!"
if "!overwriteGitConfigData!"=="true" (
git remote add !gitConfigRemoteName! "!gitConfigURL!" & Echo Overwriting successful; URL "!currentGitConfigURL!" changed to "!gitConfigURL!"
)
)
) else (
Echo Either Config.txt url was empty
)
:skipConfig
 
git pull %gitConfigRemoteName% %branchToPull%
 
 
if not %errorlevel% == 0(
Echo.
Echo Git ran into an Error when pulling.
Echo Have you committed your local changes?
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
Echo Resetting uncommited local changes ...
 
git reset --hard
git pull %gitConfigRemoteName% %branchToPull%
 
) else (
goto invalidNumberLength
)
) else (
:invalidNumberLength
Echo Aborting...
Echo.
Echo Press any key to exit.
Pause > nul
Exit
)
)
endlocal
@echo off
setlocal EnableDelayedExpansion
 
set "overwriteGitConfigData=true"
 
set "skipConfig=0"
REM 0==dont skip; 1==skip userConfig; >1==skip
 
 
where git >nul 2>nul && (
echo Git is installed.
) || (
start cmd.exe /k "color 4f & title Error & Echo. & Echo. & Echo Git is not properly installed! & Echo The installation will be canceled. If this is a mistake, remove the initial check from this batch file. & Echo Press any key to close this dialog & Pause > nul & Exit"
Echo Git environment variable wasnt found; Pulling will be canceled
Echo.
Echo Press any key to exit.
Pause > nul
Exit;
)
 
 
for /f i in ('git rev-parse --is-inside-work-tree 2^>^&1') do (
if /I "i"=="true" (
goto success
) else (
echo Current directory isn't a Git repository!
echo By continuing, Git will be set up here.
set /P "input=Press 'y' to continue and configure Git here; 'n' to abort this action: "
 
REM Check if the length of the input at 4th index is empty (3 chars or less) and if it starts with 'y'
set "choice=!input:~0,1!"
if /I "!choice!"=="y" (
if "!input:~3!"=="" (
echo Continuing...
echo Setting Git up in the current directory...
git init
) else (
goto wrongDirError
)
) else (
:wrongDirError
echo Aborting...
echo.
echo Press any key to exit.
pause > nul
exit
)
)
)
 
:success
Echo.
 
if ""=="" (
echo No branch name input provided. Pulling the 'main' branch.
set "branchToPull=main"
)
 
 
set "gitConfigRemoteName=%~2"
 
if "^"==^"" (
echo No input remote repo name provided. Setting to default 'origin'.
set "gitConfigRemoteName=origin"
)
rem Read configurations from the config.txt file
for /F "tokens=1,* delims== " G in (config.txt) do (
if "G"=="gitConfigUser" (
set "gitConfigUser=H"
if "!gitConfigUser!"=="" set "gitConfigUser="
)
if "G"=="gitConfigPassword" (
set "gitConfigPassword=H"
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
if "G"=="gitConfigURL" (
set "gitConfigURL=H"
if "!gitConfigURL!"=="" set "gitConfigURL="
)
)
rem Removing quotes from the config values
set "gitConfigUser=!gitConfigUser:"=!"
set "gitConfigPassword=!gitConfigPassword:"=!"
set "gitConfigURL=!gitConfigURL:"=!"
 
rem Check if the string is a space character and set it to an empty variable; space is always appended >:-( though git should deal with these strings correctly nevertheless
if "^"==^" " set "gitConfigUser="
if "^"==^" " set "gitConfigPassword="
if "^"==^" " set "gitConfigURL="
 
 
rem read current/already defined Git Config to see if theyre blank; not using --global flag!
for /F "delims=" i in ('git config user.name') do set currentGitConfigUser=i
for /F "delims=" i in ('git config user.password') do set currentGitConfigPassword=i
for /F "delims=" i in ('git config --get remote..url') do set currentGitConfigURL=i
 
if "!currentGitConfigUser!"==" " set "currentGitConfigUser="
if "!currentGitConfigPassword!"==" " set "currentGitConfigPassword="
if "!currentGitConfigURL!"==" " set "currentGitConfigURL="
 
if ==0 (
REM do nothing
goto dontSkip
) else if ==1 (
goto skipUserConfig
) else (
goto skipConfig
)
 
:dontSkip
 
REM set TAB="<TAB>"
set "TAB=   "
 
Echo Current User Name: "!currentGitConfigUser!"  Read User Name: "!gitConfigUser!"
Echo Current User PWD: "!currentGitConfigPassword!"  Read User PWD: "!gitConfigPassword!"
Echo.
Echo Pulling from Host with Name: "%gitConfigRemoteName%"
Echo Current URL under this Name: "!currentGitConfigURL!"  Read URL: "!gitConfigURL!"
 
Echo.
Echo.
 
if not "!gitConfigUser!"=="" (
if "!currentGitConfigUser!"=="" (
echo Current local Git Username is not set -> new Name: "!gitConfigUser!"
git config user.name "!gitConfigUser!"
)else (
echo Current local Git Username is already set; if the overwriteGitConfigData flag is true the current Username: "!currentGitConfigUser!" will be set to "!gitConfigUser!"
if "!overwriteGitConfigData!"=="true" (
git config user.name "!gitConfigUser!"&Echo Overwriting successful; Username "!currentGitConfigUser!" changed to "!gitConfigUser!"
REM git config --global --replace-all "!gitConfigUser!"
)
)
)
 
Echo.
Echo.
 
if not "!gitConfigPassword!"=="" (
if "!currentGitConfigPassword!"=="" (
echo Current local Git Password is not set -> new Password: "!gitConfigPassword!"
git config user.password "!gitConfigPassword!"
)else (
 
echo Current local Git Password is already set; if the overwriteGitConfigData flag is true the current Password: "!currentGitConfigPassword!" will be set to "!gitConfigPassword!"
if "!overwriteGitConfigData!"=="true" (
git config user.password "!gitConfigPassword!"&Echo Overwriting successful; Password "!currentGitConfigPassword!" changed to "!gitConfigPassword!"
REM git config --replace-all --global user.password "!gitConfigPassword!"
)
)
)
 
:skipUserConfig
Echo.
Echo.
 
if not "!gitConfigURL!"=="" (
echo get displayed
echo !gitConfigURL!
echo "!currentGitConfigURL!"
 
if "!currentGitConfigURL!"=="" (
echo Current local Git fetch URL is not set -> new URL: "!gitConfigURL!"
git remote add  "!gitConfigURL!"
) else (
echo Current local Git fetch URL is already set; if the overwriteGitConfigData flag is true the current URL: "!currentGitConfigURL!" will be set to "!gitConfigURL!"
if "!overwriteGitConfigData!"=="true" (
git remote add !gitConfigRemoteName! "!gitConfigURL!" & Echo Overwriting successful; URL "!currentGitConfigURL!" changed to "!gitConfigURL!"
)
)
) else (
Echo Either Config.txt url was empty
)
:skipConfig
 
git pull %gitConfigRemoteName% %branchToPull%
 
 
if not %errorlevel% == 0(
Echo.
Echo Git ran into an Error when pulling.
Echo Have you committed your local changes?
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
Echo Resetting uncommited local changes ...
 
git reset --hard
git pull %gitConfigRemoteName% %branchToPull%
 
) else (
goto invalidNumberLength
)
) else (
:invalidNumberLength
Echo Aborting...
Echo.
Echo Press any key to exit.
Pause > nul
Exit
)
)
endlocal
@echo off
setlocal EnableDelayedExpansion
 
set "overwriteGitConfigData=true"
 
set "skipConfig=0"
REM 0==dont skip; 1==skip userConfig; >1==skip
 
 
where git >nul 2>nul && (
echo Git is installed.
) || (
start cmd.exe /k "color 4f & title Error & Echo. & Echo. & Echo Git is not properly installed! & Echo The installation will be canceled. If this is a mistake, remove the initial check from this batch file. & Echo Press any key to close this dialog & Pause > nul & Exit"
Echo Git environment variable wasnt found; Pulling will be canceled
Echo.
Echo Press any key to exit.
Pause > nul
Exit;
)
 
 
for /f i in ('git rev-parse --is-inside-work-tree 2^>^&1') do (
if /I "i"=="true" (
goto success
) else (
echo Current directory isn't a Git repository!
echo By continuing, Git will be set up here.
set /P "input=Press 'y' to continue and configure Git here; 'n' to abort this action: "
 
REM Check if the length of the input at 4th index is empty (3 chars or less) and if it starts with 'y'
set "choice=!input:~0,1!"
if /I "!choice!"=="y" (
if "!input:~3!"=="" (
echo Continuing...
echo Setting Git up in the current directory...
git init
) else (
goto wrongDirError
)
) else (
:wrongDirError
echo Aborting...
echo.
echo Press any key to exit.
pause > nul
exit
)
)
)
 
:success
Echo.
 
if ""=="" (
echo No branch name input provided. Pulling the 'main' branch.
set "branchToPull=main"
)
 
 
set "gitConfigRemoteName=%~2"
 
if "^"==^"" (
echo No input remote repo name provided. Setting to default 'origin'.
set "gitConfigRemoteName=origin"
)
rem Read configurations from the config.txt file
for /F "tokens=1,* delims== " G in (config.txt) do (
if "G"=="gitConfigUser" (
set "gitConfigUser=H"
if "!gitConfigUser!"=="" set "gitConfigUser="
)
if "G"=="gitConfigPassword" (
set "gitConfigPassword=H"
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
if "G"=="gitConfigURL" (
set "gitConfigURL=H"
if "!gitConfigURL!"=="" set "gitConfigURL="
)
)
rem Removing quotes from the config values
set "gitConfigUser=!gitConfigUser:"=!"
set "gitConfigPassword=!gitConfigPassword:"=!"
set "gitConfigURL=!gitConfigURL:"=!"
 
rem Check if the string is a space character and set it to an empty variable; space is always appended >:-( though git should deal with these strings correctly nevertheless
if "^"==^" " set "gitConfigUser="
if "^"==^" " set "gitConfigPassword="
if "^"==^" " set "gitConfigURL="
 
 
rem read current/already defined Git Config to see if theyre blank; not using --global flag!
for /F "delims=" i in ('git config user.name') do set currentGitConfigUser=i
for /F "delims=" i in ('git config user.password') do set currentGitConfigPassword=i
for /F "delims=" i in ('git config --get remote..url') do set currentGitConfigURL=i
 
if "!currentGitConfigUser!"==" " set "currentGitConfigUser="
if "!currentGitConfigPassword!"==" " set "currentGitConfigPassword="
if "!currentGitConfigURL!"==" " set "currentGitConfigURL="
 
if ==0 (
REM do nothing
goto dontSkip
) else if ==1 (
goto skipUserConfig
) else (
goto skipConfig
)
 
:dontSkip
 
REM set TAB="<TAB>"
set "TAB=   "
 
Echo Current User Name: "!currentGitConfigUser!"  Read User Name: "!gitConfigUser!"
Echo Current User PWD: "!currentGitConfigPassword!"  Read User PWD: "!gitConfigPassword!"
Echo.
Echo Pulling from Host with Name: "%gitConfigRemoteName%"
Echo Current URL under this Name: "!currentGitConfigURL!"  Read URL: "!gitConfigURL!"
 
Echo.
Echo.
 
if not "!gitConfigUser!"=="" (
if "!currentGitConfigUser!"=="" (
echo Current local Git Username is not set -> new Name: "!gitConfigUser!"
git config user.name "!gitConfigUser!"
)else (
echo Current local Git Username is already set; if the overwriteGitConfigData flag is true the current Username: "!currentGitConfigUser!" will be set to "!gitConfigUser!"
if "!overwriteGitConfigData!"=="true" (
git config user.name "!gitConfigUser!"&Echo Overwriting successful; Username "!currentGitConfigUser!" changed to "!gitConfigUser!"
REM git config --global --replace-all "!gitConfigUser!"
)
)
)
 
Echo.
Echo.
 
if not "!gitConfigPassword!"=="" (
if "!currentGitConfigPassword!"=="" (
echo Current local Git Password is not set -> new Password: "!gitConfigPassword!"
git config user.password "!gitConfigPassword!"
)else (
 
echo Current local Git Password is already set; if the overwriteGitConfigData flag is true the current Password: "!currentGitConfigPassword!" will be set to "!gitConfigPassword!"
if "!overwriteGitConfigData!"=="true" (
git config user.password "!gitConfigPassword!"&Echo Overwriting successful; Password "!currentGitConfigPassword!" changed to "!gitConfigPassword!"
REM git config --replace-all --global user.password "!gitConfigPassword!"
)
)
)
 
:skipUserConfig
Echo.
Echo.
 
if not "!gitConfigURL!"=="" (
echo get displayed
echo !gitConfigURL!
echo "!currentGitConfigURL!"
 
if "!currentGitConfigURL!"=="" (
echo Current local Git fetch URL is not set -> new URL: "!gitConfigURL!"
git remote add  "!gitConfigURL!"
) else (
echo Current local Git fetch URL is already set; if the overwriteGitConfigData flag is true the current URL: "!currentGitConfigURL!" will be set to "!gitConfigURL!"
if "!overwriteGitConfigData!"=="true" (
git remote add !gitConfigRemoteName! "!gitConfigURL!" & Echo Overwriting successful; URL "!currentGitConfigURL!" changed to "!gitConfigURL!"
)
)
) else (
Echo Either Config.txt url was empty
)
:skipConfig
 
git pull %gitConfigRemoteName% %branchToPull%
 
 
if not %errorlevel% == 0(
Echo.
Echo Git ran into an Error when pulling.
Echo Have you committed your local changes?
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
Echo Resetting uncommited local changes ...
 
git reset --hard
git pull %gitConfigRemoteName% %branchToPull%
 
) else (
goto invalidNumberLength
)
) else (
:invalidNumberLength
Echo Aborting...
Echo.
Echo Press any key to exit.
Pause > nul
Exit
)
)
endlocal
@echo off
setlocal EnableDelayedExpansion
 
set "overwriteGitConfigData=true"
 
set "skipConfig=0"
REM 0==dont skip; 1==skip userConfig; >1==skip
 
 
where git >nul 2>nul && (
echo Git is installed.
) || (
start cmd.exe /k "color 4f & title Error & Echo. & Echo. & Echo Git is not properly installed! & Echo The installation will be canceled. If this is a mistake, remove the initial check from this batch file. & Echo Press any key to close this dialog & Pause > nul & Exit"
Echo Git environment variable wasnt found; Pulling will be canceled
Echo.
Echo Press any key to exit.
Pause > nul
Exit;
)
 
 
for /f i in ('git rev-parse --is-inside-work-tree 2^>^&1') do (
if /I "i"=="true" (
goto success
) else (
echo Current directory isn't a Git repository!
echo By continuing, Git will be set up here.
set /P "input=Press 'y' to continue and configure Git here; 'n' to abort this action: "
 
REM Check if the length of the input at 4th index is empty (3 chars or less) and if it starts with 'y'
set "choice=!input:~0,1!"
if /I "!choice!"=="y" (
if "!input:~3!"=="" (
echo Continuing...
echo Setting Git up in the current directory...
git init
) else (
goto wrongDirError
)
) else (
:wrongDirError
echo Aborting...
echo.
echo Press any key to exit.
pause > nul
exit
)
)
)
 
:success
Echo.
 
if ""=="" (
echo No branch name input provided. Pulling the 'main' branch.
set "branchToPull=main"
)
 
 
set "gitConfigRemoteName=%~2"
 
if "^"==^"" (
echo No input remote repo name provided. Setting to default 'origin'.
set "gitConfigRemoteName=origin"
)
rem Read configurations from the config.txt file
for /F "tokens=1,* delims== " G in (config.txt) do (
if "G"=="gitConfigUser" (
set "gitConfigUser=H"
if "!gitConfigUser!"=="" set "gitConfigUser="
)
if "G"=="gitConfigPassword" (
set "gitConfigPassword=H"
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
if "G"=="gitConfigURL" (
set "gitConfigURL=H"
if "!gitConfigURL!"=="" set "gitConfigURL="
)
)
rem Removing quotes from the config values
set "gitConfigUser=!gitConfigUser:"=!"
set "gitConfigPassword=!gitConfigPassword:"=!"
set "gitConfigURL=!gitConfigURL:"=!"
 
rem Check if the string is a space character and set it to an empty variable; space is always appended >:-( though git should deal with these strings correctly nevertheless
if "^"==^" " set "gitConfigUser="
if "^"==^" " set "gitConfigPassword="
if "^"==^" " set "gitConfigURL="
 
 
rem read current/already defined Git Config to see if theyre blank; not using --global flag!
for /F "delims=" i in ('git config user.name') do set currentGitConfigUser=i
for /F "delims=" i in ('git config user.password') do set currentGitConfigPassword=i
for /F "delims=" i in ('git config --get remote..url') do set currentGitConfigURL=i
 
if "!currentGitConfigUser!"==" " set "currentGitConfigUser="
if "!currentGitConfigPassword!"==" " set "currentGitConfigPassword="
if "!currentGitConfigURL!"==" " set "currentGitConfigURL="
 
if ==0 (
REM do nothing
goto dontSkip
) else if ==1 (
goto skipUserConfig
) else (
goto skipConfig
)
 
:dontSkip
 
REM set TAB="<TAB>"
set "TAB=   "
 
Echo Current User Name: "!currentGitConfigUser!"  Read User Name: "!gitConfigUser!"
Echo Current User PWD: "!currentGitConfigPassword!"  Read User PWD: "!gitConfigPassword!"
Echo.
Echo Pulling from Host with Name: "%gitConfigRemoteName%"
Echo Current URL under this Name: "!currentGitConfigURL!"  Read URL: "!gitConfigURL!"
 
Echo.
Echo.
 
if not "!gitConfigUser!"=="" (
if "!currentGitConfigUser!"=="" (
echo Current local Git Username is not set -> new Name: "!gitConfigUser!"
git config user.name "!gitConfigUser!"
)else (
echo Current local Git Username is already set; if the overwriteGitConfigData flag is true the current Username: "!currentGitConfigUser!" will be set to "!gitConfigUser!"
if "!overwriteGitConfigData!"=="true" (
git config user.name "!gitConfigUser!"&Echo Overwriting successful; Username "!currentGitConfigUser!" changed to "!gitConfigUser!"
REM git config --global --replace-all "!gitConfigUser!"
)
)
)
 
Echo.
Echo.
 
if not "!gitConfigPassword!"=="" (
if "!currentGitConfigPassword!"=="" (
echo Current local Git Password is not set -> new Password: "!gitConfigPassword!"
git config user.password "!gitConfigPassword!"
)else (
 
echo Current local Git Password is already set; if the overwriteGitConfigData flag is true the current Password: "!currentGitConfigPassword!" will be set to "!gitConfigPassword!"
if "!overwriteGitConfigData!"=="true" (
git config user.password "!gitConfigPassword!"&Echo Overwriting successful; Password "!currentGitConfigPassword!" changed to "!gitConfigPassword!"
REM git config --replace-all --global user.password "!gitConfigPassword!"
)
)
)
 
:skipUserConfig
Echo.
Echo.
 
if not "!gitConfigURL!"=="" (
echo get displayed
echo !gitConfigURL!
echo "!currentGitConfigURL!"
 
if "!currentGitConfigURL!"=="" (
echo Current local Git fetch URL is not set -> new URL: "!gitConfigURL!"
git remote add  "!gitConfigURL!"
) else (
echo Current local Git fetch URL is already set; if the overwriteGitConfigData flag is true the current URL: "!currentGitConfigURL!" will be set to "!gitConfigURL!"
if "!overwriteGitConfigData!"=="true" (
git remote add !gitConfigRemoteName! "!gitConfigURL!" & Echo Overwriting successful; URL "!currentGitConfigURL!" changed to "!gitConfigURL!"
)
)
) else (
Echo Either Config.txt url was empty
)
:skipConfig
 
git pull %gitConfigRemoteName% %branchToPull%
 
 
if not %errorlevel% == 0(
Echo.
Echo Git ran into an Error when pulling.
Echo Have you committed your local changes?
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
Echo Resetting uncommited local changes ...
 
git reset --hard
git pull %gitConfigRemoteName% %branchToPull%
 
) else (
goto invalidNumberLength
)
) else (
:invalidNumberLength
Echo Aborting...
Echo.
Echo Press any key to exit.
Pause > nul
Exit
)
)
endlocal
@echo off
setlocal EnableDelayedExpansion
 
set "overwriteGitConfigData=true"
 
set "skipConfig=0"
REM 0==dont skip; 1==skip userConfig; >1==skip
 
 
where git >nul 2>nul && (
echo Git is installed.
) || (
start cmd.exe /k "color 4f & title Error & Echo. & Echo. & Echo Git is not properly installed! & Echo The installation will be canceled. If this is a mistake, remove the initial check from this batch file. & Echo Press any key to close this dialog & Pause > nul & Exit"
Echo Git environment variable wasnt found; Pulling will be canceled
Echo.
Echo Press any key to exit.
Pause > nul
Exit;
)
 
 
for /f i in ('git rev-parse --is-inside-work-tree 2^>^&1') do (
if /I "i"=="true" (
goto success
) else (
echo Current directory isn't a Git repository!
echo By continuing, Git will be set up here.
set /P "input=Press 'y' to continue and configure Git here; 'n' to abort this action: "
 
REM Check if the length of the input at 4th index is empty (3 chars or less) and if it starts with 'y'
set "choice=!input:~0,1!"
if /I "!choice!"=="y" (
if "!input:~3!"=="" (
echo Continuing...
echo Setting Git up in the current directory...
git init
) else (
goto wrongDirError
)
) else (
:wrongDirError
echo Aborting...
echo.
echo Press any key to exit.
pause > nul
exit
)
)
)
 
:success
Echo.
 
if ""=="" (
echo No branch name input provided. Pulling the 'main' branch.
set "branchToPull=main"
)
 
 
set "gitConfigRemoteName=%~2"
 
if "^"==^"" (
echo No input remote repo name provided. Setting to default 'origin'.
set "gitConfigRemoteName=origin"
)
rem Read configurations from the config.txt file
for /F "tokens=1,* delims== " G in (config.txt) do (
if "G"=="gitConfigUser" (
set "gitConfigUser=H"
if "!gitConfigUser!"=="" set "gitConfigUser="
)
if "G"=="gitConfigPassword" (
set "gitConfigPassword=H"
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
if "G"=="gitConfigURL" (
set "gitConfigURL=H"
if "!gitConfigURL!"=="" set "gitConfigURL="
)
)
rem Removing quotes from the config values
set "gitConfigUser=!gitConfigUser:"=!"
set "gitConfigPassword=!gitConfigPassword:"=!"
set "gitConfigURL=!gitConfigURL:"=!"
 
rem Check if the string is a space character and set it to an empty variable; space is always appended >:-( though git should deal with these strings correctly nevertheless
if "^"==^" " set "gitConfigUser="
if "^"==^" " set "gitConfigPassword="
if "^"==^" " set "gitConfigURL="
 
 
rem read current/already defined Git Config to see if theyre blank; not using --global flag!
for /F "delims=" i in ('git config user.name') do set currentGitConfigUser=i
for /F "delims=" i in ('git config user.password') do set currentGitConfigPassword=i
for /F "delims=" i in ('git config --get remote..url') do set currentGitConfigURL=i
 
if "!currentGitConfigUser!"==" " set "currentGitConfigUser="
if "!currentGitConfigPassword!"==" " set "currentGitConfigPassword="
if "!currentGitConfigURL!"==" " set "currentGitConfigURL="
 
if ==0 (
REM do nothing
goto dontSkip
) else if ==1 (
goto skipUserConfig
) else (
goto skipConfig
)
 
:dontSkip
 
REM set TAB="<TAB>"
set "TAB=   "
 
Echo Current User Name: "!currentGitConfigUser!"  Read User Name: "!gitConfigUser!"
Echo Current User PWD: "!currentGitConfigPassword!"  Read User PWD: "!gitConfigPassword!"
Echo.
Echo Pulling from Host with Name: "%gitConfigRemoteName%"
Echo Current URL under this Name: "!currentGitConfigURL!"  Read URL: "!gitConfigURL!"
 
Echo.
Echo.
 
if not "!gitConfigUser!"=="" (
if "!currentGitConfigUser!"=="" (
echo Current local Git Username is not set -> new Name: "!gitConfigUser!"
git config user.name "!gitConfigUser!"
)else (
echo Current local Git Username is already set; if the overwriteGitConfigData flag is true the current Username: "!currentGitConfigUser!" will be set to "!gitConfigUser!"
if "!overwriteGitConfigData!"=="true" (
git config user.name "!gitConfigUser!"&Echo Overwriting successful; Username "!currentGitConfigUser!" changed to "!gitConfigUser!"
REM git config --global --replace-all "!gitConfigUser!"
)
)
)
 
Echo.
Echo.
 
if not "!gitConfigPassword!"=="" (
if "!currentGitConfigPassword!"=="" (
echo Current local Git Password is not set -> new Password: "!gitConfigPassword!"
git config user.password "!gitConfigPassword!"
)else (
 
echo Current local Git Password is already set; if the overwriteGitConfigData flag is true the current Password: "!currentGitConfigPassword!" will be set to "!gitConfigPassword!"
if "!overwriteGitConfigData!"=="true" (
git config user.password "!gitConfigPassword!"&Echo Overwriting successful; Password "!currentGitConfigPassword!" changed to "!gitConfigPassword!"
REM git config --replace-all --global user.password "!gitConfigPassword!"
)
)
)
 
:skipUserConfig
Echo.
Echo.
 
if not "!gitConfigURL!"=="" (
echo get displayed
echo !gitConfigURL!
echo "!currentGitConfigURL!"
 
if "!currentGitConfigURL!"=="" (
echo Current local Git fetch URL is not set -> new URL: "!gitConfigURL!"
git remote add  "!gitConfigURL!"
) else (
echo Current local Git fetch URL is already set; if the overwriteGitConfigData flag is true the current URL: "!currentGitConfigURL!" will be set to "!gitConfigURL!"
if "!overwriteGitConfigData!"=="true" (
git remote add !gitConfigRemoteName! "!gitConfigURL!" & Echo Overwriting successful; URL "!currentGitConfigURL!" changed to "!gitConfigURL!"
)
)
) else (
Echo Either Config.txt url was empty
)
:skipConfig
 
git pull %gitConfigRemoteName% %branchToPull%
 
 
if not %errorlevel% == 0(
Echo.
Echo Git ran into an Error when pulling.
Echo Have you committed your local changes?
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
Echo Resetting uncommited local changes ...
 
git reset --hard
git pull %gitConfigRemoteName% %branchToPull%
 
) else (
goto invalidNumberLength
)
) else (
:invalidNumberLength
Echo Aborting...
Echo.
Echo Press any key to exit.
Pause > nul
Exit
)
)
endlocal
@echo off
setlocal EnableDelayedExpansion
 
set "overwriteGitConfigData=true"
 
set "skipConfig=0"
REM 0==dont skip; 1==skip userConfig; >1==skip
 
 
where git >nul 2>nul && (
echo Git is installed.
) || (
start cmd.exe /k "color 4f & title Error & Echo. & Echo. & Echo Git is not properly installed! & Echo The installation will be canceled. If this is a mistake, remove the initial check from this batch file. & Echo Press any key to close this dialog & Pause > nul & Exit"
Echo Git environment variable wasnt found; Pulling will be canceled
Echo.
Echo Press any key to exit.
Pause > nul
Exit;
)
 
 
for /f i in ('git rev-parse --is-inside-work-tree 2^>^&1') do (
if /I "i"=="true" (
goto success
) else (
echo Current directory isn't a Git repository!
echo By continuing, Git will be set up here.
set /P "input=Press 'y' to continue and configure Git here; 'n' to abort this action: "
 
REM Check if the length of the input at 4th index is empty (3 chars or less) and if it starts with 'y'
set "choice=!input:~0,1!"
if /I "!choice!"=="y" (
if "!input:~3!"=="" (
echo Continuing...
echo Setting Git up in the current directory...
git init
) else (
goto wrongDirError
)
) else (
:wrongDirError
echo Aborting...
echo.
echo Press any key to exit.
pause > nul
exit
)
)
)
 
:success
Echo.
 
if ""=="" (
echo No branch name input provided. Pulling the 'main' branch.
set "branchToPull=main"
)
 
 
set "gitConfigRemoteName=%~2"
 
if "^"==^"" (
echo No input remote repo name provided. Setting to default 'origin'.
set "gitConfigRemoteName=origin"
)
rem Read configurations from the config.txt file
for /F "tokens=1,* delims== " G in (config.txt) do (
if "G"=="gitConfigUser" (
set "gitConfigUser=H"
if "!gitConfigUser!"=="" set "gitConfigUser="
)
if "G"=="gitConfigPassword" (
set "gitConfigPassword=H"
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
if "G"=="gitConfigURL" (
set "gitConfigURL=H"
if "!gitConfigURL!"=="" set "gitConfigURL="
)
)
rem Removing quotes from the config values
set "gitConfigUser=!gitConfigUser:"=!"
set "gitConfigPassword=!gitConfigPassword:"=!"
set "gitConfigURL=!gitConfigURL:"=!"
 
rem Check if the string is a space character and set it to an empty variable; space is always appended >:-( though git should deal with these strings correctly nevertheless
if "^"==^" " set "gitConfigUser="
if "^"==^" " set "gitConfigPassword="
if "^"==^" " set "gitConfigURL="
 
 
rem read current/already defined Git Config to see if theyre blank; not using --global flag!
for /F "delims=" i in ('git config user.name') do set currentGitConfigUser=i
for /F "delims=" i in ('git config user.password') do set currentGitConfigPassword=i
for /F "delims=" i in ('git config --get remote..url') do set currentGitConfigURL=i
 
if "!currentGitConfigUser!"==" " set "currentGitConfigUser="
if "!currentGitConfigPassword!"==" " set "currentGitConfigPassword="
if "!currentGitConfigURL!"==" " set "currentGitConfigURL="
 
if ==0 (
REM do nothing
goto dontSkip
) else if ==1 (
goto skipUserConfig
) else (
goto skipConfig
)
 
:dontSkip
 
REM set TAB="<TAB>"
set "TAB=   "
 
Echo Current User Name: "!currentGitConfigUser!"  Read User Name: "!gitConfigUser!"
Echo Current User PWD: "!currentGitConfigPassword!"  Read User PWD: "!gitConfigPassword!"
Echo.
Echo Pulling from Host with Name: "%gitConfigRemoteName%"
Echo Current URL under this Name: "!currentGitConfigURL!"  Read URL: "!gitConfigURL!"
 
Echo.
Echo.
 
if not "!gitConfigUser!"=="" (
if "!currentGitConfigUser!"=="" (
echo Current local Git Username is not set -> new Name: "!gitConfigUser!"
git config user.name "!gitConfigUser!"
)else (
echo Current local Git Username is already set; if the overwriteGitConfigData flag is true the current Username: "!currentGitConfigUser!" will be set to "!gitConfigUser!"
if "!overwriteGitConfigData!"=="true" (
git config user.name "!gitConfigUser!"&Echo Overwriting successful; Username "!currentGitConfigUser!" changed to "!gitConfigUser!"
REM git config --global --replace-all "!gitConfigUser!"
)
)
)
 
Echo.
Echo.
 
if not "!gitConfigPassword!"=="" (
if "!currentGitConfigPassword!"=="" (
echo Current local Git Password is not set -> new Password: "!gitConfigPassword!"
git config user.password "!gitConfigPassword!"
)else (
 
echo Current local Git Password is already set; if the overwriteGitConfigData flag is true the current Password: "!currentGitConfigPassword!" will be set to "!gitConfigPassword!"
if "!overwriteGitConfigData!"=="true" (
git config user.password "!gitConfigPassword!"&Echo Overwriting successful; Password "!currentGitConfigPassword!" changed to "!gitConfigPassword!"
REM git config --replace-all --global user.password "!gitConfigPassword!"
)
)
)
 
:skipUserConfig
Echo.
Echo.
 
if not "!gitConfigURL!"=="" (
echo get displayed
echo !gitConfigURL!
echo "!currentGitConfigURL!"
 
if "!currentGitConfigURL!"=="" (
echo Current local Git fetch URL is not set -> new URL: "!gitConfigURL!"
git remote add  "!gitConfigURL!"
) else (
echo Current local Git fetch URL is already set; if the overwriteGitConfigData flag is true the current URL: "!currentGitConfigURL!" will be set to "!gitConfigURL!"
if "!overwriteGitConfigData!"=="true" (
git remote add !gitConfigRemoteName! "!gitConfigURL!" & Echo Overwriting successful; URL "!currentGitConfigURL!" changed to "!gitConfigURL!"
)
)
) else (
Echo Either Config.txt url was empty
)
:skipConfig
 
git pull %gitConfigRemoteName% %branchToPull%
 
 
if not %errorlevel% == 0(
Echo.
Echo Git ran into an Error when pulling.
Echo Have you committed your local changes?
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
Echo Resetting uncommited local changes ...
 
git reset --hard
git pull %gitConfigRemoteName% %branchToPull%
 
) else (
goto invalidNumberLength
)
) else (
:invalidNumberLength
Echo Aborting...
Echo.
Echo Press any key to exit.
Pause > nul
Exit
)
)
endlocal
@echo off
setlocal EnableDelayedExpansion
 
set "overwriteGitConfigData=true"
 
set "skipConfig=0"
REM 0==dont skip; 1==skip userConfig; >1==skip
 
 
where git >nul 2>nul && (
echo Git is installed.
) || (
start cmd.exe /k "color 4f & title Error & Echo. & Echo. & Echo Git is not properly installed! & Echo The installation will be canceled. If this is a mistake, remove the initial check from this batch file. & Echo Press any key to close this dialog & Pause > nul & Exit"
Echo Git environment variable wasnt found; Pulling will be canceled
Echo.
Echo Press any key to exit.
Pause > nul
Exit;
)
 
 
for /f i in ('git rev-parse --is-inside-work-tree 2^>^&1') do (
if /I "i"=="true" (
goto success
) else (
echo Current directory isn't a Git repository!
echo By continuing, Git will be set up here.
set /P "input=Press 'y' to continue and configure Git here; 'n' to abort this action: "
 
REM Check if the length of the input at 4th index is empty (3 chars or less) and if it starts with 'y'
set "choice=!input:~0,1!"
if /I "!choice!"=="y" (
if "!input:~3!"=="" (
echo Continuing...
echo Setting Git up in the current directory...
git init
) else (
goto wrongDirError
)
) else (
:wrongDirError
echo Aborting...
echo.
echo Press any key to exit.
pause > nul
exit
)
)
)
 
:success
Echo.
 
if ""=="" (
echo No branch name input provided. Pulling the 'main' branch.
set "branchToPull=main"
)
 
 
set "gitConfigRemoteName=%~2"
 
if "^"==^"" (
echo No input remote repo name provided. Setting to default 'origin'.
set "gitConfigRemoteName=origin"
)
rem Read configurations from the config.txt file
for /F "tokens=1,* delims== " G in (config.txt) do (
if "G"=="gitConfigUser" (
set "gitConfigUser=H"
if "!gitConfigUser!"=="" set "gitConfigUser="
)
if "G"=="gitConfigPassword" (
set "gitConfigPassword=H"
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
if "G"=="gitConfigURL" (
set "gitConfigURL=H"
if "!gitConfigURL!"=="" set "gitConfigURL="
)
)
rem Removing quotes from the config values
set "gitConfigUser=!gitConfigUser:"=!"
set "gitConfigPassword=!gitConfigPassword:"=!"
set "gitConfigURL=!gitConfigURL:"=!"
 
rem Check if the string is a space character and set it to an empty variable; space is always appended >:-( though git should deal with these strings correctly nevertheless
if "^"==^" " set "gitConfigUser="
if "^"==^" " set "gitConfigPassword="
if "^"==^" " set "gitConfigURL="
 
 
rem read current/already defined Git Config to see if theyre blank; not using --global flag!
for /F "delims=" i in ('git config user.name') do set currentGitConfigUser=i
for /F "delims=" i in ('git config user.password') do set currentGitConfigPassword=i
for /F "delims=" i in ('git config --get remote..url') do set currentGitConfigURL=i
 
if "!currentGitConfigUser!"==" " set "currentGitConfigUser="
if "!currentGitConfigPassword!"==" " set "currentGitConfigPassword="
if "!currentGitConfigURL!"==" " set "currentGitConfigURL="
 
if ==0 (
REM do nothing
goto dontSkip
) else if ==1 (
goto skipUserConfig
) else (
goto skipConfig
)
 
:dontSkip
 
REM set TAB="<TAB>"
set "TAB=   "
 
Echo Current User Name: "!currentGitConfigUser!"  Read User Name: "!gitConfigUser!"
Echo Current User PWD: "!currentGitConfigPassword!"  Read User PWD: "!gitConfigPassword!"
Echo.
Echo Pulling from Host with Name: "%gitConfigRemoteName%"
Echo Current URL under this Name: "!currentGitConfigURL!"  Read URL: "!gitConfigURL!"
 
Echo.
Echo.
 
if not "!gitConfigUser!"=="" (
if "!currentGitConfigUser!"=="" (
echo Current local Git Username is not set -> new Name: "!gitConfigUser!"
git config user.name "!gitConfigUser!"
)else (
echo Current local Git Username is already set; if the overwriteGitConfigData flag is true the current Username: "!currentGitConfigUser!" will be set to "!gitConfigUser!"
if "!overwriteGitConfigData!"=="true" (
git config user.name "!gitConfigUser!"&Echo Overwriting successful; Username "!currentGitConfigUser!" changed to "!gitConfigUser!"
REM git config --global --replace-all "!gitConfigUser!"
)
)
)
 
Echo.
Echo.
 
if not "!gitConfigPassword!"=="" (
if "!currentGitConfigPassword!"=="" (
echo Current local Git Password is not set -> new Password: "!gitConfigPassword!"
git config user.password "!gitConfigPassword!"
)else (
 
echo Current local Git Password is already set; if the overwriteGitConfigData flag is true the current Password: "!currentGitConfigPassword!" will be set to "!gitConfigPassword!"
if "!overwriteGitConfigData!"=="true" (
git config user.password "!gitConfigPassword!"&Echo Overwriting successful; Password "!currentGitConfigPassword!" changed to "!gitConfigPassword!"
REM git config --replace-all --global user.password "!gitConfigPassword!"
)
)
)
 
:skipUserConfig
Echo.
Echo.
 
if not "!gitConfigURL!"=="" (
echo get displayed
echo !gitConfigURL!
echo "!currentGitConfigURL!"
 
if "!currentGitConfigURL!"=="" (
echo Current local Git fetch URL is not set -> new URL: "!gitConfigURL!"
git remote add  "!gitConfigURL!"
) else (
echo Current local Git fetch URL is already set; if the overwriteGitConfigData flag is true the current URL: "!currentGitConfigURL!" will be set to "!gitConfigURL!"
if "!overwriteGitConfigData!"=="true" (
git remote add !gitConfigRemoteName! "!gitConfigURL!" & Echo Overwriting successful; URL "!currentGitConfigURL!" changed to "!gitConfigURL!"
)
)
) else (
Echo Either Config.txt url was empty
)
:skipConfig
 
git pull %gitConfigRemoteName% %branchToPull%
 
 
if not %errorlevel% == 0(
Echo.
Echo Git ran into an Error when pulling.
Echo Have you committed your local changes?
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
Echo Resetting uncommited local changes ...
 
git reset --hard
git pull %gitConfigRemoteName% %branchToPull%
 
) else (
goto invalidNumberLength
)
) else (
:invalidNumberLength
Echo Aborting...
Echo.
Echo Press any key to exit.
Pause > nul
Exit
)
)
endlocal
@echo off
setlocal EnableDelayedExpansion
 
set "overwriteGitConfigData=true"
 
set "skipConfig=0"
REM 0==dont skip; 1==skip userConfig; >1==skip
 
 
where git >nul 2>nul && (
echo Git is installed.
) || (
start cmd.exe /k "color 4f & title Error & Echo. & Echo. & Echo Git is not properly installed! & Echo The installation will be canceled. If this is a mistake, remove the initial check from this batch file. & Echo Press any key to close this dialog & Pause > nul & Exit"
Echo Git environment variable wasnt found; Pulling will be canceled
Echo.
Echo Press any key to exit.
Pause > nul
Exit;
)
 
 
for /f i in ('git rev-parse --is-inside-work-tree 2^>^&1') do (
if /I "i"=="true" (
goto success
) else (
echo Current directory isn't a Git repository!
echo By continuing, Git will be set up here.
set /P "input=Press 'y' to continue and configure Git here; 'n' to abort this action: "
 
REM Check if the length of the input at 4th index is empty (3 chars or less) and if it starts with 'y'
set "choice=!input:~0,1!"
if /I "!choice!"=="y" (
if "!input:~3!"=="" (
echo Continuing...
echo Setting Git up in the current directory...
git init
) else (
goto wrongDirError
)
) else (
:wrongDirError
echo Aborting...
echo.
echo Press any key to exit.
pause > nul
exit
)
)
)
 
:success
Echo.
 
if ""=="" (
echo No branch name input provided. Pulling the 'main' branch.
set "branchToPull=main"
)
 
 
set "gitConfigRemoteName=%~2"
 
if "^"==^"" (
echo No input remote repo name provided. Setting to default 'origin'.
set "gitConfigRemoteName=origin"
)
rem Read configurations from the config.txt file
for /F "tokens=1,* delims== " G in (config.txt) do (
if "G"=="gitConfigUser" (
set "gitConfigUser=H"
if "!gitConfigUser!"=="" set "gitConfigUser="
)
if "G"=="gitConfigPassword" (
set "gitConfigPassword=H"
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
if "G"=="gitConfigURL" (
set "gitConfigURL=H"
if "!gitConfigURL!"=="" set "gitConfigURL="
)
)
rem Removing quotes from the config values
set "gitConfigUser=!gitConfigUser:"=!"
set "gitConfigPassword=!gitConfigPassword:"=!"
set "gitConfigURL=!gitConfigURL:"=!"
 
rem Check if the string is a space character and set it to an empty variable; space is always appended >:-( though git should deal with these strings correctly nevertheless
if "^"==^" " set "gitConfigUser="
if "^"==^" " set "gitConfigPassword="
if "^"==^" " set "gitConfigURL="
 
 
rem read current/already defined Git Config to see if theyre blank; not using --global flag!
for /F "delims=" i in ('git config user.name') do set currentGitConfigUser=i
for /F "delims=" i in ('git config user.password') do set currentGitConfigPassword=i
for /F "delims=" i in ('git config --get remote..url') do set currentGitConfigURL=i
 
if "!currentGitConfigUser!"==" " set "currentGitConfigUser="
if "!currentGitConfigPassword!"==" " set "currentGitConfigPassword="
if "!currentGitConfigURL!"==" " set "currentGitConfigURL="
 
if ==0 (
REM do nothing
goto dontSkip
) else if ==1 (
goto skipUserConfig
) else (
goto skipConfig
)
 
:dontSkip
 
REM set TAB="<TAB>"
set "TAB=   "
 
Echo Current User Name: "!currentGitConfigUser!"  Read User Name: "!gitConfigUser!"
Echo Current User PWD: "!currentGitConfigPassword!"  Read User PWD: "!gitConfigPassword!"
Echo.
Echo Pulling from Host with Name: "%gitConfigRemoteName%"
Echo Current URL under this Name: "!currentGitConfigURL!"  Read URL: "!gitConfigURL!"
 
Echo.
Echo.
 
if not "!gitConfigUser!"=="" (
if "!currentGitConfigUser!"=="" (
echo Current local Git Username is not set -> new Name: "!gitConfigUser!"
git config user.name "!gitConfigUser!"
)else (
echo Current local Git Username is already set; if the overwriteGitConfigData flag is true the current Username: "!currentGitConfigUser!" will be set to "!gitConfigUser!"
if "!overwriteGitConfigData!"=="true" (
git config user.name "!gitConfigUser!"&Echo Overwriting successful; Username "!currentGitConfigUser!" changed to "!gitConfigUser!"
REM git config --global --replace-all "!gitConfigUser!"
)
)
)
 
Echo.
Echo.
 
if not "!gitConfigPassword!"=="" (
if "!currentGitConfigPassword!"=="" (
echo Current local Git Password is not set -> new Password: "!gitConfigPassword!"
git config user.password "!gitConfigPassword!"
)else (
 
echo Current local Git Password is already set; if the overwriteGitConfigData flag is true the current Password: "!currentGitConfigPassword!" will be set to "!gitConfigPassword!"
if "!overwriteGitConfigData!"=="true" (
git config user.password "!gitConfigPassword!"&Echo Overwriting successful; Password "!currentGitConfigPassword!" changed to "!gitConfigPassword!"
REM git config --replace-all --global user.password "!gitConfigPassword!"
)
)
)
 
:skipUserConfig
Echo.
Echo.
 
if not "!gitConfigURL!"=="" (
echo get displayed
echo !gitConfigURL!
echo "!currentGitConfigURL!"
 
if "!currentGitConfigURL!"=="" (
echo Current local Git fetch URL is not set -> new URL: "!gitConfigURL!"
git remote add  "!gitConfigURL!"
) else (
echo Current local Git fetch URL is already set; if the overwriteGitConfigData flag is true the current URL: "!currentGitConfigURL!" will be set to "!gitConfigURL!"
if "!overwriteGitConfigData!"=="true" (
git remote add !gitConfigRemoteName! "!gitConfigURL!" & Echo Overwriting successful; URL "!currentGitConfigURL!" changed to "!gitConfigURL!"
)
)
) else (
Echo Either Config.txt url was empty
)
:skipConfig
 
git pull %gitConfigRemoteName% %branchToPull%
 
 
if not %errorlevel% == 0(
Echo.
Echo Git ran into an Error when pulling.
Echo Have you committed your local changes?
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
Echo Resetting uncommited local changes ...
 
git reset --hard
git pull %gitConfigRemoteName% %branchToPull%
 
) else (
goto invalidNumberLength
)
) else (
:invalidNumberLength
Echo Aborting...
Echo.
Echo Press any key to exit.
Pause > nul
Exit
)
)
endlocal
@echo off
setlocal EnableDelayedExpansion
 
set "overwriteGitConfigData=true"
 
set "skipConfig=0"
REM 0==dont skip; 1==skip userConfig; >1==skip
 
 
where git >nul 2>nul && (
echo Git is installed.
) || (
start cmd.exe /k "color 4f & title Error & Echo. & Echo. & Echo Git is not properly installed! & Echo The installation will be canceled. If this is a mistake, remove the initial check from this batch file. & Echo Press any key to close this dialog & Pause > nul & Exit"
Echo Git environment variable wasnt found; Pulling will be canceled
Echo.
Echo Press any key to exit.
Pause > nul
Exit;
)
 
 
for /f i in ('git rev-parse --is-inside-work-tree 2^>^&1') do (
if /I "i"=="true" (
goto success
) else (
echo Current directory isn't a Git repository!
echo By continuing, Git will be set up here.
set /P "input=Press 'y' to continue and configure Git here; 'n' to abort this action: "
 
REM Check if the length of the input at 4th index is empty (3 chars or less) and if it starts with 'y'
set "choice=!input:~0,1!"
if /I "!choice!"=="y" (
if "!input:~3!"=="" (
echo Continuing...
echo Setting Git up in the current directory...
git init
) else (
goto wrongDirError
)
) else (
:wrongDirError
echo Aborting...
echo.
echo Press any key to exit.
pause > nul
exit
)
)
)
 
:success
Echo.
 
if ""=="" (
echo No branch name input provided. Pulling the 'main' branch.
set "branchToPull=main"
)
 
 
set "gitConfigRemoteName=%~2"
 
if "^"==^"" (
echo No input remote repo name provided. Setting to default 'origin'.
set "gitConfigRemoteName=origin"
)
rem Read configurations from the config.txt file
for /F "tokens=1,* delims== " G in (config.txt) do (
if "G"=="gitConfigUser" (
set "gitConfigUser=H"
if "!gitConfigUser!"=="" set "gitConfigUser="
)
if "G"=="gitConfigPassword" (
set "gitConfigPassword=H"
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
if "G"=="gitConfigURL" (
set "gitConfigURL=H"
if "!gitConfigURL!"=="" set "gitConfigURL="
)
)
rem Removing quotes from the config values
set "gitConfigUser=!gitConfigUser:"=!"
set "gitConfigPassword=!gitConfigPassword:"=!"
set "gitConfigURL=!gitConfigURL:"=!"
 
rem Check if the string is a space character and set it to an empty variable; space is always appended >:-( though git should deal with these strings correctly nevertheless
if "^"==^" " set "gitConfigUser="
if "^"==^" " set "gitConfigPassword="
if "^"==^" " set "gitConfigURL="
 
 
rem read current/already defined Git Config to see if theyre blank; not using --global flag!
for /F "delims=" i in ('git config user.name') do set currentGitConfigUser=i
for /F "delims=" i in ('git config user.password') do set currentGitConfigPassword=i
for /F "delims=" i in ('git config --get remote..url') do set currentGitConfigURL=i
 
if "!currentGitConfigUser!"==" " set "currentGitConfigUser="
if "!currentGitConfigPassword!"==" " set "currentGitConfigPassword="
if "!currentGitConfigURL!"==" " set "currentGitConfigURL="
 
if ==0 (
REM do nothing
goto dontSkip
) else if ==1 (
goto skipUserConfig
) else (
goto skipConfig
)
 
:dontSkip
 
REM set TAB="<TAB>"
set "TAB=   "
 
Echo Current User Name: "!currentGitConfigUser!"  Read User Name: "!gitConfigUser!"
Echo Current User PWD: "!currentGitConfigPassword!"  Read User PWD: "!gitConfigPassword!"
Echo.
Echo Pulling from Host with Name: "%gitConfigRemoteName%"
Echo Current URL under this Name: "!currentGitConfigURL!"  Read URL: "!gitConfigURL!"
 
Echo.
Echo.
 
if not "!gitConfigUser!"=="" (
if "!currentGitConfigUser!"=="" (
echo Current local Git Username is not set -> new Name: "!gitConfigUser!"
git config user.name "!gitConfigUser!"
)else (
echo Current local Git Username is already set; if the overwriteGitConfigData flag is true the current Username: "!currentGitConfigUser!" will be set to "!gitConfigUser!"
if "!overwriteGitConfigData!"=="true" (
git config user.name "!gitConfigUser!"&Echo Overwriting successful; Username "!currentGitConfigUser!" changed to "!gitConfigUser!"
REM git config --global --replace-all "!gitConfigUser!"
)
)
)
 
Echo.
Echo.
 
if not "!gitConfigPassword!"=="" (
if "!currentGitConfigPassword!"=="" (
echo Current local Git Password is not set -> new Password: "!gitConfigPassword!"
git config user.password "!gitConfigPassword!"
)else (
 
echo Current local Git Password is already set; if the overwriteGitConfigData flag is true the current Password: "!currentGitConfigPassword!" will be set to "!gitConfigPassword!"
if "!overwriteGitConfigData!"=="true" (
git config user.password "!gitConfigPassword!"&Echo Overwriting successful; Password "!currentGitConfigPassword!" changed to "!gitConfigPassword!"
REM git config --replace-all --global user.password "!gitConfigPassword!"
)
)
)
 
:skipUserConfig
Echo.
Echo.
 
if not "!gitConfigURL!"=="" (
echo get displayed
echo !gitConfigURL!
echo "!currentGitConfigURL!"
 
if "!currentGitConfigURL!"=="" (
echo Current local Git fetch URL is not set -> new URL: "!gitConfigURL!"
git remote add  "!gitConfigURL!"
) else (
echo Current local Git fetch URL is already set; if the overwriteGitConfigData flag is true the current URL: "!currentGitConfigURL!" will be set to "!gitConfigURL!"
if "!overwriteGitConfigData!"=="true" (
git remote add !gitConfigRemoteName! "!gitConfigURL!" & Echo Overwriting successful; URL "!currentGitConfigURL!" changed to "!gitConfigURL!"
)
)
) else (
Echo Either Config.txt url was empty
)
:skipConfig
 
git pull %gitConfigRemoteName% %branchToPull%
 
 
if not %errorlevel% == 0(
Echo.
Echo Git ran into an Error when pulling.
Echo Have you committed your local changes?
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
Echo Resetting uncommited local changes ...
 
git reset --hard
git pull %gitConfigRemoteName% %branchToPull%
 
) else (
goto invalidNumberLength
)
) else (
:invalidNumberLength
Echo Aborting...
Echo.
Echo Press any key to exit.
Pause > nul
Exit
)
)
endlocal
@echo off
setlocal EnableDelayedExpansion
 
set "overwriteGitConfigData=true"
 
set "skipConfig=0"
REM 0==dont skip; 1==skip userConfig; >1==skip
 
 
where git >nul 2>nul && (
echo Git is installed.
) || (
start cmd.exe /k "color 4f & title Error & Echo. & Echo. & Echo Git is not properly installed! & Echo The installation will be canceled. If this is a mistake, remove the initial check from this batch file. & Echo Press any key to close this dialog & Pause > nul & Exit"
Echo Git environment variable wasnt found; Pulling will be canceled
Echo.
Echo Press any key to exit.
Pause > nul
Exit;
)
 
 
for /f i in ('git rev-parse --is-inside-work-tree 2^>^&1') do (
if /I "i"=="true" (
goto success
) else (
echo Current directory isn't a Git repository!
echo By continuing, Git will be set up here.
set /P "input=Press 'y' to continue and configure Git here; 'n' to abort this action: "
 
REM Check if the length of the input at 4th index is empty (3 chars or less) and if it starts with 'y'
set "choice=!input:~0,1!"
if /I "!choice!"=="y" (
if "!input:~3!"=="" (
echo Continuing...
echo Setting Git up in the current directory...
git init
) else (
goto wrongDirError
)
) else (
:wrongDirError
echo Aborting...
echo.
echo Press any key to exit.
pause > nul
exit
)
)
)
 
:success
Echo.
 
if ""=="" (
echo No branch name input provided. Pulling the 'main' branch.
set "branchToPull=main"
)
 
 
set "gitConfigRemoteName=%~2"
 
if "^"==^"" (
echo No input remote repo name provided. Setting to default 'origin'.
set "gitConfigRemoteName=origin"
)
rem Read configurations from the config.txt file
for /F "tokens=1,* delims== " G in (config.txt) do (
if "G"=="gitConfigUser" (
set "gitConfigUser=H"
if "!gitConfigUser!"=="" set "gitConfigUser="
)
if "G"=="gitConfigPassword" (
set "gitConfigPassword=H"
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
if "G"=="gitConfigURL" (
set "gitConfigURL=H"
if "!gitConfigURL!"=="" set "gitConfigURL="
)
)
rem Removing quotes from the config values
set "gitConfigUser=!gitConfigUser:"=!"
set "gitConfigPassword=!gitConfigPassword:"=!"
set "gitConfigURL=!gitConfigURL:"=!"
 
rem Check if the string is a space character and set it to an empty variable; space is always appended >:-( though git should deal with these strings correctly nevertheless
if "^"==^" " set "gitConfigUser="
if "^"==^" " set "gitConfigPassword="
if "^"==^" " set "gitConfigURL="
 
 
rem read current/already defined Git Config to see if theyre blank; not using --global flag!
for /F "delims=" i in ('git config user.name') do set currentGitConfigUser=i
for /F "delims=" i in ('git config user.password') do set currentGitConfigPassword=i
for /F "delims=" i in ('git config --get remote..url') do set currentGitConfigURL=i
 
if "!currentGitConfigUser!"==" " set "currentGitConfigUser="
if "!currentGitConfigPassword!"==" " set "currentGitConfigPassword="
if "!currentGitConfigURL!"==" " set "currentGitConfigURL="
 
if ==0 (
REM do nothing
goto dontSkip
) else if ==1 (
goto skipUserConfig
) else (
goto skipConfig
)
 
:dontSkip
 
REM set TAB="<TAB>"
set "TAB=   "
 
Echo Current User Name: "!currentGitConfigUser!"  Read User Name: "!gitConfigUser!"
Echo Current User PWD: "!currentGitConfigPassword!"  Read User PWD: "!gitConfigPassword!"
Echo.
Echo Pulling from Host with Name: "%gitConfigRemoteName%"
Echo Current URL under this Name: "!currentGitConfigURL!"  Read URL: "!gitConfigURL!"
 
Echo.
Echo.
 
if not "!gitConfigUser!"=="" (
if "!currentGitConfigUser!"=="" (
echo Current local Git Username is not set -> new Name: "!gitConfigUser!"
git config user.name "!gitConfigUser!"
)else (
echo Current local Git Username is already set; if the overwriteGitConfigData flag is true the current Username: "!currentGitConfigUser!" will be set to "!gitConfigUser!"
if "!overwriteGitConfigData!"=="true" (
git config user.name "!gitConfigUser!"&Echo Overwriting successful; Username "!currentGitConfigUser!" changed to "!gitConfigUser!"
REM git config --global --replace-all "!gitConfigUser!"
)
)
)
 
Echo.
Echo.
 
if not "!gitConfigPassword!"=="" (
if "!currentGitConfigPassword!"=="" (
echo Current local Git Password is not set -> new Password: "!gitConfigPassword!"
git config user.password "!gitConfigPassword!"
)else (
 
echo Current local Git Password is already set; if the overwriteGitConfigData flag is true the current Password: "!currentGitConfigPassword!" will be set to "!gitConfigPassword!"
if "!overwriteGitConfigData!"=="true" (
git config user.password "!gitConfigPassword!"&Echo Overwriting successful; Password "!currentGitConfigPassword!" changed to "!gitConfigPassword!"
REM git config --replace-all --global user.password "!gitConfigPassword!"
)
)
)
 
:skipUserConfig
Echo.
Echo.
 
if not "!gitConfigURL!"=="" (
echo get displayed
echo !gitConfigURL!
echo "!currentGitConfigURL!"
 
if "!currentGitConfigURL!"=="" (
echo Current local Git fetch URL is not set -> new URL: "!gitConfigURL!"
git remote add  "!gitConfigURL!"
) else (
echo Current local Git fetch URL is already set; if the overwriteGitConfigData flag is true the current URL: "!currentGitConfigURL!" will be set to "!gitConfigURL!"
if "!overwriteGitConfigData!"=="true" (
git remote add !gitConfigRemoteName! "!gitConfigURL!" & Echo Overwriting successful; URL "!currentGitConfigURL!" changed to "!gitConfigURL!"
)
)
) else (
Echo Either Config.txt url was empty
)
:skipConfig
 
git pull %gitConfigRemoteName% %branchToPull%
 
 
if not %errorlevel% == 0(
Echo.
Echo Git ran into an Error when pulling.
Echo Have you committed your local changes?
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
Echo Resetting uncommited local changes ...
 
git reset --hard
git pull %gitConfigRemoteName% %branchToPull%
 
) else (
goto invalidNumberLength
)
) else (
:invalidNumberLength
Echo Aborting...
Echo.
Echo Press any key to exit.
Pause > nul
Exit
)
)
endlocal
@echo off
setlocal EnableDelayedExpansion
 
set "overwriteGitConfigData=true"
 
set "skipConfig=0"
REM 0==dont skip; 1==skip userConfig; >1==skip
 
 
where git >nul 2>nul && (
echo Git is installed.
) || (
start cmd.exe /k "color 4f & title Error & Echo. & Echo. & Echo Git is not properly installed! & Echo The installation will be canceled. If this is a mistake, remove the initial check from this batch file. & Echo Press any key to close this dialog & Pause > nul & Exit"
Echo Git environment variable wasnt found; Pulling will be canceled
Echo.
Echo Press any key to exit.
Pause > nul
Exit;
)
 
 
for /f i in ('git rev-parse --is-inside-work-tree 2^>^&1') do (
if /I "i"=="true" (
goto success
) else (
echo Current directory isn't a Git repository!
echo By continuing, Git will be set up here.
set /P "input=Press 'y' to continue and configure Git here; 'n' to abort this action: "
 
REM Check if the length of the input at 4th index is empty (3 chars or less) and if it starts with 'y'
set "choice=!input:~0,1!"
if /I "!choice!"=="y" (
if "!input:~3!"=="" (
echo Continuing...
echo Setting Git up in the current directory...
git init
) else (
goto wrongDirError
)
) else (
:wrongDirError
echo Aborting...
echo.
echo Press any key to exit.
pause > nul
exit
)
)
)
 
:success
Echo.
 
if ""=="" (
echo No branch name input provided. Pulling the 'main' branch.
set "branchToPull=main"
)
 
 
set "gitConfigRemoteName=%~2"
 
if "^"==^"" (
echo No input remote repo name provided. Setting to default 'origin'.
set "gitConfigRemoteName=origin"
)
rem Read configurations from the config.txt file
for /F "tokens=1,* delims== " G in (config.txt) do (
if "G"=="gitConfigUser" (
set "gitConfigUser=H"
if "!gitConfigUser!"=="" set "gitConfigUser="
)
if "G"=="gitConfigPassword" (
set "gitConfigPassword=H"
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
if "G"=="gitConfigURL" (
set "gitConfigURL=H"
if "!gitConfigURL!"=="" set "gitConfigURL="
)
)
rem Removing quotes from the config values
set "gitConfigUser=!gitConfigUser:"=!"
set "gitConfigPassword=!gitConfigPassword:"=!"
set "gitConfigURL=!gitConfigURL:"=!"
 
rem Check if the string is a space character and set it to an empty variable; space is always appended >:-( though git should deal with these strings correctly nevertheless
if "^"==^" " set "gitConfigUser="
if "^"==^" " set "gitConfigPassword="
if "^"==^" " set "gitConfigURL="
 
 
rem read current/already defined Git Config to see if theyre blank; not using --global flag!
for /F "delims=" i in ('git config user.name') do set currentGitConfigUser=i
for /F "delims=" i in ('git config user.password') do set currentGitConfigPassword=i
for /F "delims=" i in ('git config --get remote..url') do set currentGitConfigURL=i
 
if "!currentGitConfigUser!"==" " set "currentGitConfigUser="
if "!currentGitConfigPassword!"==" " set "currentGitConfigPassword="
if "!currentGitConfigURL!"==" " set "currentGitConfigURL="
 
if ==0 (
REM do nothing
goto dontSkip
) else if ==1 (
goto skipUserConfig
) else (
goto skipConfig
)
 
:dontSkip
 
REM set TAB="<TAB>"
set "TAB=   "
 
Echo Current User Name: "!currentGitConfigUser!"  Read User Name: "!gitConfigUser!"
Echo Current User PWD: "!currentGitConfigPassword!"  Read User PWD: "!gitConfigPassword!"
Echo.
Echo Pulling from Host with Name: "%gitConfigRemoteName%"
Echo Current URL under this Name: "!currentGitConfigURL!"  Read URL: "!gitConfigURL!"
 
Echo.
Echo.
 
if not "!gitConfigUser!"=="" (
if "!currentGitConfigUser!"=="" (
echo Current local Git Username is not set -> new Name: "!gitConfigUser!"
git config user.name "!gitConfigUser!"
)else (
echo Current local Git Username is already set; if the overwriteGitConfigData flag is true the current Username: "!currentGitConfigUser!" will be set to "!gitConfigUser!"
if "!overwriteGitConfigData!"=="true" (
git config user.name "!gitConfigUser!"&Echo Overwriting successful; Username "!currentGitConfigUser!" changed to "!gitConfigUser!"
REM git config --global --replace-all "!gitConfigUser!"
)
)
)
 
Echo.
Echo.
 
if not "!gitConfigPassword!"=="" (
if "!currentGitConfigPassword!"=="" (
echo Current local Git Password is not set -> new Password: "!gitConfigPassword!"
git config user.password "!gitConfigPassword!"
)else (
 
echo Current local Git Password is already set; if the overwriteGitConfigData flag is true the current Password: "!currentGitConfigPassword!" will be set to "!gitConfigPassword!"
if "!overwriteGitConfigData!"=="true" (
git config user.password "!gitConfigPassword!"&Echo Overwriting successful; Password "!currentGitConfigPassword!" changed to "!gitConfigPassword!"
REM git config --replace-all --global user.password "!gitConfigPassword!"
)
)
)
 
:skipUserConfig
Echo.
Echo.
 
if not "!gitConfigURL!"=="" (
echo get displayed
echo !gitConfigURL!
echo "!currentGitConfigURL!"
 
if "!currentGitConfigURL!"=="" (
echo Current local Git fetch URL is not set -> new URL: "!gitConfigURL!"
git remote add  "!gitConfigURL!"
) else (
echo Current local Git fetch URL is already set; if the overwriteGitConfigData flag is true the current URL: "!currentGitConfigURL!" will be set to "!gitConfigURL!"
if "!overwriteGitConfigData!"=="true" (
git remote add !gitConfigRemoteName! "!gitConfigURL!" & Echo Overwriting successful; URL "!currentGitConfigURL!" changed to "!gitConfigURL!"
)
)
) else (
Echo Either Config.txt url was empty
)
:skipConfig
 
git pull %gitConfigRemoteName% %branchToPull%
 
 
if not %errorlevel% == 0(
Echo.
Echo Git ran into an Error when pulling.
Echo Have you committed your local changes?
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
Echo Resetting uncommited local changes ...
 
git reset --hard
git pull %gitConfigRemoteName% %branchToPull%
 
) else (
goto invalidNumberLength
)
) else (
:invalidNumberLength
Echo Aborting...
Echo.
Echo Press any key to exit.
Pause > nul
Exit
)
)
endlocal
@echo off
setlocal EnableDelayedExpansion
 
set "overwriteGitConfigData=true"
 
set "skipConfig=0"
REM 0==dont skip; 1==skip userConfig; >1==skip
 
 
where git >nul 2>nul && (
echo Git is installed.
) || (
start cmd.exe /k "color 4f & title Error & Echo. & Echo. & Echo Git is not properly installed! & Echo The installation will be canceled. If this is a mistake, remove the initial check from this batch file. & Echo Press any key to close this dialog & Pause > nul & Exit"
Echo Git environment variable wasnt found; Pulling will be canceled
Echo.
Echo Press any key to exit.
Pause > nul
Exit;
)
 
 
for /f i in ('git rev-parse --is-inside-work-tree 2^>^&1') do (
if /I "i"=="true" (
goto success
) else (
echo Current directory isn't a Git repository!
echo By continuing, Git will be set up here.
set /P "input=Press 'y' to continue and configure Git here; 'n' to abort this action: "
 
REM Check if the length of the input at 4th index is empty (3 chars or less) and if it starts with 'y'
set "choice=!input:~0,1!"
if /I "!choice!"=="y" (
if "!input:~3!"=="" (
echo Continuing...
echo Setting Git up in the current directory...
git init
) else (
goto wrongDirError
)
) else (
:wrongDirError
echo Aborting...
echo.
echo Press any key to exit.
pause > nul
exit
)
)
)
 
:success
Echo.
 
if ""=="" (
echo No branch name input provided. Pulling the 'main' branch.
set "branchToPull=main"
)
 
 
set "gitConfigRemoteName=%~2"
 
if "^"==^"" (
echo No input remote repo name provided. Setting to default 'origin'.
set "gitConfigRemoteName=origin"
)
rem Read configurations from the config.txt file
for /F "tokens=1,* delims== " G in (config.txt) do (
if "G"=="gitConfigUser" (
set "gitConfigUser=H"
if "!gitConfigUser!"=="" set "gitConfigUser="
)
if "G"=="gitConfigPassword" (
set "gitConfigPassword=H"
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
if "G"=="gitConfigURL" (
set "gitConfigURL=H"
if "!gitConfigURL!"=="" set "gitConfigURL="
)
)
rem Removing quotes from the config values
set "gitConfigUser=!gitConfigUser:"=!"
set "gitConfigPassword=!gitConfigPassword:"=!"
set "gitConfigURL=!gitConfigURL:"=!"
 
rem Check if the string is a space character and set it to an empty variable; space is always appended >:-( though git should deal with these strings correctly nevertheless
if "^"==^" " set "gitConfigUser="
if "^"==^" " set "gitConfigPassword="
if "^"==^" " set "gitConfigURL="
 
 
rem read current/already defined Git Config to see if theyre blank; not using --global flag!
for /F "delims=" i in ('git config user.name') do set currentGitConfigUser=i
for /F "delims=" i in ('git config user.password') do set currentGitConfigPassword=i
for /F "delims=" i in ('git config --get remote..url') do set currentGitConfigURL=i
 
if "!currentGitConfigUser!"==" " set "currentGitConfigUser="
if "!currentGitConfigPassword!"==" " set "currentGitConfigPassword="
if "!currentGitConfigURL!"==" " set "currentGitConfigURL="
 
if ==0 (
REM do nothing
goto dontSkip
) else if ==1 (
goto skipUserConfig
) else (
goto skipConfig
)
 
:dontSkip
 
REM set TAB="<TAB>"
set "TAB=   "
 
Echo Current User Name: "!currentGitConfigUser!"  Read User Name: "!gitConfigUser!"
Echo Current User PWD: "!currentGitConfigPassword!"  Read User PWD: "!gitConfigPassword!"
Echo.
Echo Pulling from Host with Name: "%gitConfigRemoteName%"
Echo Current URL under this Name: "!currentGitConfigURL!"  Read URL: "!gitConfigURL!"
 
Echo.
Echo.
 
if not "!gitConfigUser!"=="" (
if "!currentGitConfigUser!"=="" (
echo Current local Git Username is not set -> new Name: "!gitConfigUser!"
git config user.name "!gitConfigUser!"
)else (
echo Current local Git Username is already set; if the overwriteGitConfigData flag is true the current Username: "!currentGitConfigUser!" will be set to "!gitConfigUser!"
if "!overwriteGitConfigData!"=="true" (
git config user.name "!gitConfigUser!"&Echo Overwriting successful; Username "!currentGitConfigUser!" changed to "!gitConfigUser!"
REM git config --global --replace-all "!gitConfigUser!"
)
)
)
 
Echo.
Echo.
 
if not "!gitConfigPassword!"=="" (
if "!currentGitConfigPassword!"=="" (
echo Current local Git Password is not set -> new Password: "!gitConfigPassword!"
git config user.password "!gitConfigPassword!"
)else (
 
echo Current local Git Password is already set; if the overwriteGitConfigData flag is true the current Password: "!currentGitConfigPassword!" will be set to "!gitConfigPassword!"
if "!overwriteGitConfigData!"=="true" (
git config user.password "!gitConfigPassword!"&Echo Overwriting successful; Password "!currentGitConfigPassword!" changed to "!gitConfigPassword!"
REM git config --replace-all --global user.password "!gitConfigPassword!"
)
)
)
 
:skipUserConfig
Echo.
Echo.
 
if not "!gitConfigURL!"=="" (
echo get displayed
echo !gitConfigURL!
echo "!currentGitConfigURL!"
 
if "!currentGitConfigURL!"=="" (
echo Current local Git fetch URL is not set -> new URL: "!gitConfigURL!"
git remote add  "!gitConfigURL!"
) else (
echo Current local Git fetch URL is already set; if the overwriteGitConfigData flag is true the current URL: "!currentGitConfigURL!" will be set to "!gitConfigURL!"
if "!overwriteGitConfigData!"=="true" (
git remote add !gitConfigRemoteName! "!gitConfigURL!" & Echo Overwriting successful; URL "!currentGitConfigURL!" changed to "!gitConfigURL!"
)
)
) else (
Echo Either Config.txt url was empty
)
:skipConfig
 
git pull %gitConfigRemoteName% %branchToPull%
 
 
if not %errorlevel% == 0(
Echo.
Echo Git ran into an Error when pulling.
Echo Have you committed your local changes?
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
Echo Resetting uncommited local changes ...
 
git reset --hard
git pull %gitConfigRemoteName% %branchToPull%
 
) else (
goto invalidNumberLength
)
) else (
:invalidNumberLength
Echo Aborting...
Echo.
Echo Press any key to exit.
Pause > nul
Exit
)
)
endlocal
@echo off
setlocal EnableDelayedExpansion
 
set "overwriteGitConfigData=true"
 
set "skipConfig=0"
REM 0==dont skip; 1==skip userConfig; >1==skip
 
 
where git >nul 2>nul && (
echo Git is installed.
) || (
start cmd.exe /k "color 4f & title Error & Echo. & Echo. & Echo Git is not properly installed! & Echo The installation will be canceled. If this is a mistake, remove the initial check from this batch file. & Echo Press any key to close this dialog & Pause > nul & Exit"
Echo Git environment variable wasnt found; Pulling will be canceled
Echo.
Echo Press any key to exit.
Pause > nul
Exit;
)
 
 
for /f i in ('git rev-parse --is-inside-work-tree 2^>^&1') do (
if /I "i"=="true" (
goto success
) else (
echo Current directory isn't a Git repository!
echo By continuing, Git will be set up here.
set /P "input=Press 'y' to continue and configure Git here; 'n' to abort this action: "
 
REM Check if the length of the input at 4th index is empty (3 chars or less) and if it starts with 'y'
set "choice=!input:~0,1!"
if /I "!choice!"=="y" (
if "!input:~3!"=="" (
echo Continuing...
echo Setting Git up in the current directory...
git init
) else (
goto wrongDirError
)
) else (
:wrongDirError
echo Aborting...
echo.
echo Press any key to exit.
pause > nul
exit
)
)
)
 
:success
Echo.
 
if ""=="" (
echo No branch name input provided. Pulling the 'main' branch.
set "branchToPull=main"
)
 
 
set "gitConfigRemoteName=%~2"
 
if "^"==^"" (
echo No input remote repo name provided. Setting to default 'origin'.
set "gitConfigRemoteName=origin"
)
rem Read configurations from the config.txt file
for /F "tokens=1,* delims== " G in (config.txt) do (
if "G"=="gitConfigUser" (
set "gitConfigUser=H"
if "!gitConfigUser!"=="" set "gitConfigUser="
)
if "G"=="gitConfigPassword" (
set "gitConfigPassword=H"
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
if "G"=="gitConfigURL" (
set "gitConfigURL=H"
if "!gitConfigURL!"=="" set "gitConfigURL="
)
)
rem Removing quotes from the config values
set "gitConfigUser=!gitConfigUser:"=!"
set "gitConfigPassword=!gitConfigPassword:"=!"
set "gitConfigURL=!gitConfigURL:"=!"
 
rem Check if the string is a space character and set it to an empty variable; space is always appended >:-( though git should deal with these strings correctly nevertheless
if "^"==^" " set "gitConfigUser="
if "^"==^" " set "gitConfigPassword="
if "^"==^" " set "gitConfigURL="
 
 
rem read current/already defined Git Config to see if theyre blank; not using --global flag!
for /F "delims=" i in ('git config user.name') do set currentGitConfigUser=i
for /F "delims=" i in ('git config user.password') do set currentGitConfigPassword=i
for /F "delims=" i in ('git config --get remote..url') do set currentGitConfigURL=i
 
if "!currentGitConfigUser!"==" " set "currentGitConfigUser="
if "!currentGitConfigPassword!"==" " set "currentGitConfigPassword="
if "!currentGitConfigURL!"==" " set "currentGitConfigURL="
 
if ==0 (
REM do nothing
goto dontSkip
) else if ==1 (
goto skipUserConfig
) else (
goto skipConfig
)
 
:dontSkip
 
REM set TAB="<TAB>"
set "TAB=   "
 
Echo Current User Name: "!currentGitConfigUser!"  Read User Name: "!gitConfigUser!"
Echo Current User PWD: "!currentGitConfigPassword!"  Read User PWD: "!gitConfigPassword!"
Echo.
Echo Pulling from Host with Name: "%gitConfigRemoteName%"
Echo Current URL under this Name: "!currentGitConfigURL!"  Read URL: "!gitConfigURL!"
 
Echo.
Echo.
 
if not "!gitConfigUser!"=="" (
if "!currentGitConfigUser!"=="" (
echo Current local Git Username is not set -> new Name: "!gitConfigUser!"
git config user.name "!gitConfigUser!"
)else (
echo Current local Git Username is already set; if the overwriteGitConfigData flag is true the current Username: "!currentGitConfigUser!" will be set to "!gitConfigUser!"
if "!overwriteGitConfigData!"=="true" (
git config user.name "!gitConfigUser!"&Echo Overwriting successful; Username "!currentGitConfigUser!" changed to "!gitConfigUser!"
REM git config --global --replace-all "!gitConfigUser!"
)
)
)
 
Echo.
Echo.
 
if not "!gitConfigPassword!"=="" (
if "!currentGitConfigPassword!"=="" (
echo Current local Git Password is not set -> new Password: "!gitConfigPassword!"
git config user.password "!gitConfigPassword!"
)else (
 
echo Current local Git Password is already set; if the overwriteGitConfigData flag is true the current Password: "!currentGitConfigPassword!" will be set to "!gitConfigPassword!"
if "!overwriteGitConfigData!"=="true" (
git config user.password "!gitConfigPassword!"&Echo Overwriting successful; Password "!currentGitConfigPassword!" changed to "!gitConfigPassword!"
REM git config --replace-all --global user.password "!gitConfigPassword!"
)
)
)
 
:skipUserConfig
Echo.
Echo.
 
if not "!gitConfigURL!"=="" (
echo get displayed
echo !gitConfigURL!
echo "!currentGitConfigURL!"
 
if "!currentGitConfigURL!"=="" (
echo Current local Git fetch URL is not set -> new URL: "!gitConfigURL!"
git remote add  "!gitConfigURL!"
) else (
echo Current local Git fetch URL is already set; if the overwriteGitConfigData flag is true the current URL: "!currentGitConfigURL!" will be set to "!gitConfigURL!"
if "!overwriteGitConfigData!"=="true" (
git remote add !gitConfigRemoteName! "!gitConfigURL!" & Echo Overwriting successful; URL "!currentGitConfigURL!" changed to "!gitConfigURL!"
)
)
) else (
Echo Either Config.txt url was empty
)
:skipConfig
 
git pull %gitConfigRemoteName% %branchToPull%
 
 
if not %errorlevel% == 0(
Echo.
Echo Git ran into an Error when pulling.
Echo Have you committed your local changes?
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
Echo Resetting uncommited local changes ...
 
git reset --hard
git pull %gitConfigRemoteName% %branchToPull%
 
) else (
goto invalidNumberLength
)
) else (
:invalidNumberLength
Echo Aborting...
Echo.
Echo Press any key to exit.
Pause > nul
Exit
)
)
endlocal
@echo off
setlocal EnableDelayedExpansion
 
set "overwriteGitConfigData=true"
 
set "skipConfig=0"
REM 0==dont skip; 1==skip userConfig; >1==skip
 
 
where git >nul 2>nul && (
echo Git is installed.
) || (
start cmd.exe /k "color 4f & title Error & Echo. & Echo. & Echo Git is not properly installed! & Echo The installation will be canceled. If this is a mistake, remove the initial check from this batch file. & Echo Press any key to close this dialog & Pause > nul & Exit"
Echo Git environment variable wasnt found; Pulling will be canceled
Echo.
Echo Press any key to exit.
Pause > nul
Exit;
)
 
 
for /f i in ('git rev-parse --is-inside-work-tree 2^>^&1') do (
if /I "i"=="true" (
goto success
) else (
echo Current directory isn't a Git repository!
echo By continuing, Git will be set up here.
set /P "input=Press 'y' to continue and configure Git here; 'n' to abort this action: "
 
REM Check if the length of the input at 4th index is empty (3 chars or less) and if it starts with 'y'
set "choice=!input:~0,1!"
if /I "!choice!"=="y" (
if "!input:~3!"=="" (
echo Continuing...
echo Setting Git up in the current directory...
git init
) else (
goto wrongDirError
)
) else (
:wrongDirError
echo Aborting...
echo.
echo Press any key to exit.
pause > nul
exit
)
)
)
 
:success
Echo.
 
if ""=="" (
echo No branch name input provided. Pulling the 'main' branch.
set "branchToPull=main"
)
 
 
set "gitConfigRemoteName=%~2"
 
if "^"==^"" (
echo No input remote repo name provided. Setting to default 'origin'.
set "gitConfigRemoteName=origin"
)
rem Read configurations from the config.txt file
for /F "tokens=1,* delims== " G in (config.txt) do (
if "G"=="gitConfigUser" (
set "gitConfigUser=H"
if "!gitConfigUser!"=="" set "gitConfigUser="
)
if "G"=="gitConfigPassword" (
set "gitConfigPassword=H"
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
if "G"=="gitConfigURL" (
set "gitConfigURL=H"
if "!gitConfigURL!"=="" set "gitConfigURL="
)
)
rem Removing quotes from the config values
set "gitConfigUser=!gitConfigUser:"=!"
set "gitConfigPassword=!gitConfigPassword:"=!"
set "gitConfigURL=!gitConfigURL:"=!"
 
rem Check if the string is a space character and set it to an empty variable; space is always appended >:-( though git should deal with these strings correctly nevertheless
if "^"==^" " set "gitConfigUser="
if "^"==^" " set "gitConfigPassword="
if "^"==^" " set "gitConfigURL="
 
 
rem read current/already defined Git Config to see if theyre blank; not using --global flag!
for /F "delims=" i in ('git config user.name') do set currentGitConfigUser=i
for /F "delims=" i in ('git config user.password') do set currentGitConfigPassword=i
for /F "delims=" i in ('git config --get remote..url') do set currentGitConfigURL=i
 
if "!currentGitConfigUser!"==" " set "currentGitConfigUser="
if "!currentGitConfigPassword!"==" " set "currentGitConfigPassword="
if "!currentGitConfigURL!"==" " set "currentGitConfigURL="
 
if ==0 (
REM do nothing
goto dontSkip
) else if ==1 (
goto skipUserConfig
) else (
goto skipConfig
)
 
:dontSkip
 
REM set TAB="<TAB>"
set "TAB=   "
 
Echo Current User Name: "!currentGitConfigUser!"  Read User Name: "!gitConfigUser!"
Echo Current User PWD: "!currentGitConfigPassword!"  Read User PWD: "!gitConfigPassword!"
Echo.
Echo Pulling from Host with Name: "%gitConfigRemoteName%"
Echo Current URL under this Name: "!currentGitConfigURL!"  Read URL: "!gitConfigURL!"
 
Echo.
Echo.
 
if not "!gitConfigUser!"=="" (
if "!currentGitConfigUser!"=="" (
echo Current local Git Username is not set -> new Name: "!gitConfigUser!"
git config user.name "!gitConfigUser!"
)else (
echo Current local Git Username is already set; if the overwriteGitConfigData flag is true the current Username: "!currentGitConfigUser!" will be set to "!gitConfigUser!"
if "!overwriteGitConfigData!"=="true" (
git config user.name "!gitConfigUser!"&Echo Overwriting successful; Username "!currentGitConfigUser!" changed to "!gitConfigUser!"
REM git config --global --replace-all "!gitConfigUser!"
)
)
)
 
Echo.
Echo.
 
if not "!gitConfigPassword!"=="" (
if "!currentGitConfigPassword!"=="" (
echo Current local Git Password is not set -> new Password: "!gitConfigPassword!"
git config user.password "!gitConfigPassword!"
)else (
 
echo Current local Git Password is already set; if the overwriteGitConfigData flag is true the current Password: "!currentGitConfigPassword!" will be set to "!gitConfigPassword!"
if "!overwriteGitConfigData!"=="true" (
git config user.password "!gitConfigPassword!"&Echo Overwriting successful; Password "!currentGitConfigPassword!" changed to "!gitConfigPassword!"
REM git config --replace-all --global user.password "!gitConfigPassword!"
)
)
)
 
:skipUserConfig
Echo.
Echo.
 
if not "!gitConfigURL!"=="" (
echo get displayed
echo !gitConfigURL!
echo "!currentGitConfigURL!"
 
if "!currentGitConfigURL!"=="" (
echo Current local Git fetch URL is not set -> new URL: "!gitConfigURL!"
git remote add  "!gitConfigURL!"
) else (
echo Current local Git fetch URL is already set; if the overwriteGitConfigData flag is true the current URL: "!currentGitConfigURL!" will be set to "!gitConfigURL!"
if "!overwriteGitConfigData!"=="true" (
git remote add !gitConfigRemoteName! "!gitConfigURL!" & Echo Overwriting successful; URL "!currentGitConfigURL!" changed to "!gitConfigURL!"
)
)
) else (
Echo Either Config.txt url was empty
)
:skipConfig
 
git pull %gitConfigRemoteName% %branchToPull%
 
 
if not %errorlevel% == 0(
Echo.
Echo Git ran into an Error when pulling.
Echo Have you committed your local changes?
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
Echo Resetting uncommited local changes ...
 
git reset --hard
git pull %gitConfigRemoteName% %branchToPull%
 
) else (
goto invalidNumberLength
)
) else (
:invalidNumberLength
Echo Aborting...
Echo.
Echo Press any key to exit.
Pause > nul
Exit
)
)
endlocal
@echo off
setlocal EnableDelayedExpansion
 
set "overwriteGitConfigData=true"
 
set "skipConfig=0"
REM 0==dont skip; 1==skip userConfig; >1==skip
 
 
where git >nul 2>nul && (
echo Git is installed.
) || (
start cmd.exe /k "color 4f & title Error & Echo. & Echo. & Echo Git is not properly installed! & Echo The installation will be canceled. If this is a mistake, remove the initial check from this batch file. & Echo Press any key to close this dialog & Pause > nul & Exit"
Echo Git environment variable wasnt found; Pulling will be canceled
Echo.
Echo Press any key to exit.
Pause > nul
Exit;
)
 
 
for /f i in ('git rev-parse --is-inside-work-tree 2^>^&1') do (
if /I "i"=="true" (
goto success
) else (
echo Current directory isn't a Git repository!
echo By continuing, Git will be set up here.
set /P "input=Press 'y' to continue and configure Git here; 'n' to abort this action: "
 
REM Check if the length of the input at 4th index is empty (3 chars or less) and if it starts with 'y'
set "choice=!input:~0,1!"
if /I "!choice!"=="y" (
if "!input:~3!"=="" (
echo Continuing...
echo Setting Git up in the current directory...
git init
) else (
goto wrongDirError
)
) else (
:wrongDirError
echo Aborting...
echo.
echo Press any key to exit.
pause > nul
exit
)
)
)
 
:success
Echo.
 
if ""=="" (
echo No branch name input provided. Pulling the 'main' branch.
set "branchToPull=main"
)
 
 
set "gitConfigRemoteName=%~2"
 
if "^"==^"" (
echo No input remote repo name provided. Setting to default 'origin'.
set "gitConfigRemoteName=origin"
)
rem Read configurations from the config.txt file
for /F "tokens=1,* delims== " G in (config.txt) do (
if "G"=="gitConfigUser" (
set "gitConfigUser=H"
if "!gitConfigUser!"=="" set "gitConfigUser="
)
if "G"=="gitConfigPassword" (
set "gitConfigPassword=H"
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
if "G"=="gitConfigURL" (
set "gitConfigURL=H"
if "!gitConfigURL!"=="" set "gitConfigURL="
)
)
rem Removing quotes from the config values
set "gitConfigUser=!gitConfigUser:"=!"
set "gitConfigPassword=!gitConfigPassword:"=!"
set "gitConfigURL=!gitConfigURL:"=!"
 
rem Check if the string is a space character and set it to an empty variable; space is always appended >:-( though git should deal with these strings correctly nevertheless
if "^"==^" " set "gitConfigUser="
if "^"==^" " set "gitConfigPassword="
if "^"==^" " set "gitConfigURL="
 
 
rem read current/already defined Git Config to see if theyre blank; not using --global flag!
for /F "delims=" i in ('git config user.name') do set currentGitConfigUser=i
for /F "delims=" i in ('git config user.password') do set currentGitConfigPassword=i
for /F "delims=" i in ('git config --get remote..url') do set currentGitConfigURL=i
 
if "!currentGitConfigUser!"==" " set "currentGitConfigUser="
if "!currentGitConfigPassword!"==" " set "currentGitConfigPassword="
if "!currentGitConfigURL!"==" " set "currentGitConfigURL="
 
if ==0 (
REM do nothing
goto dontSkip
) else if ==1 (
goto skipUserConfig
) else (
goto skipConfig
)
 
:dontSkip
 
REM set TAB="<TAB>"
set "TAB=   "
 
Echo Current User Name: "!currentGitConfigUser!"  Read User Name: "!gitConfigUser!"
Echo Current User PWD: "!currentGitConfigPassword!"  Read User PWD: "!gitConfigPassword!"
Echo.
Echo Pulling from Host with Name: "%gitConfigRemoteName%"
Echo Current URL under this Name: "!currentGitConfigURL!"  Read URL: "!gitConfigURL!"
 
Echo.
Echo.
 
if not "!gitConfigUser!"=="" (
if "!currentGitConfigUser!"=="" (
echo Current local Git Username is not set -> new Name: "!gitConfigUser!"
git config user.name "!gitConfigUser!"
)else (
echo Current local Git Username is already set; if the overwriteGitConfigData flag is true the current Username: "!currentGitConfigUser!" will be set to "!gitConfigUser!"
if "!overwriteGitConfigData!"=="true" (
git config user.name "!gitConfigUser!"&Echo Overwriting successful; Username "!currentGitConfigUser!" changed to "!gitConfigUser!"
REM git config --global --replace-all "!gitConfigUser!"
)
)
)
 
Echo.
Echo.
 
if not "!gitConfigPassword!"=="" (
if "!currentGitConfigPassword!"=="" (
echo Current local Git Password is not set -> new Password: "!gitConfigPassword!"
git config user.password "!gitConfigPassword!"
)else (
 
echo Current local Git Password is already set; if the overwriteGitConfigData flag is true the current Password: "!currentGitConfigPassword!" will be set to "!gitConfigPassword!"
if "!overwriteGitConfigData!"=="true" (
git config user.password "!gitConfigPassword!"&Echo Overwriting successful; Password "!currentGitConfigPassword!" changed to "!gitConfigPassword!"
REM git config --replace-all --global user.password "!gitConfigPassword!"
)
)
)
 
:skipUserConfig
Echo.
Echo.
 
if not "!gitConfigURL!"=="" (
echo get displayed
echo !gitConfigURL!
echo "!currentGitConfigURL!"
 
if "!currentGitConfigURL!"=="" (
echo Current local Git fetch URL is not set -> new URL: "!gitConfigURL!"
git remote add  "!gitConfigURL!"
) else (
echo Current local Git fetch URL is already set; if the overwriteGitConfigData flag is true the current URL: "!currentGitConfigURL!" will be set to "!gitConfigURL!"
if "!overwriteGitConfigData!"=="true" (
git remote add !gitConfigRemoteName! "!gitConfigURL!" & Echo Overwriting successful; URL "!currentGitConfigURL!" changed to "!gitConfigURL!"
)
)
) else (
Echo Either Config.txt url was empty
)
:skipConfig
 
git pull %gitConfigRemoteName% %branchToPull%
 
 
if not %errorlevel% == 0(
Echo.
Echo Git ran into an Error when pulling.
Echo Have you committed your local changes?
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
Echo Resetting uncommited local changes ...
 
git reset --hard
git pull %gitConfigRemoteName% %branchToPull%
 
) else (
goto invalidNumberLength
)
) else (
:invalidNumberLength
Echo Aborting...
Echo.
Echo Press any key to exit.
Pause > nul
Exit
)
)
endlocal
@echo off
setlocal EnableDelayedExpansion
 
set "overwriteGitConfigData=true"
 
set "skipConfig=0"
REM 0==dont skip; 1==skip userConfig; >1==skip
 
 
where git >nul 2>nul && (
echo Git is installed.
) || (
start cmd.exe /k "color 4f & title Error & Echo. & Echo. & Echo Git is not properly installed! & Echo The installation will be canceled. If this is a mistake, remove the initial check from this batch file. & Echo Press any key to close this dialog & Pause > nul & Exit"
Echo Git environment variable wasnt found; Pulling will be canceled
Echo.
Echo Press any key to exit.
Pause > nul
Exit;
)
 
 
for /f i in ('git rev-parse --is-inside-work-tree 2^>^&1') do (
if /I "i"=="true" (
goto success
) else (
echo Current directory isn't a Git repository!
echo By continuing, Git will be set up here.
set /P "input=Press 'y' to continue and configure Git here; 'n' to abort this action: "
 
REM Check if the length of the input at 4th index is empty (3 chars or less) and if it starts with 'y'
set "choice=!input:~0,1!"
if /I "!choice!"=="y" (
if "!input:~3!"=="" (
echo Continuing...
echo Setting Git up in the current directory...
git init
) else (
goto wrongDirError
)
) else (
:wrongDirError
echo Aborting...
echo.
echo Press any key to exit.
pause > nul
exit
)
)
)
 
:success
Echo.
 
if ""=="" (
echo No branch name input provided. Pulling the 'main' branch.
set "branchToPull=main"
)
 
 
set "gitConfigRemoteName=%~2"
 
if "^"==^"" (
echo No input remote repo name provided. Setting to default 'origin'.
set "gitConfigRemoteName=origin"
)
rem Read configurations from the config.txt file
for /F "tokens=1,* delims== " G in (config.txt) do (
if "G"=="gitConfigUser" (
set "gitConfigUser=H"
if "!gitConfigUser!"=="" set "gitConfigUser="
)
if "G"=="gitConfigPassword" (
set "gitConfigPassword=H"
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
if "G"=="gitConfigURL" (
set "gitConfigURL=H"
if "!gitConfigURL!"=="" set "gitConfigURL="
)
)
rem Removing quotes from the config values
set "gitConfigUser=!gitConfigUser:"=!"
set "gitConfigPassword=!gitConfigPassword:"=!"
set "gitConfigURL=!gitConfigURL:"=!"
 
rem Check if the string is a space character and set it to an empty variable; space is always appended >:-( though git should deal with these strings correctly nevertheless
if "^"==^" " set "gitConfigUser="
if "^"==^" " set "gitConfigPassword="
if "^"==^" " set "gitConfigURL="
 
 
rem read current/already defined Git Config to see if theyre blank; not using --global flag!
for /F "delims=" i in ('git config user.name') do set currentGitConfigUser=i
for /F "delims=" i in ('git config user.password') do set currentGitConfigPassword=i
for /F "delims=" i in ('git config --get remote..url') do set currentGitConfigURL=i
 
if "!currentGitConfigUser!"==" " set "currentGitConfigUser="
if "!currentGitConfigPassword!"==" " set "currentGitConfigPassword="
if "!currentGitConfigURL!"==" " set "currentGitConfigURL="
 
if ==0 (
REM do nothing
goto dontSkip
) else if ==1 (
goto skipUserConfig
) else (
goto skipConfig
)
 
:dontSkip
 
REM set TAB="<TAB>"
set "TAB=   "
 
Echo Current User Name: "!currentGitConfigUser!"  Read User Name: "!gitConfigUser!"
Echo Current User PWD: "!currentGitConfigPassword!"  Read User PWD: "!gitConfigPassword!"
Echo.
Echo Pulling from Host with Name: "%gitConfigRemoteName%"
Echo Current URL under this Name: "!currentGitConfigURL!"  Read URL: "!gitConfigURL!"
 
Echo.
Echo.
 
if not "!gitConfigUser!"=="" (
if "!currentGitConfigUser!"=="" (
echo Current local Git Username is not set -> new Name: "!gitConfigUser!"
git config user.name "!gitConfigUser!"
)else (
echo Current local Git Username is already set; if the overwriteGitConfigData flag is true the current Username: "!currentGitConfigUser!" will be set to "!gitConfigUser!"
if "!overwriteGitConfigData!"=="true" (
git config user.name "!gitConfigUser!"&Echo Overwriting successful; Username "!currentGitConfigUser!" changed to "!gitConfigUser!"
REM git config --global --replace-all "!gitConfigUser!"
)
)
)
 
Echo.
Echo.
 
if not "!gitConfigPassword!"=="" (
if "!currentGitConfigPassword!"=="" (
echo Current local Git Password is not set -> new Password: "!gitConfigPassword!"
git config user.password "!gitConfigPassword!"
)else (
 
echo Current local Git Password is already set; if the overwriteGitConfigData flag is true the current Password: "!currentGitConfigPassword!" will be set to "!gitConfigPassword!"
if "!overwriteGitConfigData!"=="true" (
git config user.password "!gitConfigPassword!"&Echo Overwriting successful; Password "!currentGitConfigPassword!" changed to "!gitConfigPassword!"
REM git config --replace-all --global user.password "!gitConfigPassword!"
)
)
)
 
:skipUserConfig
Echo.
Echo.
 
if not "!gitConfigURL!"=="" (
echo get displayed
echo !gitConfigURL!
echo "!currentGitConfigURL!"
 
if "!currentGitConfigURL!"=="" (
echo Current local Git fetch URL is not set -> new URL: "!gitConfigURL!"
git remote add  "!gitConfigURL!"
) else (
echo Current local Git fetch URL is already set; if the overwriteGitConfigData flag is true the current URL: "!currentGitConfigURL!" will be set to "!gitConfigURL!"
if "!overwriteGitConfigData!"=="true" (
git remote add !gitConfigRemoteName! "!gitConfigURL!" & Echo Overwriting successful; URL "!currentGitConfigURL!" changed to "!gitConfigURL!"
)
)
) else (
Echo Either Config.txt url was empty
)
:skipConfig
 
git pull %gitConfigRemoteName% %branchToPull%
 
 
if not %errorlevel% == 0(
Echo.
Echo Git ran into an Error when pulling.
Echo Have you committed your local changes?
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
Echo Resetting uncommited local changes ...
 
git reset --hard
git pull %gitConfigRemoteName% %branchToPull%
 
) else (
goto invalidNumberLength
)
) else (
:invalidNumberLength
Echo Aborting...
Echo.
Echo Press any key to exit.
Pause > nul
Exit
)
)
endlocal
@echo off
setlocal EnableDelayedExpansion
 
set "overwriteGitConfigData=true"
 
set "skipConfig=0"
REM 0==dont skip; 1==skip userConfig; >1==skip
 
 
where git >nul 2>nul && (
echo Git is installed.
) || (
start cmd.exe /k "color 4f & title Error & Echo. & Echo. & Echo Git is not properly installed! & Echo The installation will be canceled. If this is a mistake, remove the initial check from this batch file. & Echo Press any key to close this dialog & Pause > nul & Exit"
Echo Git environment variable wasnt found; Pulling will be canceled
Echo.
Echo Press any key to exit.
Pause > nul
Exit;
)
 
 
for /f i in ('git rev-parse --is-inside-work-tree 2^>^&1') do (
if /I "i"=="true" (
goto success
) else (
echo Current directory isn't a Git repository!
echo By continuing, Git will be set up here.
set /P "input=Press 'y' to continue and configure Git here; 'n' to abort this action: "
 
REM Check if the length of the input at 4th index is empty (3 chars or less) and if it starts with 'y'
set "choice=!input:~0,1!"
if /I "!choice!"=="y" (
if "!input:~3!"=="" (
echo Continuing...
echo Setting Git up in the current directory...
git init
) else (
goto wrongDirError
)
) else (
:wrongDirError
echo Aborting...
echo.
echo Press any key to exit.
pause > nul
exit
)
)
)
 
:success
Echo.
 
if ""=="" (
echo No branch name input provided. Pulling the 'main' branch.
set "branchToPull=main"
)
 
 
set "gitConfigRemoteName=%~2"
 
if "^"==^"" (
echo No input remote repo name provided. Setting to default 'origin'.
set "gitConfigRemoteName=origin"
)
rem Read configurations from the config.txt file
for /F "tokens=1,* delims== " G in (config.txt) do (
if "G"=="gitConfigUser" (
set "gitConfigUser=H"
if "!gitConfigUser!"=="" set "gitConfigUser="
)
if "G"=="gitConfigPassword" (
set "gitConfigPassword=H"
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
if "G"=="gitConfigURL" (
set "gitConfigURL=H"
if "!gitConfigURL!"=="" set "gitConfigURL="
)
)
rem Removing quotes from the config values
set "gitConfigUser=!gitConfigUser:"=!"
set "gitConfigPassword=!gitConfigPassword:"=!"
set "gitConfigURL=!gitConfigURL:"=!"
 
rem Check if the string is a space character and set it to an empty variable; space is always appended >:-( though git should deal with these strings correctly nevertheless
if "^"==^" " set "gitConfigUser="
if "^"==^" " set "gitConfigPassword="
if "^"==^" " set "gitConfigURL="
 
 
rem read current/already defined Git Config to see if theyre blank; not using --global flag!
for /F "delims=" i in ('git config user.name') do set currentGitConfigUser=i
for /F "delims=" i in ('git config user.password') do set currentGitConfigPassword=i
for /F "delims=" i in ('git config --get remote..url') do set currentGitConfigURL=i
 
if "!currentGitConfigUser!"==" " set "currentGitConfigUser="
if "!currentGitConfigPassword!"==" " set "currentGitConfigPassword="
if "!currentGitConfigURL!"==" " set "currentGitConfigURL="
 
if ==0 (
REM do nothing
goto dontSkip
) else if ==1 (
goto skipUserConfig
) else (
goto skipConfig
)
 
:dontSkip
 
REM set TAB="<TAB>"
set "TAB=   "
 
Echo Current User Name: "!currentGitConfigUser!"  Read User Name: "!gitConfigUser!"
Echo Current User PWD: "!currentGitConfigPassword!"  Read User PWD: "!gitConfigPassword!"
Echo.
Echo Pulling from Host with Name: "%gitConfigRemoteName%"
Echo Current URL under this Name: "!currentGitConfigURL!"  Read URL: "!gitConfigURL!"
 
Echo.
Echo.
 
if not "!gitConfigUser!"=="" (
if "!currentGitConfigUser!"=="" (
echo Current local Git Username is not set -> new Name: "!gitConfigUser!"
git config user.name "!gitConfigUser!"
)else (
echo Current local Git Username is already set; if the overwriteGitConfigData flag is true the current Username: "!currentGitConfigUser!" will be set to "!gitConfigUser!"
if "!overwriteGitConfigData!"=="true" (
git config user.name "!gitConfigUser!"&Echo Overwriting successful; Username "!currentGitConfigUser!" changed to "!gitConfigUser!"
REM git config --global --replace-all "!gitConfigUser!"
)
)
)
 
Echo.
Echo.
 
if not "!gitConfigPassword!"=="" (
if "!currentGitConfigPassword!"=="" (
echo Current local Git Password is not set -> new Password: "!gitConfigPassword!"
git config user.password "!gitConfigPassword!"
)else (
 
echo Current local Git Password is already set; if the overwriteGitConfigData flag is true the current Password: "!currentGitConfigPassword!" will be set to "!gitConfigPassword!"
if "!overwriteGitConfigData!"=="true" (
git config user.password "!gitConfigPassword!"&Echo Overwriting successful; Password "!currentGitConfigPassword!" changed to "!gitConfigPassword!"
REM git config --replace-all --global user.password "!gitConfigPassword!"
)
)
)
 
:skipUserConfig
Echo.
Echo.
 
if not "!gitConfigURL!"=="" (
echo get displayed
echo !gitConfigURL!
echo "!currentGitConfigURL!"
 
if "!currentGitConfigURL!"=="" (
echo Current local Git fetch URL is not set -> new URL: "!gitConfigURL!"
git remote add  "!gitConfigURL!"
) else (
echo Current local Git fetch URL is already set; if the overwriteGitConfigData flag is true the current URL: "!currentGitConfigURL!" will be set to "!gitConfigURL!"
if "!overwriteGitConfigData!"=="true" (
git remote add !gitConfigRemoteName! "!gitConfigURL!" & Echo Overwriting successful; URL "!currentGitConfigURL!" changed to "!gitConfigURL!"
)
)
) else (
Echo Either Config.txt url was empty
)
:skipConfig
 
git pull %gitConfigRemoteName% %branchToPull%
 
 
if not %errorlevel% == 0(
Echo.
Echo Git ran into an Error when pulling.
Echo Have you committed your local changes?
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
Echo Resetting uncommited local changes ...
 
git reset --hard
git pull %gitConfigRemoteName% %branchToPull%
 
) else (
goto invalidNumberLength
)
) else (
:invalidNumberLength
Echo Aborting...
Echo.
Echo Press any key to exit.
Pause > nul
Exit
)
)
endlocal
@echo off
setlocal EnableDelayedExpansion
 
set "overwriteGitConfigData=true"
 
set "skipConfig=0"
REM 0==dont skip; 1==skip userConfig; >1==skip
 
 
where git >nul 2>nul && (
echo Git is installed.
) || (
start cmd.exe /k "color 4f & title Error & Echo. & Echo. & Echo Git is not properly installed! & Echo The installation will be canceled. If this is a mistake, remove the initial check from this batch file. & Echo Press any key to close this dialog & Pause > nul & Exit"
Echo Git environment variable wasnt found; Pulling will be canceled
Echo.
Echo Press any key to exit.
Pause > nul
Exit;
)
 
 
for /f i in ('git rev-parse --is-inside-work-tree 2^>^&1') do (
if /I "i"=="true" (
goto success
) else (
echo Current directory isn't a Git repository!
echo By continuing, Git will be set up here.
set /P "input=Press 'y' to continue and configure Git here; 'n' to abort this action: "
 
REM Check if the length of the input at 4th index is empty (3 chars or less) and if it starts with 'y'
set "choice=!input:~0,1!"
if /I "!choice!"=="y" (
if "!input:~3!"=="" (
echo Continuing...
echo Setting Git up in the current directory...
git init
) else (
goto wrongDirError
)
) else (
:wrongDirError
echo Aborting...
echo.
echo Press any key to exit.
pause > nul
exit
)
)
)
 
:success
Echo.
 
if ""=="" (
echo No branch name input provided. Pulling the 'main' branch.
set "branchToPull=main"
)
 
 
set "gitConfigRemoteName=%~2"
 
if "^"==^"" (
echo No input remote repo name provided. Setting to default 'origin'.
set "gitConfigRemoteName=origin"
)
rem Read configurations from the config.txt file
for /F "tokens=1,* delims== " G in (config.txt) do (
if "G"=="gitConfigUser" (
set "gitConfigUser=H"
if "!gitConfigUser!"=="" set "gitConfigUser="
)
if "G"=="gitConfigPassword" (
set "gitConfigPassword=H"
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
if "G"=="gitConfigURL" (
set "gitConfigURL=H"
if "!gitConfigURL!"=="" set "gitConfigURL="
)
)
rem Removing quotes from the config values
set "gitConfigUser=!gitConfigUser:"=!"
set "gitConfigPassword=!gitConfigPassword:"=!"
set "gitConfigURL=!gitConfigURL:"=!"
 
rem Check if the string is a space character and set it to an empty variable; space is always appended >:-( though git should deal with these strings correctly nevertheless
if "^"==^" " set "gitConfigUser="
if "^"==^" " set "gitConfigPassword="
if "^"==^" " set "gitConfigURL="
 
 
rem read current/already defined Git Config to see if theyre blank; not using --global flag!
for /F "delims=" i in ('git config user.name') do set currentGitConfigUser=i
for /F "delims=" i in ('git config user.password') do set currentGitConfigPassword=i
for /F "delims=" i in ('git config --get remote..url') do set currentGitConfigURL=i
 
if "!currentGitConfigUser!"==" " set "currentGitConfigUser="
if "!currentGitConfigPassword!"==" " set "currentGitConfigPassword="
if "!currentGitConfigURL!"==" " set "currentGitConfigURL="
 
if ==0 (
REM do nothing
goto dontSkip
) else if ==1 (
goto skipUserConfig
) else (
goto skipConfig
)
 
:dontSkip
 
REM set TAB="<TAB>"
set "TAB=   "
 
Echo Current User Name: "!currentGitConfigUser!"  Read User Name: "!gitConfigUser!"
Echo Current User PWD: "!currentGitConfigPassword!"  Read User PWD: "!gitConfigPassword!"
Echo.
Echo Pulling from Host with Name: "%gitConfigRemoteName%"
Echo Current URL under this Name: "!currentGitConfigURL!"  Read URL: "!gitConfigURL!"
 
Echo.
Echo.
 
if not "!gitConfigUser!"=="" (
if "!currentGitConfigUser!"=="" (
echo Current local Git Username is not set -> new Name: "!gitConfigUser!"
git config user.name "!gitConfigUser!"
)else (
echo Current local Git Username is already set; if the overwriteGitConfigData flag is true the current Username: "!currentGitConfigUser!" will be set to "!gitConfigUser!"
if "!overwriteGitConfigData!"=="true" (
git config user.name "!gitConfigUser!"&Echo Overwriting successful; Username "!currentGitConfigUser!" changed to "!gitConfigUser!"
REM git config --global --replace-all "!gitConfigUser!"
)
)
)
 
Echo.
Echo.
 
if not "!gitConfigPassword!"=="" (
if "!currentGitConfigPassword!"=="" (
echo Current local Git Password is not set -> new Password: "!gitConfigPassword!"
git config user.password "!gitConfigPassword!"
)else (
 
echo Current local Git Password is already set; if the overwriteGitConfigData flag is true the current Password: "!currentGitConfigPassword!" will be set to "!gitConfigPassword!"
if "!overwriteGitConfigData!"=="true" (
git config user.password "!gitConfigPassword!"&Echo Overwriting successful; Password "!currentGitConfigPassword!" changed to "!gitConfigPassword!"
REM git config --replace-all --global user.password "!gitConfigPassword!"
)
)
)
 
:skipUserConfig
Echo.
Echo.
 
if not "!gitConfigURL!"=="" (
echo get displayed
echo !gitConfigURL!
echo "!currentGitConfigURL!"
 
if "!currentGitConfigURL!"=="" (
echo Current local Git fetch URL is not set -> new URL: "!gitConfigURL!"
git remote add  "!gitConfigURL!"
) else (
echo Current local Git fetch URL is already set; if the overwriteGitConfigData flag is true the current URL: "!currentGitConfigURL!" will be set to "!gitConfigURL!"
if "!overwriteGitConfigData!"=="true" (
git remote add !gitConfigRemoteName! "!gitConfigURL!" & Echo Overwriting successful; URL "!currentGitConfigURL!" changed to "!gitConfigURL!"
)
)
) else (
Echo Either Config.txt url was empty
)
:skipConfig
 
git pull %gitConfigRemoteName% %branchToPull%
 
 
if not %errorlevel% == 0(
Echo.
Echo Git ran into an Error when pulling.
Echo Have you committed your local changes?
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
Echo Resetting uncommited local changes ...
 
git reset --hard
git pull %gitConfigRemoteName% %branchToPull%
 
) else (
goto invalidNumberLength
)
) else (
:invalidNumberLength
Echo Aborting...
Echo.
Echo Press any key to exit.
Pause > nul
Exit
)
)
endlocal
@echo off
setlocal EnableDelayedExpansion
 
set "overwriteGitConfigData=true"
 
set "skipConfig=0"
REM 0==dont skip; 1==skip userConfig; >1==skip
 
 
where git >nul 2>nul && (
echo Git is installed.
) || (
start cmd.exe /k "color 4f & title Error & Echo. & Echo. & Echo Git is not properly installed! & Echo The installation will be canceled. If this is a mistake, remove the initial check from this batch file. & Echo Press any key to close this dialog & Pause > nul & Exit"
Echo Git environment variable wasnt found; Pulling will be canceled
Echo.
Echo Press any key to exit.
Pause > nul
Exit;
)
 
 
for /f i in ('git rev-parse --is-inside-work-tree 2^>^&1') do (
if /I "i"=="true" (
goto success
) else (
echo Current directory isn't a Git repository!
echo By continuing, Git will be set up here.
set /P "input=Press 'y' to continue and configure Git here; 'n' to abort this action: "
 
REM Check if the length of the input at 4th index is empty (3 chars or less) and if it starts with 'y'
set "choice=!input:~0,1!"
if /I "!choice!"=="y" (
if "!input:~3!"=="" (
echo Continuing...
echo Setting Git up in the current directory...
git init
) else (
goto wrongDirError
)
) else (
:wrongDirError
echo Aborting...
echo.
echo Press any key to exit.
pause > nul
exit
)
)
)
 
:success
Echo.
 
if ""=="" (
echo No branch name input provided. Pulling the 'main' branch.
set "branchToPull=main"
)
 
 
set "gitConfigRemoteName=%~2"
 
if "^"==^"" (
echo No input remote repo name provided. Setting to default 'origin'.
set "gitConfigRemoteName=origin"
)
rem Read configurations from the config.txt file
for /F "tokens=1,* delims== " G in (config.txt) do (
if "G"=="gitConfigUser" (
set "gitConfigUser=H"
if "!gitConfigUser!"=="" set "gitConfigUser="
)
if "G"=="gitConfigPassword" (
set "gitConfigPassword=H"
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
if "G"=="gitConfigURL" (
set "gitConfigURL=H"
if "!gitConfigURL!"=="" set "gitConfigURL="
)
)
rem Removing quotes from the config values
set "gitConfigUser=!gitConfigUser:"=!"
set "gitConfigPassword=!gitConfigPassword:"=!"
set "gitConfigURL=!gitConfigURL:"=!"
 
rem Check if the string is a space character and set it to an empty variable; space is always appended >:-( though git should deal with these strings correctly nevertheless
if "^"==^" " set "gitConfigUser="
if "^"==^" " set "gitConfigPassword="
if "^"==^" " set "gitConfigURL="
 
 
rem read current/already defined Git Config to see if theyre blank; not using --global flag!
for /F "delims=" i in ('git config user.name') do set currentGitConfigUser=i
for /F "delims=" i in ('git config user.password') do set currentGitConfigPassword=i
for /F "delims=" i in ('git config --get remote..url') do set currentGitConfigURL=i
 
if "!currentGitConfigUser!"==" " set "currentGitConfigUser="
if "!currentGitConfigPassword!"==" " set "currentGitConfigPassword="
if "!currentGitConfigURL!"==" " set "currentGitConfigURL="
 
if ==0 (
REM do nothing
goto dontSkip
) else if ==1 (
goto skipUserConfig
) else (
goto skipConfig
)
 
:dontSkip
 
REM set TAB="<TAB>"
set "TAB=   "
 
Echo Current User Name: "!currentGitConfigUser!"  Read User Name: "!gitConfigUser!"
Echo Current User PWD: "!currentGitConfigPassword!"  Read User PWD: "!gitConfigPassword!"
Echo.
Echo Pulling from Host with Name: "%gitConfigRemoteName%"
Echo Current URL under this Name: "!currentGitConfigURL!"  Read URL: "!gitConfigURL!"
 
Echo.
Echo.
 
if not "!gitConfigUser!"=="" (
if "!currentGitConfigUser!"=="" (
echo Current local Git Username is not set -> new Name: "!gitConfigUser!"
git config user.name "!gitConfigUser!"
)else (
echo Current local Git Username is already set; if the overwriteGitConfigData flag is true the current Username: "!currentGitConfigUser!" will be set to "!gitConfigUser!"
if "!overwriteGitConfigData!"=="true" (
git config user.name "!gitConfigUser!"&Echo Overwriting successful; Username "!currentGitConfigUser!" changed to "!gitConfigUser!"
REM git config --global --replace-all "!gitConfigUser!"
)
)
)
 
Echo.
Echo.
 
if not "!gitConfigPassword!"=="" (
if "!currentGitConfigPassword!"=="" (
echo Current local Git Password is not set -> new Password: "!gitConfigPassword!"
git config user.password "!gitConfigPassword!"
)else (
 
echo Current local Git Password is already set; if the overwriteGitConfigData flag is true the current Password: "!currentGitConfigPassword!" will be set to "!gitConfigPassword!"
if "!overwriteGitConfigData!"=="true" (
git config user.password "!gitConfigPassword!"&Echo Overwriting successful; Password "!currentGitConfigPassword!" changed to "!gitConfigPassword!"
REM git config --replace-all --global user.password "!gitConfigPassword!"
)
)
)
 
:skipUserConfig
Echo.
Echo.
 
if not "!gitConfigURL!"=="" (
echo get displayed
echo !gitConfigURL!
echo "!currentGitConfigURL!"
 
if "!currentGitConfigURL!"=="" (
echo Current local Git fetch URL is not set -> new URL: "!gitConfigURL!"
git remote add  "!gitConfigURL!"
) else (
echo Current local Git fetch URL is already set; if the overwriteGitConfigData flag is true the current URL: "!currentGitConfigURL!" will be set to "!gitConfigURL!"
if "!overwriteGitConfigData!"=="true" (
git remote add !gitConfigRemoteName! "!gitConfigURL!" & Echo Overwriting successful; URL "!currentGitConfigURL!" changed to "!gitConfigURL!"
)
)
) else (
Echo Either Config.txt url was empty
)
:skipConfig
 
git pull %gitConfigRemoteName% %branchToPull%
 
 
if not %errorlevel% == 0(
Echo.
Echo Git ran into an Error when pulling.
Echo Have you committed your local changes?
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
Echo Resetting uncommited local changes ...
 
git reset --hard
git pull %gitConfigRemoteName% %branchToPull%
 
) else (
goto invalidNumberLength
)
) else (
:invalidNumberLength
Echo Aborting...
Echo.
Echo Press any key to exit.
Pause > nul
Exit
)
)
endlocal
@echo off
setlocal EnableDelayedExpansion
 
set "overwriteGitConfigData=true"
 
set "skipConfig=0"
REM 0==dont skip; 1==skip userConfig; >1==skip
 
 
where git >nul 2>nul && (
echo Git is installed.
) || (
start cmd.exe /k "color 4f & title Error & Echo. & Echo. & Echo Git is not properly installed! & Echo The installation will be canceled. If this is a mistake, remove the initial check from this batch file. & Echo Press any key to close this dialog & Pause > nul & Exit"
Echo Git environment variable wasnt found; Pulling will be canceled
Echo.
Echo Press any key to exit.
Pause > nul
Exit;
)
 
 
for /f i in ('git rev-parse --is-inside-work-tree 2^>^&1') do (
if /I "i"=="true" (
goto success
) else (
echo Current directory isn't a Git repository!
echo By continuing, Git will be set up here.
set /P "input=Press 'y' to continue and configure Git here; 'n' to abort this action: "
 
REM Check if the length of the input at 4th index is empty (3 chars or less) and if it starts with 'y'
set "choice=!input:~0,1!"
if /I "!choice!"=="y" (
if "!input:~3!"=="" (
echo Continuing...
echo Setting Git up in the current directory...
git init
) else (
goto wrongDirError
)
) else (
:wrongDirError
echo Aborting...
echo.
echo Press any key to exit.
pause > nul
exit
)
)
)
 
:success
Echo.
 
if ""=="" (
echo No branch name input provided. Pulling the 'main' branch.
set "branchToPull=main"
)
 
 
set "gitConfigRemoteName=%~2"
 
if "^"==^"" (
echo No input remote repo name provided. Setting to default 'origin'.
set "gitConfigRemoteName=origin"
)
rem Read configurations from the config.txt file
for /F "tokens=1,* delims== " G in (config.txt) do (
if "G"=="gitConfigUser" (
set "gitConfigUser=H"
if "!gitConfigUser!"=="" set "gitConfigUser="
)
if "G"=="gitConfigPassword" (
set "gitConfigPassword=H"
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
if "G"=="gitConfigURL" (
set "gitConfigURL=H"
if "!gitConfigURL!"=="" set "gitConfigURL="
)
)
rem Removing quotes from the config values
set "gitConfigUser=!gitConfigUser:"=!"
set "gitConfigPassword=!gitConfigPassword:"=!"
set "gitConfigURL=!gitConfigURL:"=!"
 
rem Check if the string is a space character and set it to an empty variable; space is always appended >:-( though git should deal with these strings correctly nevertheless
if "^"==^" " set "gitConfigUser="
if "^"==^" " set "gitConfigPassword="
if "^"==^" " set "gitConfigURL="
 
 
rem read current/already defined Git Config to see if theyre blank; not using --global flag!
for /F "delims=" i in ('git config user.name') do set currentGitConfigUser=i
for /F "delims=" i in ('git config user.password') do set currentGitConfigPassword=i
for /F "delims=" i in ('git config --get remote..url') do set currentGitConfigURL=i
 
if "!currentGitConfigUser!"==" " set "currentGitConfigUser="
if "!currentGitConfigPassword!"==" " set "currentGitConfigPassword="
if "!currentGitConfigURL!"==" " set "currentGitConfigURL="
 
if ==0 (
REM do nothing
goto dontSkip
) else if ==1 (
goto skipUserConfig
) else (
goto skipConfig
)
 
:dontSkip
 
REM set TAB="<TAB>"
set "TAB=   "
 
Echo Current User Name: "!currentGitConfigUser!"  Read User Name: "!gitConfigUser!"
Echo Current User PWD: "!currentGitConfigPassword!"  Read User PWD: "!gitConfigPassword!"
Echo.
Echo Pulling from Host with Name: "%gitConfigRemoteName%"
Echo Current URL under this Name: "!currentGitConfigURL!"  Read URL: "!gitConfigURL!"
 
Echo.
Echo.
 
if not "!gitConfigUser!"=="" (
if "!currentGitConfigUser!"=="" (
echo Current local Git Username is not set -> new Name: "!gitConfigUser!"
git config user.name "!gitConfigUser!"
)else (
echo Current local Git Username is already set; if the overwriteGitConfigData flag is true the current Username: "!currentGitConfigUser!" will be set to "!gitConfigUser!"
if "!overwriteGitConfigData!"=="true" (
git config user.name "!gitConfigUser!"&Echo Overwriting successful; Username "!currentGitConfigUser!" changed to "!gitConfigUser!"
REM git config --global --replace-all "!gitConfigUser!"
)
)
)
 
Echo.
Echo.
 
if not "!gitConfigPassword!"=="" (
if "!currentGitConfigPassword!"=="" (
echo Current local Git Password is not set -> new Password: "!gitConfigPassword!"
git config user.password "!gitConfigPassword!"
)else (
 
echo Current local Git Password is already set; if the overwriteGitConfigData flag is true the current Password: "!currentGitConfigPassword!" will be set to "!gitConfigPassword!"
if "!overwriteGitConfigData!"=="true" (
git config user.password "!gitConfigPassword!"&Echo Overwriting successful; Password "!currentGitConfigPassword!" changed to "!gitConfigPassword!"
REM git config --replace-all --global user.password "!gitConfigPassword!"
)
)
)
 
:skipUserConfig
Echo.
Echo.
 
if not "!gitConfigURL!"=="" (
echo get displayed
echo !gitConfigURL!
echo "!currentGitConfigURL!"
 
if "!currentGitConfigURL!"=="" (
echo Current local Git fetch URL is not set -> new URL: "!gitConfigURL!"
git remote add  "!gitConfigURL!"
) else (
echo Current local Git fetch URL is already set; if the overwriteGitConfigData flag is true the current URL: "!currentGitConfigURL!" will be set to "!gitConfigURL!"
if "!overwriteGitConfigData!"=="true" (
git remote add !gitConfigRemoteName! "!gitConfigURL!" & Echo Overwriting successful; URL "!currentGitConfigURL!" changed to "!gitConfigURL!"
)
)
) else (
Echo Either Config.txt url was empty
)
:skipConfig
 
git pull %gitConfigRemoteName% %branchToPull%
 
 
if not %errorlevel% == 0(
Echo.
Echo Git ran into an Error when pulling.
Echo Have you committed your local changes?
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
Echo Resetting uncommited local changes ...
 
git reset --hard
git pull %gitConfigRemoteName% %branchToPull%
 
) else (
goto invalidNumberLength
)
) else (
:invalidNumberLength
Echo Aborting...
Echo.
Echo Press any key to exit.
Pause > nul
Exit
)
)
endlocal
@echo off
setlocal EnableDelayedExpansion
 
set "overwriteGitConfigData=true"
 
set "skipConfig=0"
REM 0==dont skip; 1==skip userConfig; >1==skip
 
 
where git >nul 2>nul && (
echo Git is installed.
) || (
start cmd.exe /k "color 4f & title Error & Echo. & Echo. & Echo Git is not properly installed! & Echo The installation will be canceled. If this is a mistake, remove the initial check from this batch file. & Echo Press any key to close this dialog & Pause > nul & Exit"
Echo Git environment variable wasnt found; Pulling will be canceled
Echo.
Echo Press any key to exit.
Pause > nul
Exit;
)
 
 
for /f i in ('git rev-parse --is-inside-work-tree 2^>^&1') do (
if /I "i"=="true" (
goto success
) else (
echo Current directory isn't a Git repository!
echo By continuing, Git will be set up here.
set /P "input=Press 'y' to continue and configure Git here; 'n' to abort this action: "
 
REM Check if the length of the input at 4th index is empty (3 chars or less) and if it starts with 'y'
set "choice=!input:~0,1!"
if /I "!choice!"=="y" (
if "!input:~3!"=="" (
echo Continuing...
echo Setting Git up in the current directory...
git init
) else (
goto wrongDirError
)
) else (
:wrongDirError
echo Aborting...
echo.
echo Press any key to exit.
pause > nul
exit
)
)
)
 
:success
Echo.
 
if ""=="" (
echo No branch name input provided. Pulling the 'main' branch.
set "branchToPull=main"
)
 
 
set "gitConfigRemoteName=%~2"
 
if "^"==^"" (
echo No input remote repo name provided. Setting to default 'origin'.
set "gitConfigRemoteName=origin"
)
rem Read configurations from the config.txt file
for /F "tokens=1,* delims== " G in (config.txt) do (
if "G"=="gitConfigUser" (
set "gitConfigUser=H"
if "!gitConfigUser!"=="" set "gitConfigUser="
)
if "G"=="gitConfigPassword" (
set "gitConfigPassword=H"
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
if "G"=="gitConfigURL" (
set "gitConfigURL=H"
if "!gitConfigURL!"=="" set "gitConfigURL="
)
)
rem Removing quotes from the config values
set "gitConfigUser=!gitConfigUser:"=!"
set "gitConfigPassword=!gitConfigPassword:"=!"
set "gitConfigURL=!gitConfigURL:"=!"
 
rem Check if the string is a space character and set it to an empty variable; space is always appended >:-( though git should deal with these strings correctly nevertheless
if "^"==^" " set "gitConfigUser="
if "^"==^" " set "gitConfigPassword="
if "^"==^" " set "gitConfigURL="
 
 
rem read current/already defined Git Config to see if theyre blank; not using --global flag!
for /F "delims=" i in ('git config user.name') do set currentGitConfigUser=i
for /F "delims=" i in ('git config user.password') do set currentGitConfigPassword=i
for /F "delims=" i in ('git config --get remote..url') do set currentGitConfigURL=i
 
if "!currentGitConfigUser!"==" " set "currentGitConfigUser="
if "!currentGitConfigPassword!"==" " set "currentGitConfigPassword="
if "!currentGitConfigURL!"==" " set "currentGitConfigURL="
 
if ==0 (
REM do nothing
goto dontSkip
) else if ==1 (
goto skipUserConfig
) else (
goto skipConfig
)
 
:dontSkip
 
REM set TAB="<TAB>"
set "TAB=   "
 
Echo Current User Name: "!currentGitConfigUser!"  Read User Name: "!gitConfigUser!"
Echo Current User PWD: "!currentGitConfigPassword!"  Read User PWD: "!gitConfigPassword!"
Echo.
Echo Pulling from Host with Name: "%gitConfigRemoteName%"
Echo Current URL under this Name: "!currentGitConfigURL!"  Read URL: "!gitConfigURL!"
 
Echo.
Echo.
 
if not "!gitConfigUser!"=="" (
if "!currentGitConfigUser!"=="" (
echo Current local Git Username is not set -> new Name: "!gitConfigUser!"
git config user.name "!gitConfigUser!"
)else (
echo Current local Git Username is already set; if the overwriteGitConfigData flag is true the current Username: "!currentGitConfigUser!" will be set to "!gitConfigUser!"
if "!overwriteGitConfigData!"=="true" (
git config user.name "!gitConfigUser!"&Echo Overwriting successful; Username "!currentGitConfigUser!" changed to "!gitConfigUser!"
REM git config --global --replace-all "!gitConfigUser!"
)
)
)
 
Echo.
Echo.
 
if not "!gitConfigPassword!"=="" (
if "!currentGitConfigPassword!"=="" (
echo Current local Git Password is not set -> new Password: "!gitConfigPassword!"
git config user.password "!gitConfigPassword!"
)else (
 
echo Current local Git Password is already set; if the overwriteGitConfigData flag is true the current Password: "!currentGitConfigPassword!" will be set to "!gitConfigPassword!"
if "!overwriteGitConfigData!"=="true" (
git config user.password "!gitConfigPassword!"&Echo Overwriting successful; Password "!currentGitConfigPassword!" changed to "!gitConfigPassword!"
REM git config --replace-all --global user.password "!gitConfigPassword!"
)
)
)
 
:skipUserConfig
Echo.
Echo.
 
if not "!gitConfigURL!"=="" (
echo get displayed
echo !gitConfigURL!
echo "!currentGitConfigURL!"
 
if "!currentGitConfigURL!"=="" (
echo Current local Git fetch URL is not set -> new URL: "!gitConfigURL!"
git remote add  "!gitConfigURL!"
) else (
echo Current local Git fetch URL is already set; if the overwriteGitConfigData flag is true the current URL: "!currentGitConfigURL!" will be set to "!gitConfigURL!"
if "!overwriteGitConfigData!"=="true" (
git remote add !gitConfigRemoteName! "!gitConfigURL!" & Echo Overwriting successful; URL "!currentGitConfigURL!" changed to "!gitConfigURL!"
)
)
) else (
Echo Either Config.txt url was empty
)
:skipConfig
 
git pull %gitConfigRemoteName% %branchToPull%
 
 
if not %errorlevel% == 0(
Echo.
Echo Git ran into an Error when pulling.
Echo Have you committed your local changes?
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
Echo Resetting uncommited local changes ...
 
git reset --hard
git pull %gitConfigRemoteName% %branchToPull%
 
) else (
goto invalidNumberLength
)
) else (
:invalidNumberLength
Echo Aborting...
Echo.
Echo Press any key to exit.
Pause > nul
Exit
)
)
endlocal
@echo off
setlocal EnableDelayedExpansion
 
set "overwriteGitConfigData=true"
 
set "skipConfig=0"
REM 0==dont skip; 1==skip userConfig; >1==skip
 
 
where git >nul 2>nul && (
echo Git is installed.
) || (
start cmd.exe /k "color 4f & title Error & Echo. & Echo. & Echo Git is not properly installed! & Echo The installation will be canceled. If this is a mistake, remove the initial check from this batch file. & Echo Press any key to close this dialog & Pause > nul & Exit"
Echo Git environment variable wasnt found; Pulling will be canceled
Echo.
Echo Press any key to exit.
Pause > nul
Exit;
)
 
 
for /f i in ('git rev-parse --is-inside-work-tree 2^>^&1') do (
if /I "i"=="true" (
goto success
) else (
echo Current directory isn't a Git repository!
echo By continuing, Git will be set up here.
set /P "input=Press 'y' to continue and configure Git here; 'n' to abort this action: "
 
REM Check if the length of the input at 4th index is empty (3 chars or less) and if it starts with 'y'
set "choice=!input:~0,1!"
if /I "!choice!"=="y" (
if "!input:~3!"=="" (
echo Continuing...
echo Setting Git up in the current directory...
git init
) else (
goto wrongDirError
)
) else (
:wrongDirError
echo Aborting...
echo.
echo Press any key to exit.
pause > nul
exit
)
)
)
 
:success
Echo.
 
if ""=="" (
echo No branch name input provided. Pulling the 'main' branch.
set "branchToPull=main"
)
 
 
set "gitConfigRemoteName=%~2"
 
if "^"==^"" (
echo No input remote repo name provided. Setting to default 'origin'.
set "gitConfigRemoteName=origin"
)
rem Read configurations from the config.txt file
for /F "tokens=1,* delims== " G in (config.txt) do (
if "G"=="gitConfigUser" (
set "gitConfigUser=H"
if "!gitConfigUser!"=="" set "gitConfigUser="
)
if "G"=="gitConfigPassword" (
set "gitConfigPassword=H"
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
if "G"=="gitConfigURL" (
set "gitConfigURL=H"
if "!gitConfigURL!"=="" set "gitConfigURL="
)
)
rem Removing quotes from the config values
set "gitConfigUser=!gitConfigUser:"=!"
set "gitConfigPassword=!gitConfigPassword:"=!"
set "gitConfigURL=!gitConfigURL:"=!"
 
rem Check if the string is a space character and set it to an empty variable; space is always appended >:-( though git should deal with these strings correctly nevertheless
if "^"==^" " set "gitConfigUser="
if "^"==^" " set "gitConfigPassword="
if "^"==^" " set "gitConfigURL="
 
 
rem read current/already defined Git Config to see if theyre blank; not using --global flag!
for /F "delims=" i in ('git config user.name') do set currentGitConfigUser=i
for /F "delims=" i in ('git config user.password') do set currentGitConfigPassword=i
for /F "delims=" i in ('git config --get remote..url') do set currentGitConfigURL=i
 
if "!currentGitConfigUser!"==" " set "currentGitConfigUser="
if "!currentGitConfigPassword!"==" " set "currentGitConfigPassword="
if "!currentGitConfigURL!"==" " set "currentGitConfigURL="
 
if ==0 (
REM do nothing
goto dontSkip
) else if ==1 (
goto skipUserConfig
) else (
goto skipConfig
)
 
:dontSkip
 
REM set TAB="<TAB>"
set "TAB=   "
 
Echo Current User Name: "!currentGitConfigUser!"  Read User Name: "!gitConfigUser!"
Echo Current User PWD: "!currentGitConfigPassword!"  Read User PWD: "!gitConfigPassword!"
Echo.
Echo Pulling from Host with Name: "%gitConfigRemoteName%"
Echo Current URL under this Name: "!currentGitConfigURL!"  Read URL: "!gitConfigURL!"
 
Echo.
Echo.
 
if not "!gitConfigUser!"=="" (
if "!currentGitConfigUser!"=="" (
echo Current local Git Username is not set -> new Name: "!gitConfigUser!"
git config user.name "!gitConfigUser!"
)else (
echo Current local Git Username is already set; if the overwriteGitConfigData flag is true the current Username: "!currentGitConfigUser!" will be set to "!gitConfigUser!"
if "!overwriteGitConfigData!"=="true" (
git config user.name "!gitConfigUser!"&Echo Overwriting successful; Username "!currentGitConfigUser!" changed to "!gitConfigUser!"
REM git config --global --replace-all "!gitConfigUser!"
)
)
)
 
Echo.
Echo.
 
if not "!gitConfigPassword!"=="" (
if "!currentGitConfigPassword!"=="" (
echo Current local Git Password is not set -> new Password: "!gitConfigPassword!"
git config user.password "!gitConfigPassword!"
)else (
 
echo Current local Git Password is already set; if the overwriteGitConfigData flag is true the current Password: "!currentGitConfigPassword!" will be set to "!gitConfigPassword!"
if "!overwriteGitConfigData!"=="true" (
git config user.password "!gitConfigPassword!"&Echo Overwriting successful; Password "!currentGitConfigPassword!" changed to "!gitConfigPassword!"
REM git config --replace-all --global user.password "!gitConfigPassword!"
)
)
)
 
:skipUserConfig
Echo.
Echo.
 
if not "!gitConfigURL!"=="" (
echo get displayed
echo !gitConfigURL!
echo "!currentGitConfigURL!"
 
if "!currentGitConfigURL!"=="" (
echo Current local Git fetch URL is not set -> new URL: "!gitConfigURL!"
git remote add  "!gitConfigURL!"
) else (
echo Current local Git fetch URL is already set; if the overwriteGitConfigData flag is true the current URL: "!currentGitConfigURL!" will be set to "!gitConfigURL!"
if "!overwriteGitConfigData!"=="true" (
git remote add !gitConfigRemoteName! "!gitConfigURL!" & Echo Overwriting successful; URL "!currentGitConfigURL!" changed to "!gitConfigURL!"
)
)
) else (
Echo Either Config.txt url was empty
)
:skipConfig
 
git pull %gitConfigRemoteName% %branchToPull%
 
 
if not %errorlevel% == 0(
Echo.
Echo Git ran into an Error when pulling.
Echo Have you committed your local changes?
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
Echo Resetting uncommited local changes ...
 
git reset --hard
git pull %gitConfigRemoteName% %branchToPull%
 
) else (
goto invalidNumberLength
)
) else (
:invalidNumberLength
Echo Aborting...
Echo.
Echo Press any key to exit.
Pause > nul
Exit
)
)
endlocal
@echo off
setlocal EnableDelayedExpansion
 
set "overwriteGitConfigData=true"
 
set "skipConfig=0"
REM 0==dont skip; 1==skip userConfig; >1==skip
 
 
where git >nul 2>nul && (
echo Git is installed.
) || (
start cmd.exe /k "color 4f & title Error & Echo. & Echo. & Echo Git is not properly installed! & Echo The installation will be canceled. If this is a mistake, remove the initial check from this batch file. & Echo Press any key to close this dialog & Pause > nul & Exit"
Echo Git environment variable wasnt found; Pulling will be canceled
Echo.
Echo Press any key to exit.
Pause > nul
Exit;
)
 
 
for /f i in ('git rev-parse --is-inside-work-tree 2^>^&1') do (
if /I "i"=="true" (
goto success
) else (
echo Current directory isn't a Git repository!
echo By continuing, Git will be set up here.
set /P "input=Press 'y' to continue and configure Git here; 'n' to abort this action: "
 
REM Check if the length of the input at 4th index is empty (3 chars or less) and if it starts with 'y'
set "choice=!input:~0,1!"
if /I "!choice!"=="y" (
if "!input:~3!"=="" (
echo Continuing...
echo Setting Git up in the current directory...
git init
) else (
goto wrongDirError
)
) else (
:wrongDirError
echo Aborting...
echo.
echo Press any key to exit.
pause > nul
exit
)
)
)
 
:success
Echo.
 
if ""=="" (
echo No branch name input provided. Pulling the 'main' branch.
set "branchToPull=main"
)
 
 
set "gitConfigRemoteName=%~2"
 
if "^"==^"" (
echo No input remote repo name provided. Setting to default 'origin'.
set "gitConfigRemoteName=origin"
)
rem Read configurations from the config.txt file
for /F "tokens=1,* delims== " G in (config.txt) do (
if "G"=="gitConfigUser" (
set "gitConfigUser=H"
if "!gitConfigUser!"=="" set "gitConfigUser="
)
if "G"=="gitConfigPassword" (
set "gitConfigPassword=H"
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
if "G"=="gitConfigURL" (
set "gitConfigURL=H"
if "!gitConfigURL!"=="" set "gitConfigURL="
)
)
rem Removing quotes from the config values
set "gitConfigUser=!gitConfigUser:"=!"
set "gitConfigPassword=!gitConfigPassword:"=!"
set "gitConfigURL=!gitConfigURL:"=!"
 
rem Check if the string is a space character and set it to an empty variable; space is always appended >:-( though git should deal with these strings correctly nevertheless
if "^"==^" " set "gitConfigUser="
if "^"==^" " set "gitConfigPassword="
if "^"==^" " set "gitConfigURL="
 
 
rem read current/already defined Git Config to see if theyre blank; not using --global flag!
for /F "delims=" i in ('git config user.name') do set currentGitConfigUser=i
for /F "delims=" i in ('git config user.password') do set currentGitConfigPassword=i
for /F "delims=" i in ('git config --get remote..url') do set currentGitConfigURL=i
 
if "!currentGitConfigUser!"==" " set "currentGitConfigUser="
if "!currentGitConfigPassword!"==" " set "currentGitConfigPassword="
if "!currentGitConfigURL!"==" " set "currentGitConfigURL="
 
if ==0 (
REM do nothing
goto dontSkip
) else if ==1 (
goto skipUserConfig
) else (
goto skipConfig
)
 
:dontSkip
 
REM set TAB="<TAB>"
set "TAB=   "
 
Echo Current User Name: "!currentGitConfigUser!"  Read User Name: "!gitConfigUser!"
Echo Current User PWD: "!currentGitConfigPassword!"  Read User PWD: "!gitConfigPassword!"
Echo.
Echo Pulling from Host with Name: "%gitConfigRemoteName%"
Echo Current URL under this Name: "!currentGitConfigURL!"  Read URL: "!gitConfigURL!"
 
Echo.
Echo.
 
if not "!gitConfigUser!"=="" (
if "!currentGitConfigUser!"=="" (
echo Current local Git Username is not set -> new Name: "!gitConfigUser!"
git config user.name "!gitConfigUser!"
)else (
echo Current local Git Username is already set; if the overwriteGitConfigData flag is true the current Username: "!currentGitConfigUser!" will be set to "!gitConfigUser!"
if "!overwriteGitConfigData!"=="true" (
git config user.name "!gitConfigUser!"&Echo Overwriting successful; Username "!currentGitConfigUser!" changed to "!gitConfigUser!"
REM git config --global --replace-all "!gitConfigUser!"
)
)
)
 
Echo.
Echo.
 
if not "!gitConfigPassword!"=="" (
if "!currentGitConfigPassword!"=="" (
echo Current local Git Password is not set -> new Password: "!gitConfigPassword!"
git config user.password "!gitConfigPassword!"
)else (
 
echo Current local Git Password is already set; if the overwriteGitConfigData flag is true the current Password: "!currentGitConfigPassword!" will be set to "!gitConfigPassword!"
if "!overwriteGitConfigData!"=="true" (
git config user.password "!gitConfigPassword!"&Echo Overwriting successful; Password "!currentGitConfigPassword!" changed to "!gitConfigPassword!"
REM git config --replace-all --global user.password "!gitConfigPassword!"
)
)
)
 
:skipUserConfig
Echo.
Echo.
 
if not "!gitConfigURL!"=="" (
echo get displayed
echo !gitConfigURL!
echo "!currentGitConfigURL!"
 
if "!currentGitConfigURL!"=="" (
echo Current local Git fetch URL is not set -> new URL: "!gitConfigURL!"
git remote add  "!gitConfigURL!"
) else (
echo Current local Git fetch URL is already set; if the overwriteGitConfigData flag is true the current URL: "!currentGitConfigURL!" will be set to "!gitConfigURL!"
if "!overwriteGitConfigData!"=="true" (
git remote add !gitConfigRemoteName! "!gitConfigURL!" & Echo Overwriting successful; URL "!currentGitConfigURL!" changed to "!gitConfigURL!"
)
)
) else (
Echo Either Config.txt url was empty
)
:skipConfig
 
git pull %gitConfigRemoteName% %branchToPull%
 
 
if not %errorlevel% == 0(
Echo.
Echo Git ran into an Error when pulling.
Echo Have you committed your local changes?
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
Echo Resetting uncommited local changes ...
 
git reset --hard
git pull %gitConfigRemoteName% %branchToPull%
 
) else (
goto invalidNumberLength
)
) else (
:invalidNumberLength
Echo Aborting...
Echo.
Echo Press any key to exit.
Pause > nul
Exit
)
)
endlocal
@echo off
setlocal EnableDelayedExpansion
 
set "overwriteGitConfigData=true"
 
set "skipConfig=0"
REM 0==dont skip; 1==skip userConfig; >1==skip
 
 
where git >nul 2>nul && (
echo Git is installed.
) || (
start cmd.exe /k "color 4f & title Error & Echo. & Echo. & Echo Git is not properly installed! & Echo The installation will be canceled. If this is a mistake, remove the initial check from this batch file. & Echo Press any key to close this dialog & Pause > nul & Exit"
Echo Git environment variable wasnt found; Pulling will be canceled
Echo.
Echo Press any key to exit.
Pause > nul
Exit;
)
 
 
for /f i in ('git rev-parse --is-inside-work-tree 2^>^&1') do (
if /I "i"=="true" (
goto success
) else (
echo Current directory isn't a Git repository!
echo By continuing, Git will be set up here.
set /P "input=Press 'y' to continue and configure Git here; 'n' to abort this action: "
 
REM Check if the length of the input at 4th index is empty (3 chars or less) and if it starts with 'y'
set "choice=!input:~0,1!"
if /I "!choice!"=="y" (
if "!input:~3!"=="" (
echo Continuing...
echo Setting Git up in the current directory...
git init
) else (
goto wrongDirError
)
) else (
:wrongDirError
echo Aborting...
echo.
echo Press any key to exit.
pause > nul
exit
)
)
)
 
:success
Echo.
 
if ""=="" (
echo No branch name input provided. Pulling the 'main' branch.
set "branchToPull=main"
)
 
 
set "gitConfigRemoteName=%~2"
 
if "^"==^"" (
echo No input remote repo name provided. Setting to default 'origin'.
set "gitConfigRemoteName=origin"
)
rem Read configurations from the config.txt file
for /F "tokens=1,* delims== " G in (config.txt) do (
if "G"=="gitConfigUser" (
set "gitConfigUser=H"
if "!gitConfigUser!"=="" set "gitConfigUser="
)
if "G"=="gitConfigPassword" (
set "gitConfigPassword=H"
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
if "G"=="gitConfigURL" (
set "gitConfigURL=H"
if "!gitConfigURL!"=="" set "gitConfigURL="
)
)
rem Removing quotes from the config values
set "gitConfigUser=!gitConfigUser:"=!"
set "gitConfigPassword=!gitConfigPassword:"=!"
set "gitConfigURL=!gitConfigURL:"=!"
 
rem Check if the string is a space character and set it to an empty variable; space is always appended >:-( though git should deal with these strings correctly nevertheless
if "^"==^" " set "gitConfigUser="
if "^"==^" " set "gitConfigPassword="
if "^"==^" " set "gitConfigURL="
 
 
rem read current/already defined Git Config to see if theyre blank; not using --global flag!
for /F "delims=" i in ('git config user.name') do set currentGitConfigUser=i
for /F "delims=" i in ('git config user.password') do set currentGitConfigPassword=i
for /F "delims=" i in ('git config --get remote..url') do set currentGitConfigURL=i
 
if "!currentGitConfigUser!"==" " set "currentGitConfigUser="
if "!currentGitConfigPassword!"==" " set "currentGitConfigPassword="
if "!currentGitConfigURL!"==" " set "currentGitConfigURL="
 
if ==0 (
REM do nothing
goto dontSkip
) else if ==1 (
goto skipUserConfig
) else (
goto skipConfig
)
 
:dontSkip
 
REM set TAB="<TAB>"
set "TAB=   "
 
Echo Current User Name: "!currentGitConfigUser!"  Read User Name: "!gitConfigUser!"
Echo Current User PWD: "!currentGitConfigPassword!"  Read User PWD: "!gitConfigPassword!"
Echo.
Echo Pulling from Host with Name: "%gitConfigRemoteName%"
Echo Current URL under this Name: "!currentGitConfigURL!"  Read URL: "!gitConfigURL!"
 
Echo.
Echo.
 
if not "!gitConfigUser!"=="" (
if "!currentGitConfigUser!"=="" (
echo Current local Git Username is not set -> new Name: "!gitConfigUser!"
git config user.name "!gitConfigUser!"
)else (
echo Current local Git Username is already set; if the overwriteGitConfigData flag is true the current Username: "!currentGitConfigUser!" will be set to "!gitConfigUser!"
if "!overwriteGitConfigData!"=="true" (
git config user.name "!gitConfigUser!"&Echo Overwriting successful; Username "!currentGitConfigUser!" changed to "!gitConfigUser!"
REM git config --global --replace-all "!gitConfigUser!"
)
)
)
 
Echo.
Echo.
 
if not "!gitConfigPassword!"=="" (
if "!currentGitConfigPassword!"=="" (
echo Current local Git Password is not set -> new Password: "!gitConfigPassword!"
git config user.password "!gitConfigPassword!"
)else (
 
echo Current local Git Password is already set; if the overwriteGitConfigData flag is true the current Password: "!currentGitConfigPassword!" will be set to "!gitConfigPassword!"
if "!overwriteGitConfigData!"=="true" (
git config user.password "!gitConfigPassword!"&Echo Overwriting successful; Password "!currentGitConfigPassword!" changed to "!gitConfigPassword!"
REM git config --replace-all --global user.password "!gitConfigPassword!"
)
)
)
 
:skipUserConfig
Echo.
Echo.
 
if not "!gitConfigURL!"=="" (
echo get displayed
echo !gitConfigURL!
echo "!currentGitConfigURL!"
 
if "!currentGitConfigURL!"=="" (
echo Current local Git fetch URL is not set -> new URL: "!gitConfigURL!"
git remote add  "!gitConfigURL!"
) else (
echo Current local Git fetch URL is already set; if the overwriteGitConfigData flag is true the current URL: "!currentGitConfigURL!" will be set to "!gitConfigURL!"
if "!overwriteGitConfigData!"=="true" (
git remote add !gitConfigRemoteName! "!gitConfigURL!" & Echo Overwriting successful; URL "!currentGitConfigURL!" changed to "!gitConfigURL!"
)
)
) else (
Echo Either Config.txt url was empty
)
:skipConfig
 
git pull %gitConfigRemoteName% %branchToPull%
 
 
if not %errorlevel% == 0(
Echo.
Echo Git ran into an Error when pulling.
Echo Have you committed your local changes?
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
Echo Resetting uncommited local changes ...
 
git reset --hard
git pull %gitConfigRemoteName% %branchToPull%
 
) else (
goto invalidNumberLength
)
) else (
:invalidNumberLength
Echo Aborting...
Echo.
Echo Press any key to exit.
Pause > nul
Exit
)
)
endlocal
@echo off
setlocal EnableDelayedExpansion
 
set "overwriteGitConfigData=true"
 
set "skipConfig=0"
REM 0==dont skip; 1==skip userConfig; >1==skip
 
 
where git >nul 2>nul && (
echo Git is installed.
) || (
start cmd.exe /k "color 4f & title Error & Echo. & Echo. & Echo Git is not properly installed! & Echo The installation will be canceled. If this is a mistake, remove the initial check from this batch file. & Echo Press any key to close this dialog & Pause > nul & Exit"
Echo Git environment variable wasnt found; Pulling will be canceled
Echo.
Echo Press any key to exit.
Pause > nul
Exit;
)
 
 
for /f i in ('git rev-parse --is-inside-work-tree 2^>^&1') do (
if /I "i"=="true" (
goto success
) else (
echo Current directory isn't a Git repository!
echo By continuing, Git will be set up here.
set /P "input=Press 'y' to continue and configure Git here; 'n' to abort this action: "
 
REM Check if the length of the input at 4th index is empty (3 chars or less) and if it starts with 'y'
set "choice=!input:~0,1!"
if /I "!choice!"=="y" (
if "!input:~3!"=="" (
echo Continuing...
echo Setting Git up in the current directory...
git init
) else (
goto wrongDirError
)
) else (
:wrongDirError
echo Aborting...
echo.
echo Press any key to exit.
pause > nul
exit
)
)
)
 
:success
Echo.
 
if ""=="" (
echo No branch name input provided. Pulling the 'main' branch.
set "branchToPull=main"
)
 
 
set "gitConfigRemoteName=%~2"
 
if "^"==^"" (
echo No input remote repo name provided. Setting to default 'origin'.
set "gitConfigRemoteName=origin"
)
rem Read configurations from the config.txt file
for /F "tokens=1,* delims== " G in (config.txt) do (
if "G"=="gitConfigUser" (
set "gitConfigUser=H"
if "!gitConfigUser!"=="" set "gitConfigUser="
)
if "G"=="gitConfigPassword" (
set "gitConfigPassword=H"
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
if "G"=="gitConfigURL" (
set "gitConfigURL=H"
if "!gitConfigURL!"=="" set "gitConfigURL="
)
)
rem Removing quotes from the config values
set "gitConfigUser=!gitConfigUser:"=!"
set "gitConfigPassword=!gitConfigPassword:"=!"
set "gitConfigURL=!gitConfigURL:"=!"
 
rem Check if the string is a space character and set it to an empty variable; space is always appended >:-( though git should deal with these strings correctly nevertheless
if "^"==^" " set "gitConfigUser="
if "^"==^" " set "gitConfigPassword="
if "^"==^" " set "gitConfigURL="
 
 
rem read current/already defined Git Config to see if theyre blank; not using --global flag!
for /F "delims=" i in ('git config user.name') do set currentGitConfigUser=i
for /F "delims=" i in ('git config user.password') do set currentGitConfigPassword=i
for /F "delims=" i in ('git config --get remote..url') do set currentGitConfigURL=i
 
if "!currentGitConfigUser!"==" " set "currentGitConfigUser="
if "!currentGitConfigPassword!"==" " set "currentGitConfigPassword="
if "!currentGitConfigURL!"==" " set "currentGitConfigURL="
 
if ==0 (
REM do nothing
goto dontSkip
) else if ==1 (
goto skipUserConfig
) else (
goto skipConfig
)
 
:dontSkip
 
REM set TAB="<TAB>"
set "TAB=   "
 
Echo Current User Name: "!currentGitConfigUser!"  Read User Name: "!gitConfigUser!"
Echo Current User PWD: "!currentGitConfigPassword!"  Read User PWD: "!gitConfigPassword!"
Echo.
Echo Pulling from Host with Name: "%gitConfigRemoteName%"
Echo Current URL under this Name: "!currentGitConfigURL!"  Read URL: "!gitConfigURL!"
 
Echo.
Echo.
 
if not "!gitConfigUser!"=="" (
if "!currentGitConfigUser!"=="" (
echo Current local Git Username is not set -> new Name: "!gitConfigUser!"
git config user.name "!gitConfigUser!"
)else (
echo Current local Git Username is already set; if the overwriteGitConfigData flag is true the current Username: "!currentGitConfigUser!" will be set to "!gitConfigUser!"
if "!overwriteGitConfigData!"=="true" (
git config user.name "!gitConfigUser!"&Echo Overwriting successful; Username "!currentGitConfigUser!" changed to "!gitConfigUser!"
REM git config --global --replace-all "!gitConfigUser!"
)
)
)
 
Echo.
Echo.
 
if not "!gitConfigPassword!"=="" (
if "!currentGitConfigPassword!"=="" (
echo Current local Git Password is not set -> new Password: "!gitConfigPassword!"
git config user.password "!gitConfigPassword!"
)else (
 
echo Current local Git Password is already set; if the overwriteGitConfigData flag is true the current Password: "!currentGitConfigPassword!" will be set to "!gitConfigPassword!"
if "!overwriteGitConfigData!"=="true" (
git config user.password "!gitConfigPassword!"&Echo Overwriting successful; Password "!currentGitConfigPassword!" changed to "!gitConfigPassword!"
REM git config --replace-all --global user.password "!gitConfigPassword!"
)
)
)
 
:skipUserConfig
Echo.
Echo.
 
if not "!gitConfigURL!"=="" (
echo get displayed
echo !gitConfigURL!
echo "!currentGitConfigURL!"
 
if "!currentGitConfigURL!"=="" (
echo Current local Git fetch URL is not set -> new URL: "!gitConfigURL!"
git remote add  "!gitConfigURL!"
) else (
echo Current local Git fetch URL is already set; if the overwriteGitConfigData flag is true the current URL: "!currentGitConfigURL!" will be set to "!gitConfigURL!"
if "!overwriteGitConfigData!"=="true" (
git remote add !gitConfigRemoteName! "!gitConfigURL!" & Echo Overwriting successful; URL "!currentGitConfigURL!" changed to "!gitConfigURL!"
)
)
) else (
Echo Either Config.txt url was empty
)
:skipConfig
 
git pull %gitConfigRemoteName% %branchToPull%
 
 
if not %errorlevel% == 0(
Echo.
Echo Git ran into an Error when pulling.
Echo Have you committed your local changes?
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
Echo Resetting uncommited local changes ...
 
git reset --hard
git pull %gitConfigRemoteName% %branchToPull%
 
) else (
goto invalidNumberLength
)
) else (
:invalidNumberLength
Echo Aborting...
Echo.
Echo Press any key to exit.
Pause > nul
Exit
)
)
endlocal
@echo off
setlocal EnableDelayedExpansion
 
set "overwriteGitConfigData=true"
 
set "skipConfig=0"
REM 0==dont skip; 1==skip userConfig; >1==skip
 
 
where git >nul 2>nul && (
echo Git is installed.
) || (
start cmd.exe /k "color 4f & title Error & Echo. & Echo. & Echo Git is not properly installed! & Echo The installation will be canceled. If this is a mistake, remove the initial check from this batch file. & Echo Press any key to close this dialog & Pause > nul & Exit"
Echo Git environment variable wasnt found; Pulling will be canceled
Echo.
Echo Press any key to exit.
Pause > nul
Exit;
)
 
 
for /f i in ('git rev-parse --is-inside-work-tree 2^>^&1') do (
if /I "i"=="true" (
goto success
) else (
echo Current directory isn't a Git repository!
echo By continuing, Git will be set up here.
set /P "input=Press 'y' to continue and configure Git here; 'n' to abort this action: "
 
REM Check if the length of the input at 4th index is empty (3 chars or less) and if it starts with 'y'
set "choice=!input:~0,1!"
if /I "!choice!"=="y" (
if "!input:~3!"=="" (
echo Continuing...
echo Setting Git up in the current directory...
git init
) else (
goto wrongDirError
)
) else (
:wrongDirError
echo Aborting...
echo.
echo Press any key to exit.
pause > nul
exit
)
)
)
 
:success
Echo.
 
if ""=="" (
echo No branch name input provided. Pulling the 'main' branch.
set "branchToPull=main"
)
 
 
set "gitConfigRemoteName=%~2"
 
if "^"==^"" (
echo No input remote repo name provided. Setting to default 'origin'.
set "gitConfigRemoteName=origin"
)
rem Read configurations from the config.txt file
for /F "tokens=1,* delims== " G in (config.txt) do (
if "G"=="gitConfigUser" (
set "gitConfigUser=H"
if "!gitConfigUser!"=="" set "gitConfigUser="
)
if "G"=="gitConfigPassword" (
set "gitConfigPassword=H"
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
if "G"=="gitConfigURL" (
set "gitConfigURL=H"
if "!gitConfigURL!"=="" set "gitConfigURL="
)
)
rem Removing quotes from the config values
set "gitConfigUser=!gitConfigUser:"=!"
set "gitConfigPassword=!gitConfigPassword:"=!"
set "gitConfigURL=!gitConfigURL:"=!"
 
rem Check if the string is a space character and set it to an empty variable; space is always appended >:-( though git should deal with these strings correctly nevertheless
if "^"==^" " set "gitConfigUser="
if "^"==^" " set "gitConfigPassword="
if "^"==^" " set "gitConfigURL="
 
 
rem read current/already defined Git Config to see if theyre blank; not using --global flag!
for /F "delims=" i in ('git config user.name') do set currentGitConfigUser=i
for /F "delims=" i in ('git config user.password') do set currentGitConfigPassword=i
for /F "delims=" i in ('git config --get remote..url') do set currentGitConfigURL=i
 
if "!currentGitConfigUser!"==" " set "currentGitConfigUser="
if "!currentGitConfigPassword!"==" " set "currentGitConfigPassword="
if "!currentGitConfigURL!"==" " set "currentGitConfigURL="
 
if ==0 (
REM do nothing
goto dontSkip
) else if ==1 (
goto skipUserConfig
) else (
goto skipConfig
)
 
:dontSkip
 
REM set TAB="<TAB>"
set "TAB=   "
 
Echo Current User Name: "!currentGitConfigUser!"  Read User Name: "!gitConfigUser!"
Echo Current User PWD: "!currentGitConfigPassword!"  Read User PWD: "!gitConfigPassword!"
Echo.
Echo Pulling from Host with Name: "%gitConfigRemoteName%"
Echo Current URL under this Name: "!currentGitConfigURL!"  Read URL: "!gitConfigURL!"
 
Echo.
Echo.
 
if not "!gitConfigUser!"=="" (
if "!currentGitConfigUser!"=="" (
echo Current local Git Username is not set -> new Name: "!gitConfigUser!"
git config user.name "!gitConfigUser!"
)else (
echo Current local Git Username is already set; if the overwriteGitConfigData flag is true the current Username: "!currentGitConfigUser!" will be set to "!gitConfigUser!"
if "!overwriteGitConfigData!"=="true" (
git config user.name "!gitConfigUser!"&Echo Overwriting successful; Username "!currentGitConfigUser!" changed to "!gitConfigUser!"
REM git config --global --replace-all "!gitConfigUser!"
)
)
)
 
Echo.
Echo.
 
if not "!gitConfigPassword!"=="" (
if "!currentGitConfigPassword!"=="" (
echo Current local Git Password is not set -> new Password: "!gitConfigPassword!"
git config user.password "!gitConfigPassword!"
)else (
 
echo Current local Git Password is already set; if the overwriteGitConfigData flag is true the current Password: "!currentGitConfigPassword!" will be set to "!gitConfigPassword!"
if "!overwriteGitConfigData!"=="true" (
git config user.password "!gitConfigPassword!"&Echo Overwriting successful; Password "!currentGitConfigPassword!" changed to "!gitConfigPassword!"
REM git config --replace-all --global user.password "!gitConfigPassword!"
)
)
)
 
:skipUserConfig
Echo.
Echo.
 
if not "!gitConfigURL!"=="" (
echo get displayed
echo !gitConfigURL!
echo "!currentGitConfigURL!"
 
if "!currentGitConfigURL!"=="" (
echo Current local Git fetch URL is not set -> new URL: "!gitConfigURL!"
git remote add  "!gitConfigURL!"
) else (
echo Current local Git fetch URL is already set; if the overwriteGitConfigData flag is true the current URL: "!currentGitConfigURL!" will be set to "!gitConfigURL!"
if "!overwriteGitConfigData!"=="true" (
git remote add !gitConfigRemoteName! "!gitConfigURL!" & Echo Overwriting successful; URL "!currentGitConfigURL!" changed to "!gitConfigURL!"
)
)
) else (
Echo Either Config.txt url was empty
)
:skipConfig
 
git pull %gitConfigRemoteName% %branchToPull%
 
 
if not %errorlevel% == 0(
Echo.
Echo Git ran into an Error when pulling.
Echo Have you committed your local changes?
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
Echo Resetting uncommited local changes ...
 
git reset --hard
git pull %gitConfigRemoteName% %branchToPull%
 
) else (
goto invalidNumberLength
)
) else (
:invalidNumberLength
Echo Aborting...
Echo.
Echo Press any key to exit.
Pause > nul
Exit
)
)
endlocal
@echo off
setlocal EnableDelayedExpansion
 
set "overwriteGitConfigData=true"
 
set "skipConfig=0"
REM 0==dont skip; 1==skip userConfig; >1==skip
 
 
where git >nul 2>nul && (
echo Git is installed.
) || (
start cmd.exe /k "color 4f & title Error & Echo. & Echo. & Echo Git is not properly installed! & Echo The installation will be canceled. If this is a mistake, remove the initial check from this batch file. & Echo Press any key to close this dialog & Pause > nul & Exit"
Echo Git environment variable wasnt found; Pulling will be canceled
Echo.
Echo Press any key to exit.
Pause > nul
Exit;
)
 
 
for /f i in ('git rev-parse --is-inside-work-tree 2^>^&1') do (
if /I "i"=="true" (
goto success
) else (
echo Current directory isn't a Git repository!
echo By continuing, Git will be set up here.
set /P "input=Press 'y' to continue and configure Git here; 'n' to abort this action: "
 
REM Check if the length of the input at 4th index is empty (3 chars or less) and if it starts with 'y'
set "choice=!input:~0,1!"
if /I "!choice!"=="y" (
if "!input:~3!"=="" (
echo Continuing...
echo Setting Git up in the current directory...
git init
) else (
goto wrongDirError
)
) else (
:wrongDirError
echo Aborting...
echo.
echo Press any key to exit.
pause > nul
exit
)
)
)
 
:success
Echo.
 
if ""=="" (
echo No branch name input provided. Pulling the 'main' branch.
set "branchToPull=main"
)
 
 
set "gitConfigRemoteName=%~2"
 
if "^"==^"" (
echo No input remote repo name provided. Setting to default 'origin'.
set "gitConfigRemoteName=origin"
)
rem Read configurations from the config.txt file
for /F "tokens=1,* delims== " G in (config.txt) do (
if "G"=="gitConfigUser" (
set "gitConfigUser=H"
if "!gitConfigUser!"=="" set "gitConfigUser="
)
if "G"=="gitConfigPassword" (
set "gitConfigPassword=H"
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
if "G"=="gitConfigURL" (
set "gitConfigURL=H"
if "!gitConfigURL!"=="" set "gitConfigURL="
)
)
rem Removing quotes from the config values
set "gitConfigUser=!gitConfigUser:"=!"
set "gitConfigPassword=!gitConfigPassword:"=!"
set "gitConfigURL=!gitConfigURL:"=!"
 
rem Check if the string is a space character and set it to an empty variable; space is always appended >:-( though git should deal with these strings correctly nevertheless
if "^"==^" " set "gitConfigUser="
if "^"==^" " set "gitConfigPassword="
if "^"==^" " set "gitConfigURL="
 
 
rem read current/already defined Git Config to see if theyre blank; not using --global flag!
for /F "delims=" i in ('git config user.name') do set currentGitConfigUser=i
for /F "delims=" i in ('git config user.password') do set currentGitConfigPassword=i
for /F "delims=" i in ('git config --get remote..url') do set currentGitConfigURL=i
 
if "!currentGitConfigUser!"==" " set "currentGitConfigUser="
if "!currentGitConfigPassword!"==" " set "currentGitConfigPassword="
if "!currentGitConfigURL!"==" " set "currentGitConfigURL="
 
if ==0 (
REM do nothing
goto dontSkip
) else if ==1 (
goto skipUserConfig
) else (
goto skipConfig
)
 
:dontSkip
 
REM set TAB="<TAB>"
set "TAB=   "
 
Echo Current User Name: "!currentGitConfigUser!"  Read User Name: "!gitConfigUser!"
Echo Current User PWD: "!currentGitConfigPassword!"  Read User PWD: "!gitConfigPassword!"
Echo.
Echo Pulling from Host with Name: "%gitConfigRemoteName%"
Echo Current URL under this Name: "!currentGitConfigURL!"  Read URL: "!gitConfigURL!"
 
Echo.
Echo.
 
if not "!gitConfigUser!"=="" (
if "!currentGitConfigUser!"=="" (
echo Current local Git Username is not set -> new Name: "!gitConfigUser!"
git config user.name "!gitConfigUser!"
)else (
echo Current local Git Username is already set; if the overwriteGitConfigData flag is true the current Username: "!currentGitConfigUser!" will be set to "!gitConfigUser!"
if "!overwriteGitConfigData!"=="true" (
git config user.name "!gitConfigUser!"&Echo Overwriting successful; Username "!currentGitConfigUser!" changed to "!gitConfigUser!"
REM git config --global --replace-all "!gitConfigUser!"
)
)
)
 
Echo.
Echo.
 
if not "!gitConfigPassword!"=="" (
if "!currentGitConfigPassword!"=="" (
echo Current local Git Password is not set -> new Password: "!gitConfigPassword!"
git config user.password "!gitConfigPassword!"
)else (
 
echo Current local Git Password is already set; if the overwriteGitConfigData flag is true the current Password: "!currentGitConfigPassword!" will be set to "!gitConfigPassword!"
if "!overwriteGitConfigData!"=="true" (
git config user.password "!gitConfigPassword!"&Echo Overwriting successful; Password "!currentGitConfigPassword!" changed to "!gitConfigPassword!"
REM git config --replace-all --global user.password "!gitConfigPassword!"
)
)
)
 
:skipUserConfig
Echo.
Echo.
 
if not "!gitConfigURL!"=="" (
echo get displayed
echo !gitConfigURL!
echo "!currentGitConfigURL!"
 
if "!currentGitConfigURL!"=="" (
echo Current local Git fetch URL is not set -> new URL: "!gitConfigURL!"
git remote add  "!gitConfigURL!"
) else (
echo Current local Git fetch URL is already set; if the overwriteGitConfigData flag is true the current URL: "!currentGitConfigURL!" will be set to "!gitConfigURL!"
if "!overwriteGitConfigData!"=="true" (
git remote add !gitConfigRemoteName! "!gitConfigURL!" & Echo Overwriting successful; URL "!currentGitConfigURL!" changed to "!gitConfigURL!"
)
)
) else (
Echo Either Config.txt url was empty
)
:skipConfig
 
git pull %gitConfigRemoteName% %branchToPull%
 
 
if not %errorlevel% == 0(
Echo.
Echo Git ran into an Error when pulling.
Echo Have you committed your local changes?
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
Echo Resetting uncommited local changes ...
 
git reset --hard
git pull %gitConfigRemoteName% %branchToPull%
 
) else (
goto invalidNumberLength
)
) else (
:invalidNumberLength
Echo Aborting...
Echo.
Echo Press any key to exit.
Pause > nul
Exit
)
)
endlocal
@echo off
setlocal EnableDelayedExpansion
 
set "overwriteGitConfigData=true"
 
set "skipConfig=0"
REM 0==dont skip; 1==skip userConfig; >1==skip
 
 
where git >nul 2>nul && (
echo Git is installed.
) || (
start cmd.exe /k "color 4f & title Error & Echo. & Echo. & Echo Git is not properly installed! & Echo The installation will be canceled. If this is a mistake, remove the initial check from this batch file. & Echo Press any key to close this dialog & Pause > nul & Exit"
Echo Git environment variable wasnt found; Pulling will be canceled
Echo.
Echo Press any key to exit.
Pause > nul
Exit;
)
 
 
for /f i in ('git rev-parse --is-inside-work-tree 2^>^&1') do (
if /I "i"=="true" (
goto success
) else (
echo Current directory isn't a Git repository!
echo By continuing, Git will be set up here.
set /P "input=Press 'y' to continue and configure Git here; 'n' to abort this action: "
 
REM Check if the length of the input at 4th index is empty (3 chars or less) and if it starts with 'y'
set "choice=!input:~0,1!"
if /I "!choice!"=="y" (
if "!input:~3!"=="" (
echo Continuing...
echo Setting Git up in the current directory...
git init
) else (
goto wrongDirError
)
) else (
:wrongDirError
echo Aborting...
echo.
echo Press any key to exit.
pause > nul
exit
)
)
)
 
:success
Echo.
 
if ""=="" (
echo No branch name input provided. Pulling the 'main' branch.
set "branchToPull=main"
)
 
 
set "gitConfigRemoteName=%~2"
 
if "^"==^"" (
echo No input remote repo name provided. Setting to default 'origin'.
set "gitConfigRemoteName=origin"
)
rem Read configurations from the config.txt file
for /F "tokens=1,* delims== " G in (config.txt) do (
if "G"=="gitConfigUser" (
set "gitConfigUser=H"
if "!gitConfigUser!"=="" set "gitConfigUser="
)
if "G"=="gitConfigPassword" (
set "gitConfigPassword=H"
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
if "G"=="gitConfigURL" (
set "gitConfigURL=H"
if "!gitConfigURL!"=="" set "gitConfigURL="
)
)
rem Removing quotes from the config values
set "gitConfigUser=!gitConfigUser:"=!"
set "gitConfigPassword=!gitConfigPassword:"=!"
set "gitConfigURL=!gitConfigURL:"=!"
 
rem Check if the string is a space character and set it to an empty variable; space is always appended >:-( though git should deal with these strings correctly nevertheless
if "^"==^" " set "gitConfigUser="
if "^"==^" " set "gitConfigPassword="
if "^"==^" " set "gitConfigURL="
 
 
rem read current/already defined Git Config to see if theyre blank; not using --global flag!
for /F "delims=" i in ('git config user.name') do set currentGitConfigUser=i
for /F "delims=" i in ('git config user.password') do set currentGitConfigPassword=i
for /F "delims=" i in ('git config --get remote..url') do set currentGitConfigURL=i
 
if "!currentGitConfigUser!"==" " set "currentGitConfigUser="
if "!currentGitConfigPassword!"==" " set "currentGitConfigPassword="
if "!currentGitConfigURL!"==" " set "currentGitConfigURL="
 
if ==0 (
REM do nothing
goto dontSkip
) else if ==1 (
goto skipUserConfig
) else (
goto skipConfig
)
 
:dontSkip
 
REM set TAB="<TAB>"
set "TAB=   "
 
Echo Current User Name: "!currentGitConfigUser!"  Read User Name: "!gitConfigUser!"
Echo Current User PWD: "!currentGitConfigPassword!"  Read User PWD: "!gitConfigPassword!"
Echo.
Echo Pulling from Host with Name: "%gitConfigRemoteName%"
Echo Current URL under this Name: "!currentGitConfigURL!"  Read URL: "!gitConfigURL!"
 
Echo.
Echo.
 
if not "!gitConfigUser!"=="" (
if "!currentGitConfigUser!"=="" (
echo Current local Git Username is not set -> new Name: "!gitConfigUser!"
git config user.name "!gitConfigUser!"
)else (
echo Current local Git Username is already set; if the overwriteGitConfigData flag is true the current Username: "!currentGitConfigUser!" will be set to "!gitConfigUser!"
if "!overwriteGitConfigData!"=="true" (
git config user.name "!gitConfigUser!"&Echo Overwriting successful; Username "!currentGitConfigUser!" changed to "!gitConfigUser!"
REM git config --global --replace-all "!gitConfigUser!"
)
)
)
 
Echo.
Echo.
 
if not "!gitConfigPassword!"=="" (
if "!currentGitConfigPassword!"=="" (
echo Current local Git Password is not set -> new Password: "!gitConfigPassword!"
git config user.password "!gitConfigPassword!"
)else (
 
echo Current local Git Password is already set; if the overwriteGitConfigData flag is true the current Password: "!currentGitConfigPassword!" will be set to "!gitConfigPassword!"
if "!overwriteGitConfigData!"=="true" (
git config user.password "!gitConfigPassword!"&Echo Overwriting successful; Password "!currentGitConfigPassword!" changed to "!gitConfigPassword!"
REM git config --replace-all --global user.password "!gitConfigPassword!"
)
)
)
 
:skipUserConfig
Echo.
Echo.
 
if not "!gitConfigURL!"=="" (
echo get displayed
echo !gitConfigURL!
echo "!currentGitConfigURL!"
 
if "!currentGitConfigURL!"=="" (
echo Current local Git fetch URL is not set -> new URL: "!gitConfigURL!"
git remote add  "!gitConfigURL!"
) else (
echo Current local Git fetch URL is already set; if the overwriteGitConfigData flag is true the current URL: "!currentGitConfigURL!" will be set to "!gitConfigURL!"
if "!overwriteGitConfigData!"=="true" (
git remote add !gitConfigRemoteName! "!gitConfigURL!" & Echo Overwriting successful; URL "!currentGitConfigURL!" changed to "!gitConfigURL!"
)
)
) else (
Echo Either Config.txt url was empty
)
:skipConfig
 
git pull %gitConfigRemoteName% %branchToPull%
 
 
if not %errorlevel% == 0(
Echo.
Echo Git ran into an Error when pulling.
Echo Have you committed your local changes?
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
Echo Resetting uncommited local changes ...
 
git reset --hard
git pull %gitConfigRemoteName% %branchToPull%
 
) else (
goto invalidNumberLength
)
) else (
:invalidNumberLength
Echo Aborting...
Echo.
Echo Press any key to exit.
Pause > nul
Exit
)
)
endlocal
@echo off
setlocal EnableDelayedExpansion
 
set "overwriteGitConfigData=true"
 
set "skipConfig=0"
REM 0==dont skip; 1==skip userConfig; >1==skip
 
 
where git >nul 2>nul && (
echo Git is installed.
) || (
start cmd.exe /k "color 4f & title Error & Echo. & Echo. & Echo Git is not properly installed! & Echo The installation will be canceled. If this is a mistake, remove the initial check from this batch file. & Echo Press any key to close this dialog & Pause > nul & Exit"
Echo Git environment variable wasnt found; Pulling will be canceled
Echo.
Echo Press any key to exit.
Pause > nul
Exit;
)
 
 
for /f i in ('git rev-parse --is-inside-work-tree 2^>^&1') do (
if /I "i"=="true" (
goto success
) else (
echo Current directory isn't a Git repository!
echo By continuing, Git will be set up here.
set /P "input=Press 'y' to continue and configure Git here; 'n' to abort this action: "
 
REM Check if the length of the input at 4th index is empty (3 chars or less) and if it starts with 'y'
set "choice=!input:~0,1!"
if /I "!choice!"=="y" (
if "!input:~3!"=="" (
echo Continuing...
echo Setting Git up in the current directory...
git init
) else (
goto wrongDirError
)
) else (
:wrongDirError
echo Aborting...
echo.
echo Press any key to exit.
pause > nul
exit
)
)
)
 
:success
Echo.
 
if ""=="" (
echo No branch name input provided. Pulling the 'main' branch.
set "branchToPull=main"
)
 
 
set "gitConfigRemoteName=%~2"
 
if "^"==^"" (
echo No input remote repo name provided. Setting to default 'origin'.
set "gitConfigRemoteName=origin"
)
rem Read configurations from the config.txt file
for /F "tokens=1,* delims== " G in (config.txt) do (
if "G"=="gitConfigUser" (
set "gitConfigUser=H"
if "!gitConfigUser!"=="" set "gitConfigUser="
)
if "G"=="gitConfigPassword" (
set "gitConfigPassword=H"
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
if "G"=="gitConfigURL" (
set "gitConfigURL=H"
if "!gitConfigURL!"=="" set "gitConfigURL="
)
)
rem Removing quotes from the config values
set "gitConfigUser=!gitConfigUser:"=!"
set "gitConfigPassword=!gitConfigPassword:"=!"
set "gitConfigURL=!gitConfigURL:"=!"
 
rem Check if the string is a space character and set it to an empty variable; space is always appended >:-( though git should deal with these strings correctly nevertheless
if "^"==^" " set "gitConfigUser="
if "^"==^" " set "gitConfigPassword="
if "^"==^" " set "gitConfigURL="
 
 
rem read current/already defined Git Config to see if theyre blank; not using --global flag!
for /F "delims=" i in ('git config user.name') do set currentGitConfigUser=i
for /F "delims=" i in ('git config user.password') do set currentGitConfigPassword=i
for /F "delims=" i in ('git config --get remote..url') do set currentGitConfigURL=i
 
if "!currentGitConfigUser!"==" " set "currentGitConfigUser="
if "!currentGitConfigPassword!"==" " set "currentGitConfigPassword="
if "!currentGitConfigURL!"==" " set "currentGitConfigURL="
 
if ==0 (
REM do nothing
goto dontSkip
) else if ==1 (
goto skipUserConfig
) else (
goto skipConfig
)
 
:dontSkip
 
REM set TAB="<TAB>"
set "TAB=   "
 
Echo Current User Name: "!currentGitConfigUser!"  Read User Name: "!gitConfigUser!"
Echo Current User PWD: "!currentGitConfigPassword!"  Read User PWD: "!gitConfigPassword!"
Echo.
Echo Pulling from Host with Name: "%gitConfigRemoteName%"
Echo Current URL under this Name: "!currentGitConfigURL!"  Read URL: "!gitConfigURL!"
 
Echo.
Echo.
 
if not "!gitConfigUser!"=="" (
if "!currentGitConfigUser!"=="" (
echo Current local Git Username is not set -> new Name: "!gitConfigUser!"
git config user.name "!gitConfigUser!"
)else (
echo Current local Git Username is already set; if the overwriteGitConfigData flag is true the current Username: "!currentGitConfigUser!" will be set to "!gitConfigUser!"
if "!overwriteGitConfigData!"=="true" (
git config user.name "!gitConfigUser!"&Echo Overwriting successful; Username "!currentGitConfigUser!" changed to "!gitConfigUser!"
REM git config --global --replace-all "!gitConfigUser!"
)
)
)
 
Echo.
Echo.
 
if not "!gitConfigPassword!"=="" (
if "!currentGitConfigPassword!"=="" (
echo Current local Git Password is not set -> new Password: "!gitConfigPassword!"
git config user.password "!gitConfigPassword!"
)else (
 
echo Current local Git Password is already set; if the overwriteGitConfigData flag is true the current Password: "!currentGitConfigPassword!" will be set to "!gitConfigPassword!"
if "!overwriteGitConfigData!"=="true" (
git config user.password "!gitConfigPassword!"&Echo Overwriting successful; Password "!currentGitConfigPassword!" changed to "!gitConfigPassword!"
REM git config --replace-all --global user.password "!gitConfigPassword!"
)
)
)
 
:skipUserConfig
Echo.
Echo.
 
if not "!gitConfigURL!"=="" (
echo get displayed
echo !gitConfigURL!
echo "!currentGitConfigURL!"
 
if "!currentGitConfigURL!"=="" (
echo Current local Git fetch URL is not set -> new URL: "!gitConfigURL!"
git remote add  "!gitConfigURL!"
) else (
echo Current local Git fetch URL is already set; if the overwriteGitConfigData flag is true the current URL: "!currentGitConfigURL!" will be set to "!gitConfigURL!"
if "!overwriteGitConfigData!"=="true" (
git remote add !gitConfigRemoteName! "!gitConfigURL!" & Echo Overwriting successful; URL "!currentGitConfigURL!" changed to "!gitConfigURL!"
)
)
) else (
Echo Either Config.txt url was empty
)
:skipConfig
 
git pull %gitConfigRemoteName% %branchToPull%
 
 
if not %errorlevel% == 0(
Echo.
Echo Git ran into an Error when pulling.
Echo Have you committed your local changes?
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
Echo Resetting uncommited local changes ...
 
git reset --hard
git pull %gitConfigRemoteName% %branchToPull%
 
) else (
goto invalidNumberLength
)
) else (
:invalidNumberLength
Echo Aborting...
Echo.
Echo Press any key to exit.
Pause > nul
Exit
)
)
endlocal
@echo off
setlocal EnableDelayedExpansion
 
set "overwriteGitConfigData=true"
 
set "skipConfig=0"
REM 0==dont skip; 1==skip userConfig; >1==skip
 
 
where git >nul 2>nul && (
echo Git is installed.
) || (
start cmd.exe /k "color 4f & title Error & Echo. & Echo. & Echo Git is not properly installed! & Echo The installation will be canceled. If this is a mistake, remove the initial check from this batch file. & Echo Press any key to close this dialog & Pause > nul & Exit"
Echo Git environment variable wasnt found; Pulling will be canceled
Echo.
Echo Press any key to exit.
Pause > nul
Exit;
)
 
 
for /f i in ('git rev-parse --is-inside-work-tree 2^>^&1') do (
if /I "i"=="true" (
goto success
) else (
echo Current directory isn't a Git repository!
echo By continuing, Git will be set up here.
set /P "input=Press 'y' to continue and configure Git here; 'n' to abort this action: "
 
REM Check if the length of the input at 4th index is empty (3 chars or less) and if it starts with 'y'
set "choice=!input:~0,1!"
if /I "!choice!"=="y" (
if "!input:~3!"=="" (
echo Continuing...
echo Setting Git up in the current directory...
git init
) else (
goto wrongDirError
)
) else (
:wrongDirError
echo Aborting...
echo.
echo Press any key to exit.
pause > nul
exit
)
)
)
 
:success
Echo.
 
if ""=="" (
echo No branch name input provided. Pulling the 'main' branch.
set "branchToPull=main"
)
 
 
set "gitConfigRemoteName=%~2"
 
if "^"==^"" (
echo No input remote repo name provided. Setting to default 'origin'.
set "gitConfigRemoteName=origin"
)
rem Read configurations from the config.txt file
for /F "tokens=1,* delims== " G in (config.txt) do (
if "G"=="gitConfigUser" (
set "gitConfigUser=H"
if "!gitConfigUser!"=="" set "gitConfigUser="
)
if "G"=="gitConfigPassword" (
set "gitConfigPassword=H"
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
if "G"=="gitConfigURL" (
set "gitConfigURL=H"
if "!gitConfigURL!"=="" set "gitConfigURL="
)
)
rem Removing quotes from the config values
set "gitConfigUser=!gitConfigUser:"=!"
set "gitConfigPassword=!gitConfigPassword:"=!"
set "gitConfigURL=!gitConfigURL:"=!"
 
rem Check if the string is a space character and set it to an empty variable; space is always appended >:-( though git should deal with these strings correctly nevertheless
if "^"==^" " set "gitConfigUser="
if "^"==^" " set "gitConfigPassword="
if "^"==^" " set "gitConfigURL="
 
 
rem read current/already defined Git Config to see if theyre blank; not using --global flag!
for /F "delims=" i in ('git config user.name') do set currentGitConfigUser=i
for /F "delims=" i in ('git config user.password') do set currentGitConfigPassword=i
for /F "delims=" i in ('git config --get remote..url') do set currentGitConfigURL=i
 
if "!currentGitConfigUser!"==" " set "currentGitConfigUser="
if "!currentGitConfigPassword!"==" " set "currentGitConfigPassword="
if "!currentGitConfigURL!"==" " set "currentGitConfigURL="
 
if ==0 (
REM do nothing
goto dontSkip
) else if ==1 (
goto skipUserConfig
) else (
goto skipConfig
)
 
:dontSkip
 
REM set TAB="<TAB>"
set "TAB=   "
 
Echo Current User Name: "!currentGitConfigUser!"  Read User Name: "!gitConfigUser!"
Echo Current User PWD: "!currentGitConfigPassword!"  Read User PWD: "!gitConfigPassword!"
Echo.
Echo Pulling from Host with Name: "%gitConfigRemoteName%"
Echo Current URL under this Name: "!currentGitConfigURL!"  Read URL: "!gitConfigURL!"
 
Echo.
Echo.
 
if not "!gitConfigUser!"=="" (
if "!currentGitConfigUser!"=="" (
echo Current local Git Username is not set -> new Name: "!gitConfigUser!"
git config user.name "!gitConfigUser!"
)else (
echo Current local Git Username is already set; if the overwriteGitConfigData flag is true the current Username: "!currentGitConfigUser!" will be set to "!gitConfigUser!"
if "!overwriteGitConfigData!"=="true" (
git config user.name "!gitConfigUser!"&Echo Overwriting successful; Username "!currentGitConfigUser!" changed to "!gitConfigUser!"
REM git config --global --replace-all "!gitConfigUser!"
)
)
)
 
Echo.
Echo.
 
if not "!gitConfigPassword!"=="" (
if "!currentGitConfigPassword!"=="" (
echo Current local Git Password is not set -> new Password: "!gitConfigPassword!"
git config user.password "!gitConfigPassword!"
)else (
 
echo Current local Git Password is already set; if the overwriteGitConfigData flag is true the current Password: "!currentGitConfigPassword!" will be set to "!gitConfigPassword!"
if "!overwriteGitConfigData!"=="true" (
git config user.password "!gitConfigPassword!"&Echo Overwriting successful; Password "!currentGitConfigPassword!" changed to "!gitConfigPassword!"
REM git config --replace-all --global user.password "!gitConfigPassword!"
)
)
)
 
:skipUserConfig
Echo.
Echo.
 
if not "!gitConfigURL!"=="" (
echo get displayed
echo !gitConfigURL!
echo "!currentGitConfigURL!"
 
if "!currentGitConfigURL!"=="" (
echo Current local Git fetch URL is not set -> new URL: "!gitConfigURL!"
git remote add  "!gitConfigURL!"
) else (
echo Current local Git fetch URL is already set; if the overwriteGitConfigData flag is true the current URL: "!currentGitConfigURL!" will be set to "!gitConfigURL!"
if "!overwriteGitConfigData!"=="true" (
git remote add !gitConfigRemoteName! "!gitConfigURL!" & Echo Overwriting successful; URL "!currentGitConfigURL!" changed to "!gitConfigURL!"
)
)
) else (
Echo Either Config.txt url was empty
)
:skipConfig
 
git pull %gitConfigRemoteName% %branchToPull%
 
 
if not %errorlevel% == 0(
Echo.
Echo Git ran into an Error when pulling.
Echo Have you committed your local changes?
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
Echo Resetting uncommited local changes ...
 
git reset --hard
git pull %gitConfigRemoteName% %branchToPull%
 
) else (
goto invalidNumberLength
)
) else (
:invalidNumberLength
Echo Aborting...
Echo.
Echo Press any key to exit.
Pause > nul
Exit
)
)
endlocal
@echo off
setlocal EnableDelayedExpansion
 
set "overwriteGitConfigData=true"
 
set "skipConfig=0"
REM 0==dont skip; 1==skip userConfig; >1==skip
 
 
where git >nul 2>nul && (
echo Git is installed.
) || (
start cmd.exe /k "color 4f & title Error & Echo. & Echo. & Echo Git is not properly installed! & Echo The installation will be canceled. If this is a mistake, remove the initial check from this batch file. & Echo Press any key to close this dialog & Pause > nul & Exit"
Echo Git environment variable wasnt found; Pulling will be canceled
Echo.
Echo Press any key to exit.
Pause > nul
Exit;
)
 
 
for /f i in ('git rev-parse --is-inside-work-tree 2^>^&1') do (
if /I "i"=="true" (
goto success
) else (
echo Current directory isn't a Git repository!
echo By continuing, Git will be set up here.
set /P "input=Press 'y' to continue and configure Git here; 'n' to abort this action: "
 
REM Check if the length of the input at 4th index is empty (3 chars or less) and if it starts with 'y'
set "choice=!input:~0,1!"
if /I "!choice!"=="y" (
if "!input:~3!"=="" (
echo Continuing...
echo Setting Git up in the current directory...
git init
) else (
goto wrongDirError
)
) else (
:wrongDirError
echo Aborting...
echo.
echo Press any key to exit.
pause > nul
exit
)
)
)
 
:success
Echo.
 
if ""=="" (
echo No branch name input provided. Pulling the 'main' branch.
set "branchToPull=main"
)
 
 
set "gitConfigRemoteName=%~2"
 
if "^"==^"" (
echo No input remote repo name provided. Setting to default 'origin'.
set "gitConfigRemoteName=origin"
)
rem Read configurations from the config.txt file
for /F "tokens=1,* delims== " G in (config.txt) do (
if "G"=="gitConfigUser" (
set "gitConfigUser=H"
if "!gitConfigUser!"=="" set "gitConfigUser="
)
if "G"=="gitConfigPassword" (
set "gitConfigPassword=H"
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
if "G"=="gitConfigURL" (
set "gitConfigURL=H"
if "!gitConfigURL!"=="" set "gitConfigURL="
)
)
rem Removing quotes from the config values
set "gitConfigUser=!gitConfigUser:"=!"
set "gitConfigPassword=!gitConfigPassword:"=!"
set "gitConfigURL=!gitConfigURL:"=!"
 
rem Check if the string is a space character and set it to an empty variable; space is always appended >:-( though git should deal with these strings correctly nevertheless
if "^"==^" " set "gitConfigUser="
if "^"==^" " set "gitConfigPassword="
if "^"==^" " set "gitConfigURL="
 
 
rem read current/already defined Git Config to see if theyre blank; not using --global flag!
for /F "delims=" i in ('git config user.name') do set currentGitConfigUser=i
for /F "delims=" i in ('git config user.password') do set currentGitConfigPassword=i
for /F "delims=" i in ('git config --get remote..url') do set currentGitConfigURL=i
 
if "!currentGitConfigUser!"==" " set "currentGitConfigUser="
if "!currentGitConfigPassword!"==" " set "currentGitConfigPassword="
if "!currentGitConfigURL!"==" " set "currentGitConfigURL="
 
if ==0 (
REM do nothing
goto dontSkip
) else if ==1 (
goto skipUserConfig
) else (
goto skipConfig
)
 
:dontSkip
 
REM set TAB="<TAB>"
set "TAB=   "
 
Echo Current User Name: "!currentGitConfigUser!"  Read User Name: "!gitConfigUser!"
Echo Current User PWD: "!currentGitConfigPassword!"  Read User PWD: "!gitConfigPassword!"
Echo.
Echo Pulling from Host with Name: "%gitConfigRemoteName%"
Echo Current URL under this Name: "!currentGitConfigURL!"  Read URL: "!gitConfigURL!"
 
Echo.
Echo.
 
if not "!gitConfigUser!"=="" (
if "!currentGitConfigUser!"=="" (
echo Current local Git Username is not set -> new Name: "!gitConfigUser!"
git config user.name "!gitConfigUser!"
)else (
echo Current local Git Username is already set; if the overwriteGitConfigData flag is true the current Username: "!currentGitConfigUser!" will be set to "!gitConfigUser!"
if "!overwriteGitConfigData!"=="true" (
git config user.name "!gitConfigUser!"&Echo Overwriting successful; Username "!currentGitConfigUser!" changed to "!gitConfigUser!"
REM git config --global --replace-all "!gitConfigUser!"
)
)
)
 
Echo.
Echo.
 
if not "!gitConfigPassword!"=="" (
if "!currentGitConfigPassword!"=="" (
echo Current local Git Password is not set -> new Password: "!gitConfigPassword!"
git config user.password "!gitConfigPassword!"
)else (
 
echo Current local Git Password is already set; if the overwriteGitConfigData flag is true the current Password: "!currentGitConfigPassword!" will be set to "!gitConfigPassword!"
if "!overwriteGitConfigData!"=="true" (
git config user.password "!gitConfigPassword!"&Echo Overwriting successful; Password "!currentGitConfigPassword!" changed to "!gitConfigPassword!"
REM git config --replace-all --global user.password "!gitConfigPassword!"
)
)
)
 
:skipUserConfig
Echo.
Echo.
 
if not "!gitConfigURL!"=="" (
echo get displayed
echo !gitConfigURL!
echo "!currentGitConfigURL!"
 
if "!currentGitConfigURL!"=="" (
echo Current local Git fetch URL is not set -> new URL: "!gitConfigURL!"
git remote add  "!gitConfigURL!"
) else (
echo Current local Git fetch URL is already set; if the overwriteGitConfigData flag is true the current URL: "!currentGitConfigURL!" will be set to "!gitConfigURL!"
if "!overwriteGitConfigData!"=="true" (
git remote add !gitConfigRemoteName! "!gitConfigURL!" & Echo Overwriting successful; URL "!currentGitConfigURL!" changed to "!gitConfigURL!"
)
)
) else (
Echo Either Config.txt url was empty
)
:skipConfig
 
git pull %gitConfigRemoteName% %branchToPull%
 
 
if not %errorlevel% == 0(
Echo.
Echo Git ran into an Error when pulling.
Echo Have you committed your local changes?
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
Echo Resetting uncommited local changes ...
 
git reset --hard
git pull %gitConfigRemoteName% %branchToPull%
 
) else (
goto invalidNumberLength
)
) else (
:invalidNumberLength
Echo Aborting...
Echo.
Echo Press any key to exit.
Pause > nul
Exit
)
)
endlocal
@echo off
setlocal EnableDelayedExpansion
 
set "overwriteGitConfigData=true"
 
set "skipConfig=0"
REM 0==dont skip; 1==skip userConfig; >1==skip
 
 
where git >nul 2>nul && (
echo Git is installed.
) || (
start cmd.exe /k "color 4f & title Error & Echo. & Echo. & Echo Git is not properly installed! & Echo The installation will be canceled. If this is a mistake, remove the initial check from this batch file. & Echo Press any key to close this dialog & Pause > nul & Exit"
Echo Git environment variable wasnt found; Pulling will be canceled
Echo.
Echo Press any key to exit.
Pause > nul
Exit;
)
 
 
for /f i in ('git rev-parse --is-inside-work-tree 2^>^&1') do (
if /I "i"=="true" (
goto success
) else (
echo Current directory isn't a Git repository!
echo By continuing, Git will be set up here.
set /P "input=Press 'y' to continue and configure Git here; 'n' to abort this action: "
 
REM Check if the length of the input at 4th index is empty (3 chars or less) and if it starts with 'y'
set "choice=!input:~0,1!"
if /I "!choice!"=="y" (
if "!input:~3!"=="" (
echo Continuing...
echo Setting Git up in the current directory...
git init
) else (
goto wrongDirError
)
) else (
:wrongDirError
echo Aborting...
echo.
echo Press any key to exit.
pause > nul
exit
)
)
)
 
:success
Echo.
 
if ""=="" (
echo No branch name input provided. Pulling the 'main' branch.
set "branchToPull=main"
)
 
 
set "gitConfigRemoteName=%~2"
 
if "^"==^"" (
echo No input remote repo name provided. Setting to default 'origin'.
set "gitConfigRemoteName=origin"
)
rem Read configurations from the config.txt file
for /F "tokens=1,* delims== " G in (config.txt) do (
if "G"=="gitConfigUser" (
set "gitConfigUser=H"
if "!gitConfigUser!"=="" set "gitConfigUser="
)
if "G"=="gitConfigPassword" (
set "gitConfigPassword=H"
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
if "G"=="gitConfigURL" (
set "gitConfigURL=H"
if "!gitConfigURL!"=="" set "gitConfigURL="
)
)
rem Removing quotes from the config values
set "gitConfigUser=!gitConfigUser:"=!"
set "gitConfigPassword=!gitConfigPassword:"=!"
set "gitConfigURL=!gitConfigURL:"=!"
 
rem Check if the string is a space character and set it to an empty variable; space is always appended >:-( though git should deal with these strings correctly nevertheless
if "^"==^" " set "gitConfigUser="
if "^"==^" " set "gitConfigPassword="
if "^"==^" " set "gitConfigURL="
 
 
rem read current/already defined Git Config to see if theyre blank; not using --global flag!
for /F "delims=" i in ('git config user.name') do set currentGitConfigUser=i
for /F "delims=" i in ('git config user.password') do set currentGitConfigPassword=i
for /F "delims=" i in ('git config --get remote..url') do set currentGitConfigURL=i
 
if "!currentGitConfigUser!"==" " set "currentGitConfigUser="
if "!currentGitConfigPassword!"==" " set "currentGitConfigPassword="
if "!currentGitConfigURL!"==" " set "currentGitConfigURL="
 
if ==0 (
REM do nothing
goto dontSkip
) else if ==1 (
goto skipUserConfig
) else (
goto skipConfig
)
 
:dontSkip
 
REM set TAB="<TAB>"
set "TAB=   "
 
Echo Current User Name: "!currentGitConfigUser!"  Read User Name: "!gitConfigUser!"
Echo Current User PWD: "!currentGitConfigPassword!"  Read User PWD: "!gitConfigPassword!"
Echo.
Echo Pulling from Host with Name: "%gitConfigRemoteName%"
Echo Current URL under this Name: "!currentGitConfigURL!"  Read URL: "!gitConfigURL!"
 
Echo.
Echo.
 
if not "!gitConfigUser!"=="" (
if "!currentGitConfigUser!"=="" (
echo Current local Git Username is not set -> new Name: "!gitConfigUser!"
git config user.name "!gitConfigUser!"
)else (
echo Current local Git Username is already set; if the overwriteGitConfigData flag is true the current Username: "!currentGitConfigUser!" will be set to "!gitConfigUser!"
if "!overwriteGitConfigData!"=="true" (
git config user.name "!gitConfigUser!"&Echo Overwriting successful; Username "!currentGitConfigUser!" changed to "!gitConfigUser!"
REM git config --global --replace-all "!gitConfigUser!"
)
)
)
 
Echo.
Echo.
 
if not "!gitConfigPassword!"=="" (
if "!currentGitConfigPassword!"=="" (
echo Current local Git Password is not set -> new Password: "!gitConfigPassword!"
git config user.password "!gitConfigPassword!"
)else (
 
echo Current local Git Password is already set; if the overwriteGitConfigData flag is true the current Password: "!currentGitConfigPassword!" will be set to "!gitConfigPassword!"
if "!overwriteGitConfigData!"=="true" (
git config user.password "!gitConfigPassword!"&Echo Overwriting successful; Password "!currentGitConfigPassword!" changed to "!gitConfigPassword!"
REM git config --replace-all --global user.password "!gitConfigPassword!"
)
)
)
 
:skipUserConfig
Echo.
Echo.
 
if not "!gitConfigURL!"=="" (
echo get displayed
echo !gitConfigURL!
echo "!currentGitConfigURL!"
 
if "!currentGitConfigURL!"=="" (
echo Current local Git fetch URL is not set -> new URL: "!gitConfigURL!"
git remote add  "!gitConfigURL!"
) else (
echo Current local Git fetch URL is already set; if the overwriteGitConfigData flag is true the current URL: "!currentGitConfigURL!" will be set to "!gitConfigURL!"
if "!overwriteGitConfigData!"=="true" (
git remote add !gitConfigRemoteName! "!gitConfigURL!" & Echo Overwriting successful; URL "!currentGitConfigURL!" changed to "!gitConfigURL!"
)
)
) else (
Echo Either Config.txt url was empty
)
:skipConfig
 
git pull %gitConfigRemoteName% %branchToPull%
 
 
if not %errorlevel% == 0(
Echo.
Echo Git ran into an Error when pulling.
Echo Have you committed your local changes?
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
Echo Resetting uncommited local changes ...
 
git reset --hard
git pull %gitConfigRemoteName% %branchToPull%
 
) else (
goto invalidNumberLength
)
) else (
:invalidNumberLength
Echo Aborting...
Echo.
Echo Press any key to exit.
Pause > nul
Exit
)
)
endlocal
@echo off
setlocal EnableDelayedExpansion
 
set "overwriteGitConfigData=true"
 
set "skipConfig=0"
REM 0==dont skip; 1==skip userConfig; >1==skip
 
 
where git >nul 2>nul && (
echo Git is installed.
) || (
start cmd.exe /k "color 4f & title Error & Echo. & Echo. & Echo Git is not properly installed! & Echo The installation will be canceled. If this is a mistake, remove the initial check from this batch file. & Echo Press any key to close this dialog & Pause > nul & Exit"
Echo Git environment variable wasnt found; Pulling will be canceled
Echo.
Echo Press any key to exit.
Pause > nul
Exit;
)
 
 
for /f i in ('git rev-parse --is-inside-work-tree 2^>^&1') do (
if /I "i"=="true" (
goto success
) else (
echo Current directory isn't a Git repository!
echo By continuing, Git will be set up here.
set /P "input=Press 'y' to continue and configure Git here; 'n' to abort this action: "
 
REM Check if the length of the input at 4th index is empty (3 chars or less) and if it starts with 'y'
set "choice=!input:~0,1!"
if /I "!choice!"=="y" (
if "!input:~3!"=="" (
echo Continuing...
echo Setting Git up in the current directory...
git init
) else (
goto wrongDirError
)
) else (
:wrongDirError
echo Aborting...
echo.
echo Press any key to exit.
pause > nul
exit
)
)
)
 
:success
Echo.
 
if ""=="" (
echo No branch name input provided. Pulling the 'main' branch.
set "branchToPull=main"
)
 
 
set "gitConfigRemoteName=%~2"
 
if "^"==^"" (
echo No input remote repo name provided. Setting to default 'origin'.
set "gitConfigRemoteName=origin"
)
rem Read configurations from the config.txt file
for /F "tokens=1,* delims== " G in (config.txt) do (
if "G"=="gitConfigUser" (
set "gitConfigUser=H"
if "!gitConfigUser!"=="" set "gitConfigUser="
)
if "G"=="gitConfigPassword" (
set "gitConfigPassword=H"
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
if "G"=="gitConfigURL" (
set "gitConfigURL=H"
if "!gitConfigURL!"=="" set "gitConfigURL="
)
)
rem Removing quotes from the config values
set "gitConfigUser=!gitConfigUser:"=!"
set "gitConfigPassword=!gitConfigPassword:"=!"
set "gitConfigURL=!gitConfigURL:"=!"
 
rem Check if the string is a space character and set it to an empty variable; space is always appended >:-( though git should deal with these strings correctly nevertheless
if "^"==^" " set "gitConfigUser="
if "^"==^" " set "gitConfigPassword="
if "^"==^" " set "gitConfigURL="
 
 
rem read current/already defined Git Config to see if theyre blank; not using --global flag!
for /F "delims=" i in ('git config user.name') do set currentGitConfigUser=i
for /F "delims=" i in ('git config user.password') do set currentGitConfigPassword=i
for /F "delims=" i in ('git config --get remote..url') do set currentGitConfigURL=i
 
if "!currentGitConfigUser!"==" " set "currentGitConfigUser="
if "!currentGitConfigPassword!"==" " set "currentGitConfigPassword="
if "!currentGitConfigURL!"==" " set "currentGitConfigURL="
 
if ==0 (
REM do nothing
goto dontSkip
) else if ==1 (
goto skipUserConfig
) else (
goto skipConfig
)
 
:dontSkip
 
REM set TAB="<TAB>"
set "TAB=   "
 
Echo Current User Name: "!currentGitConfigUser!"  Read User Name: "!gitConfigUser!"
Echo Current User PWD: "!currentGitConfigPassword!"  Read User PWD: "!gitConfigPassword!"
Echo.
Echo Pulling from Host with Name: "%gitConfigRemoteName%"
Echo Current URL under this Name: "!currentGitConfigURL!"  Read URL: "!gitConfigURL!"
 
Echo.
Echo.
 
if not "!gitConfigUser!"=="" (
if "!currentGitConfigUser!"=="" (
echo Current local Git Username is not set -> new Name: "!gitConfigUser!"
git config user.name "!gitConfigUser!"
)else (
echo Current local Git Username is already set; if the overwriteGitConfigData flag is true the current Username: "!currentGitConfigUser!" will be set to "!gitConfigUser!"
if "!overwriteGitConfigData!"=="true" (
git config user.name "!gitConfigUser!"&Echo Overwriting successful; Username "!currentGitConfigUser!" changed to "!gitConfigUser!"
REM git config --global --replace-all "!gitConfigUser!"
)
)
)
 
Echo.
Echo.
 
if not "!gitConfigPassword!"=="" (
if "!currentGitConfigPassword!"=="" (
echo Current local Git Password is not set -> new Password: "!gitConfigPassword!"
git config user.password "!gitConfigPassword!"
)else (
 
echo Current local Git Password is already set; if the overwriteGitConfigData flag is true the current Password: "!currentGitConfigPassword!" will be set to "!gitConfigPassword!"
if "!overwriteGitConfigData!"=="true" (
git config user.password "!gitConfigPassword!"&Echo Overwriting successful; Password "!currentGitConfigPassword!" changed to "!gitConfigPassword!"
REM git config --replace-all --global user.password "!gitConfigPassword!"
)
)
)
 
:skipUserConfig
Echo.
Echo.
 
if not "!gitConfigURL!"=="" (
echo get displayed
echo !gitConfigURL!
echo "!currentGitConfigURL!"
 
if "!currentGitConfigURL!"=="" (
echo Current local Git fetch URL is not set -> new URL: "!gitConfigURL!"
git remote add  "!gitConfigURL!"
) else (
echo Current local Git fetch URL is already set; if the overwriteGitConfigData flag is true the current URL: "!currentGitConfigURL!" will be set to "!gitConfigURL!"
if "!overwriteGitConfigData!"=="true" (
git remote add !gitConfigRemoteName! "!gitConfigURL!" & Echo Overwriting successful; URL "!currentGitConfigURL!" changed to "!gitConfigURL!"
)
)
) else (
Echo Either Config.txt url was empty
)
:skipConfig
 
git pull %gitConfigRemoteName% %branchToPull%
 
 
if not %errorlevel% == 0(
Echo.
Echo Git ran into an Error when pulling.
Echo Have you committed your local changes?
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
Echo Resetting uncommited local changes ...
 
git reset --hard
git pull %gitConfigRemoteName% %branchToPull%
 
) else (
goto invalidNumberLength
)
) else (
:invalidNumberLength
Echo Aborting...
Echo.
Echo Press any key to exit.
Pause > nul
Exit
)
)
endlocal
@echo off
setlocal EnableDelayedExpansion
 
set "overwriteGitConfigData=true"
 
set "skipConfig=0"
REM 0==dont skip; 1==skip userConfig; >1==skip
 
 
where git >nul 2>nul && (
echo Git is installed.
) || (
start cmd.exe /k "color 4f & title Error & Echo. & Echo. & Echo Git is not properly installed! & Echo The installation will be canceled. If this is a mistake, remove the initial check from this batch file. & Echo Press any key to close this dialog & Pause > nul & Exit"
Echo Git environment variable wasnt found; Pulling will be canceled
Echo.
Echo Press any key to exit.
Pause > nul
Exit;
)
 
 
for /f i in ('git rev-parse --is-inside-work-tree 2^>^&1') do (
if /I "i"=="true" (
goto success
) else (
echo Current directory isn't a Git repository!
echo By continuing, Git will be set up here.
set /P "input=Press 'y' to continue and configure Git here; 'n' to abort this action: "
 
REM Check if the length of the input at 4th index is empty (3 chars or less) and if it starts with 'y'
set "choice=!input:~0,1!"
if /I "!choice!"=="y" (
if "!input:~3!"=="" (
echo Continuing...
echo Setting Git up in the current directory...
git init
) else (
goto wrongDirError
)
) else (
:wrongDirError
echo Aborting...
echo.
echo Press any key to exit.
pause > nul
exit
)
)
)
 
:success
Echo.
 
if ""=="" (
echo No branch name input provided. Pulling the 'main' branch.
set "branchToPull=main"
)
 
 
set "gitConfigRemoteName=%~2"
 
if "^"==^"" (
echo No input remote repo name provided. Setting to default 'origin'.
set "gitConfigRemoteName=origin"
)
rem Read configurations from the config.txt file
for /F "tokens=1,* delims== " G in (config.txt) do (
if "G"=="gitConfigUser" (
set "gitConfigUser=H"
if "!gitConfigUser!"=="" set "gitConfigUser="
)
if "G"=="gitConfigPassword" (
set "gitConfigPassword=H"
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
if "G"=="gitConfigURL" (
set "gitConfigURL=H"
if "!gitConfigURL!"=="" set "gitConfigURL="
)
)
rem Removing quotes from the config values
set "gitConfigUser=!gitConfigUser:"=!"
set "gitConfigPassword=!gitConfigPassword:"=!"
set "gitConfigURL=!gitConfigURL:"=!"
 
rem Check if the string is a space character and set it to an empty variable; space is always appended >:-( though git should deal with these strings correctly nevertheless
if "^"==^" " set "gitConfigUser="
if "^"==^" " set "gitConfigPassword="
if "^"==^" " set "gitConfigURL="
 
 
rem read current/already defined Git Config to see if theyre blank; not using --global flag!
for /F "delims=" i in ('git config user.name') do set currentGitConfigUser=i
for /F "delims=" i in ('git config user.password') do set currentGitConfigPassword=i
for /F "delims=" i in ('git config --get remote..url') do set currentGitConfigURL=i
 
if "!currentGitConfigUser!"==" " set "currentGitConfigUser="
if "!currentGitConfigPassword!"==" " set "currentGitConfigPassword="
if "!currentGitConfigURL!"==" " set "currentGitConfigURL="
 
if ==0 (
REM do nothing
goto dontSkip
) else if ==1 (
goto skipUserConfig
) else (
goto skipConfig
)
 
:dontSkip
 
REM set TAB="<TAB>"
set "TAB=   "
 
Echo Current User Name: "!currentGitConfigUser!"  Read User Name: "!gitConfigUser!"
Echo Current User PWD: "!currentGitConfigPassword!"  Read User PWD: "!gitConfigPassword!"
Echo.
Echo Pulling from Host with Name: "%gitConfigRemoteName%"
Echo Current URL under this Name: "!currentGitConfigURL!"  Read URL: "!gitConfigURL!"
 
Echo.
Echo.
 
if not "!gitConfigUser!"=="" (
if "!currentGitConfigUser!"=="" (
echo Current local Git Username is not set -> new Name: "!gitConfigUser!"
git config user.name "!gitConfigUser!"
)else (
echo Current local Git Username is already set; if the overwriteGitConfigData flag is true the current Username: "!currentGitConfigUser!" will be set to "!gitConfigUser!"
if "!overwriteGitConfigData!"=="true" (
git config user.name "!gitConfigUser!"&Echo Overwriting successful; Username "!currentGitConfigUser!" changed to "!gitConfigUser!"
REM git config --global --replace-all "!gitConfigUser!"
)
)
)
 
Echo.
Echo.
 
if not "!gitConfigPassword!"=="" (
if "!currentGitConfigPassword!"=="" (
echo Current local Git Password is not set -> new Password: "!gitConfigPassword!"
git config user.password "!gitConfigPassword!"
)else (
 
echo Current local Git Password is already set; if the overwriteGitConfigData flag is true the current Password: "!currentGitConfigPassword!" will be set to "!gitConfigPassword!"
if "!overwriteGitConfigData!"=="true" (
git config user.password "!gitConfigPassword!"&Echo Overwriting successful; Password "!currentGitConfigPassword!" changed to "!gitConfigPassword!"
REM git config --replace-all --global user.password "!gitConfigPassword!"
)
)
)
 
:skipUserConfig
Echo.
Echo.
 
if not "!gitConfigURL!"=="" (
echo get displayed
echo !gitConfigURL!
echo "!currentGitConfigURL!"
 
if "!currentGitConfigURL!"=="" (
echo Current local Git fetch URL is not set -> new URL: "!gitConfigURL!"
git remote add  "!gitConfigURL!"
) else (
echo Current local Git fetch URL is already set; if the overwriteGitConfigData flag is true the current URL: "!currentGitConfigURL!" will be set to "!gitConfigURL!"
if "!overwriteGitConfigData!"=="true" (
git remote add !gitConfigRemoteName! "!gitConfigURL!" & Echo Overwriting successful; URL "!currentGitConfigURL!" changed to "!gitConfigURL!"
)
)
) else (
Echo Either Config.txt url was empty
)
:skipConfig
 
git pull %gitConfigRemoteName% %branchToPull%
 
 
if not %errorlevel% == 0(
Echo.
Echo Git ran into an Error when pulling.
Echo Have you committed your local changes?
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
Echo Resetting uncommited local changes ...
 
git reset --hard
git pull %gitConfigRemoteName% %branchToPull%
 
) else (
goto invalidNumberLength
)
) else (
:invalidNumberLength
Echo Aborting...
Echo.
Echo Press any key to exit.
Pause > nul
Exit
)
)
endlocal
@echo off
setlocal EnableDelayedExpansion
 
set "overwriteGitConfigData=true"
 
set "skipConfig=0"
REM 0==dont skip; 1==skip userConfig; >1==skip
 
 
where git >nul 2>nul && (
echo Git is installed.
) || (
start cmd.exe /k "color 4f & title Error & Echo. & Echo. & Echo Git is not properly installed! & Echo The installation will be canceled. If this is a mistake, remove the initial check from this batch file. & Echo Press any key to close this dialog & Pause > nul & Exit"
Echo Git environment variable wasnt found; Pulling will be canceled
Echo.
Echo Press any key to exit.
Pause > nul
Exit;
)
 
 
for /f i in ('git rev-parse --is-inside-work-tree 2^>^&1') do (
if /I "i"=="true" (
goto success
) else (
echo Current directory isn't a Git repository!
echo By continuing, Git will be set up here.
set /P "input=Press 'y' to continue and configure Git here; 'n' to abort this action: "
 
REM Check if the length of the input at 4th index is empty (3 chars or less) and if it starts with 'y'
set "choice=!input:~0,1!"
if /I "!choice!"=="y" (
if "!input:~3!"=="" (
echo Continuing...
echo Setting Git up in the current directory...
git init
) else (
goto wrongDirError
)
) else (
:wrongDirError
echo Aborting...
echo.
echo Press any key to exit.
pause > nul
exit
)
)
)
 
:success
Echo.
 
if ""=="" (
echo No branch name input provided. Pulling the 'main' branch.
set "branchToPull=main"
)
 
 
set "gitConfigRemoteName=%~2"
 
if "^"==^"" (
echo No input remote repo name provided. Setting to default 'origin'.
set "gitConfigRemoteName=origin"
)
rem Read configurations from the config.txt file
for /F "tokens=1,* delims== " G in (config.txt) do (
if "G"=="gitConfigUser" (
set "gitConfigUser=H"
if "!gitConfigUser!"=="" set "gitConfigUser="
)
if "G"=="gitConfigPassword" (
set "gitConfigPassword=H"
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
if "G"=="gitConfigURL" (
set "gitConfigURL=H"
if "!gitConfigURL!"=="" set "gitConfigURL="
)
)
rem Removing quotes from the config values
set "gitConfigUser=!gitConfigUser:"=!"
set "gitConfigPassword=!gitConfigPassword:"=!"
set "gitConfigURL=!gitConfigURL:"=!"
 
rem Check if the string is a space character and set it to an empty variable; space is always appended >:-( though git should deal with these strings correctly nevertheless
if "^"==^" " set "gitConfigUser="
if "^"==^" " set "gitConfigPassword="
if "^"==^" " set "gitConfigURL="
 
 
rem read current/already defined Git Config to see if theyre blank; not using --global flag!
for /F "delims=" i in ('git config user.name') do set currentGitConfigUser=i
for /F "delims=" i in ('git config user.password') do set currentGitConfigPassword=i
for /F "delims=" i in ('git config --get remote..url') do set currentGitConfigURL=i
 
if "!currentGitConfigUser!"==" " set "currentGitConfigUser="
if "!currentGitConfigPassword!"==" " set "currentGitConfigPassword="
if "!currentGitConfigURL!"==" " set "currentGitConfigURL="
 
if ==0 (
REM do nothing
goto dontSkip
) else if ==1 (
goto skipUserConfig
) else (
goto skipConfig
)
 
:dontSkip
 
REM set TAB="<TAB>"
set "TAB=   "
 
Echo Current User Name: "!currentGitConfigUser!"  Read User Name: "!gitConfigUser!"
Echo Current User PWD: "!currentGitConfigPassword!"  Read User PWD: "!gitConfigPassword!"
Echo.
Echo Pulling from Host with Name: "%gitConfigRemoteName%"
Echo Current URL under this Name: "!currentGitConfigURL!"  Read URL: "!gitConfigURL!"
 
Echo.
Echo.
 
if not "!gitConfigUser!"=="" (
if "!currentGitConfigUser!"=="" (
echo Current local Git Username is not set -> new Name: "!gitConfigUser!"
git config user.name "!gitConfigUser!"
)else (
echo Current local Git Username is already set; if the overwriteGitConfigData flag is true the current Username: "!currentGitConfigUser!" will be set to "!gitConfigUser!"
if "!overwriteGitConfigData!"=="true" (
git config user.name "!gitConfigUser!"&Echo Overwriting successful; Username "!currentGitConfigUser!" changed to "!gitConfigUser!"
REM git config --global --replace-all "!gitConfigUser!"
)
)
)
 
Echo.
Echo.
 
if not "!gitConfigPassword!"=="" (
if "!currentGitConfigPassword!"=="" (
echo Current local Git Password is not set -> new Password: "!gitConfigPassword!"
git config user.password "!gitConfigPassword!"
)else (
 
echo Current local Git Password is already set; if the overwriteGitConfigData flag is true the current Password: "!currentGitConfigPassword!" will be set to "!gitConfigPassword!"
if "!overwriteGitConfigData!"=="true" (
git config user.password "!gitConfigPassword!"&Echo Overwriting successful; Password "!currentGitConfigPassword!" changed to "!gitConfigPassword!"
REM git config --replace-all --global user.password "!gitConfigPassword!"
)
)
)
 
:skipUserConfig
Echo.
Echo.
 
if not "!gitConfigURL!"=="" (
echo get displayed
echo !gitConfigURL!
echo "!currentGitConfigURL!"
 
if "!currentGitConfigURL!"=="" (
echo Current local Git fetch URL is not set -> new URL: "!gitConfigURL!"
git remote add  "!gitConfigURL!"
) else (
echo Current local Git fetch URL is already set; if the overwriteGitConfigData flag is true the current URL: "!currentGitConfigURL!" will be set to "!gitConfigURL!"
if "!overwriteGitConfigData!"=="true" (
git remote add !gitConfigRemoteName! "!gitConfigURL!" & Echo Overwriting successful; URL "!currentGitConfigURL!" changed to "!gitConfigURL!"
)
)
) else (
Echo Either Config.txt url was empty
)
:skipConfig
 
git pull %gitConfigRemoteName% %branchToPull%
 
 
if not %errorlevel% == 0(
Echo.
Echo Git ran into an Error when pulling.
Echo Have you committed your local changes?
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
Echo Resetting uncommited local changes ...
 
git reset --hard
git pull %gitConfigRemoteName% %branchToPull%
 
) else (
goto invalidNumberLength
)
) else (
:invalidNumberLength
Echo Aborting...
Echo.
Echo Press any key to exit.
Pause > nul
Exit
)
)
endlocal
@echo off
setlocal EnableDelayedExpansion
 
set "overwriteGitConfigData=true"
 
set "skipConfig=0"
REM 0==dont skip; 1==skip userConfig; >1==skip
 
 
where git >nul 2>nul && (
echo Git is installed.
) || (
start cmd.exe /k "color 4f & title Error & Echo. & Echo. & Echo Git is not properly installed! & Echo The installation will be canceled. If this is a mistake, remove the initial check from this batch file. & Echo Press any key to close this dialog & Pause > nul & Exit"
Echo Git environment variable wasnt found; Pulling will be canceled
Echo.
Echo Press any key to exit.
Pause > nul
Exit;
)
 
 
for /f i in ('git rev-parse --is-inside-work-tree 2^>^&1') do (
if /I "i"=="true" (
goto success
) else (
echo Current directory isn't a Git repository!
echo By continuing, Git will be set up here.
set /P "input=Press 'y' to continue and configure Git here; 'n' to abort this action: "
 
REM Check if the length of the input at 4th index is empty (3 chars or less) and if it starts with 'y'
set "choice=!input:~0,1!"
if /I "!choice!"=="y" (
if "!input:~3!"=="" (
echo Continuing...
echo Setting Git up in the current directory...
git init
) else (
goto wrongDirError
)
) else (
:wrongDirError
echo Aborting...
echo.
echo Press any key to exit.
pause > nul
exit
)
)
)
 
:success
Echo.
 
if ""=="" (
echo No branch name input provided. Pulling the 'main' branch.
set "branchToPull=main"
)
 
 
set "gitConfigRemoteName=%~2"
 
if "^"==^"" (
echo No input remote repo name provided. Setting to default 'origin'.
set "gitConfigRemoteName=origin"
)
rem Read configurations from the config.txt file
for /F "tokens=1,* delims== " G in (config.txt) do (
if "G"=="gitConfigUser" (
set "gitConfigUser=H"
if "!gitConfigUser!"=="" set "gitConfigUser="
)
if "G"=="gitConfigPassword" (
set "gitConfigPassword=H"
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
if "G"=="gitConfigURL" (
set "gitConfigURL=H"
if "!gitConfigURL!"=="" set "gitConfigURL="
)
)
rem Removing quotes from the config values
set "gitConfigUser=!gitConfigUser:"=!"
set "gitConfigPassword=!gitConfigPassword:"=!"
set "gitConfigURL=!gitConfigURL:"=!"
 
rem Check if the string is a space character and set it to an empty variable; space is always appended >:-( though git should deal with these strings correctly nevertheless
if "^"==^" " set "gitConfigUser="
if "^"==^" " set "gitConfigPassword="
if "^"==^" " set "gitConfigURL="
 
 
rem read current/already defined Git Config to see if theyre blank; not using --global flag!
for /F "delims=" i in ('git config user.name') do set currentGitConfigUser=i
for /F "delims=" i in ('git config user.password') do set currentGitConfigPassword=i
for /F "delims=" i in ('git config --get remote..url') do set currentGitConfigURL=i
 
if "!currentGitConfigUser!"==" " set "currentGitConfigUser="
if "!currentGitConfigPassword!"==" " set "currentGitConfigPassword="
if "!currentGitConfigURL!"==" " set "currentGitConfigURL="
 
if ==0 (
REM do nothing
goto dontSkip
) else if ==1 (
goto skipUserConfig
) else (
goto skipConfig
)
 
:dontSkip
 
REM set TAB="<TAB>"
set "TAB=   "
 
Echo Current User Name: "!currentGitConfigUser!"  Read User Name: "!gitConfigUser!"
Echo Current User PWD: "!currentGitConfigPassword!"  Read User PWD: "!gitConfigPassword!"
Echo.
Echo Pulling from Host with Name: "%gitConfigRemoteName%"
Echo Current URL under this Name: "!currentGitConfigURL!"  Read URL: "!gitConfigURL!"
 
Echo.
Echo.
 
if not "!gitConfigUser!"=="" (
if "!currentGitConfigUser!"=="" (
echo Current local Git Username is not set -> new Name: "!gitConfigUser!"
git config user.name "!gitConfigUser!"
)else (
echo Current local Git Username is already set; if the overwriteGitConfigData flag is true the current Username: "!currentGitConfigUser!" will be set to "!gitConfigUser!"
if "!overwriteGitConfigData!"=="true" (
git config user.name "!gitConfigUser!"&Echo Overwriting successful; Username "!currentGitConfigUser!" changed to "!gitConfigUser!"
REM git config --global --replace-all "!gitConfigUser!"
)
)
)
 
Echo.
Echo.
 
if not "!gitConfigPassword!"=="" (
if "!currentGitConfigPassword!"=="" (
echo Current local Git Password is not set -> new Password: "!gitConfigPassword!"
git config user.password "!gitConfigPassword!"
)else (
 
echo Current local Git Password is already set; if the overwriteGitConfigData flag is true the current Password: "!currentGitConfigPassword!" will be set to "!gitConfigPassword!"
if "!overwriteGitConfigData!"=="true" (
git config user.password "!gitConfigPassword!"&Echo Overwriting successful; Password "!currentGitConfigPassword!" changed to "!gitConfigPassword!"
REM git config --replace-all --global user.password "!gitConfigPassword!"
)
)
)
 
:skipUserConfig
Echo.
Echo.
 
if not "!gitConfigURL!"=="" (
echo get displayed
echo !gitConfigURL!
echo "!currentGitConfigURL!"
 
if "!currentGitConfigURL!"=="" (
echo Current local Git fetch URL is not set -> new URL: "!gitConfigURL!"
git remote add  "!gitConfigURL!"
) else (
echo Current local Git fetch URL is already set; if the overwriteGitConfigData flag is true the current URL: "!currentGitConfigURL!" will be set to "!gitConfigURL!"
if "!overwriteGitConfigData!"=="true" (
git remote add !gitConfigRemoteName! "!gitConfigURL!" & Echo Overwriting successful; URL "!currentGitConfigURL!" changed to "!gitConfigURL!"
)
)
) else (
Echo Either Config.txt url was empty
)
:skipConfig
 
git pull %gitConfigRemoteName% %branchToPull%
 
 
if not %errorlevel% == 0(
Echo.
Echo Git ran into an Error when pulling.
Echo Have you committed your local changes?
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
Echo Resetting uncommited local changes ...
 
git reset --hard
git pull %gitConfigRemoteName% %branchToPull%
 
) else (
goto invalidNumberLength
)
) else (
:invalidNumberLength
Echo Aborting...
Echo.
Echo Press any key to exit.
Pause > nul
Exit
)
)
endlocal
@echo off
setlocal EnableDelayedExpansion
 
set "overwriteGitConfigData=true"
 
set "skipConfig=0"
REM 0==dont skip; 1==skip userConfig; >1==skip
 
 
where git >nul 2>nul && (
echo Git is installed.
) || (
start cmd.exe /k "color 4f & title Error & Echo. & Echo. & Echo Git is not properly installed! & Echo The installation will be canceled. If this is a mistake, remove the initial check from this batch file. & Echo Press any key to close this dialog & Pause > nul & Exit"
Echo Git environment variable wasnt found; Pulling will be canceled
Echo.
Echo Press any key to exit.
Pause > nul
Exit;
)
 
 
for /f i in ('git rev-parse --is-inside-work-tree 2^>^&1') do (
if /I "i"=="true" (
goto success
) else (
echo Current directory isn't a Git repository!
echo By continuing, Git will be set up here.
set /P "input=Press 'y' to continue and configure Git here; 'n' to abort this action: "
 
REM Check if the length of the input at 4th index is empty (3 chars or less) and if it starts with 'y'
set "choice=!input:~0,1!"
if /I "!choice!"=="y" (
if "!input:~3!"=="" (
echo Continuing...
echo Setting Git up in the current directory...
git init
) else (
goto wrongDirError
)
) else (
:wrongDirError
echo Aborting...
echo.
echo Press any key to exit.
pause > nul
exit
)
)
)
 
:success
Echo.
 
if ""=="" (
echo No branch name input provided. Pulling the 'main' branch.
set "branchToPull=main"
)
 
 
set "gitConfigRemoteName=%~2"
 
if "^"==^"" (
echo No input remote repo name provided. Setting to default 'origin'.
set "gitConfigRemoteName=origin"
)
rem Read configurations from the config.txt file
for /F "tokens=1,* delims== " G in (config.txt) do (
if "G"=="gitConfigUser" (
set "gitConfigUser=H"
if "!gitConfigUser!"=="" set "gitConfigUser="
)
if "G"=="gitConfigPassword" (
set "gitConfigPassword=H"
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
if "G"=="gitConfigURL" (
set "gitConfigURL=H"
if "!gitConfigURL!"=="" set "gitConfigURL="
)
)
rem Removing quotes from the config values
set "gitConfigUser=!gitConfigUser:"=!"
set "gitConfigPassword=!gitConfigPassword:"=!"
set "gitConfigURL=!gitConfigURL:"=!"
 
rem Check if the string is a space character and set it to an empty variable; space is always appended >:-( though git should deal with these strings correctly nevertheless
if "^"==^" " set "gitConfigUser="
if "^"==^" " set "gitConfigPassword="
if "^"==^" " set "gitConfigURL="
 
 
rem read current/already defined Git Config to see if theyre blank; not using --global flag!
for /F "delims=" i in ('git config user.name') do set currentGitConfigUser=i
for /F "delims=" i in ('git config user.password') do set currentGitConfigPassword=i
for /F "delims=" i in ('git config --get remote..url') do set currentGitConfigURL=i
 
if "!currentGitConfigUser!"==" " set "currentGitConfigUser="
if "!currentGitConfigPassword!"==" " set "currentGitConfigPassword="
if "!currentGitConfigURL!"==" " set "currentGitConfigURL="
 
if ==0 (
REM do nothing
goto dontSkip
) else if ==1 (
goto skipUserConfig
) else (
goto skipConfig
)
 
:dontSkip
 
REM set TAB="<TAB>"
set "TAB=   "
 
Echo Current User Name: "!currentGitConfigUser!"  Read User Name: "!gitConfigUser!"
Echo Current User PWD: "!currentGitConfigPassword!"  Read User PWD: "!gitConfigPassword!"
Echo.
Echo Pulling from Host with Name: "%gitConfigRemoteName%"
Echo Current URL under this Name: "!currentGitConfigURL!"  Read URL: "!gitConfigURL!"
 
Echo.
Echo.
 
if not "!gitConfigUser!"=="" (
if "!currentGitConfigUser!"=="" (
echo Current local Git Username is not set -> new Name: "!gitConfigUser!"
git config user.name "!gitConfigUser!"
)else (
echo Current local Git Username is already set; if the overwriteGitConfigData flag is true the current Username: "!currentGitConfigUser!" will be set to "!gitConfigUser!"
if "!overwriteGitConfigData!"=="true" (
git config user.name "!gitConfigUser!"&Echo Overwriting successful; Username "!currentGitConfigUser!" changed to "!gitConfigUser!"
REM git config --global --replace-all "!gitConfigUser!"
)
)
)
 
Echo.
Echo.
 
if not "!gitConfigPassword!"=="" (
if "!currentGitConfigPassword!"=="" (
echo Current local Git Password is not set -> new Password: "!gitConfigPassword!"
git config user.password "!gitConfigPassword!"
)else (
 
echo Current local Git Password is already set; if the overwriteGitConfigData flag is true the current Password: "!currentGitConfigPassword!" will be set to "!gitConfigPassword!"
if "!overwriteGitConfigData!"=="true" (
git config user.password "!gitConfigPassword!"&Echo Overwriting successful; Password "!currentGitConfigPassword!" changed to "!gitConfigPassword!"
REM git config --replace-all --global user.password "!gitConfigPassword!"
)
)
)
 
:skipUserConfig
Echo.
Echo.
 
if not "!gitConfigURL!"=="" (
echo get displayed
echo !gitConfigURL!
echo "!currentGitConfigURL!"
 
if "!currentGitConfigURL!"=="" (
echo Current local Git fetch URL is not set -> new URL: "!gitConfigURL!"
git remote add  "!gitConfigURL!"
) else (
echo Current local Git fetch URL is already set; if the overwriteGitConfigData flag is true the current URL: "!currentGitConfigURL!" will be set to "!gitConfigURL!"
if "!overwriteGitConfigData!"=="true" (
git remote add !gitConfigRemoteName! "!gitConfigURL!" & Echo Overwriting successful; URL "!currentGitConfigURL!" changed to "!gitConfigURL!"
)
)
) else (
Echo Either Config.txt url was empty
)
:skipConfig
 
git pull %gitConfigRemoteName% %branchToPull%
 
 
if not %errorlevel% == 0(
Echo.
Echo Git ran into an Error when pulling.
Echo Have you committed your local changes?
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
Echo Resetting uncommited local changes ...
 
git reset --hard
git pull %gitConfigRemoteName% %branchToPull%
 
) else (
goto invalidNumberLength
)
) else (
:invalidNumberLength
Echo Aborting...
Echo.
Echo Press any key to exit.
Pause > nul
Exit
)
)
endlocal
@echo off
setlocal EnableDelayedExpansion
 
set "overwriteGitConfigData=true"
 
set "skipConfig=0"
REM 0==dont skip; 1==skip userConfig; >1==skip
 
 
where git >nul 2>nul && (
echo Git is installed.
) || (
start cmd.exe /k "color 4f & title Error & Echo. & Echo. & Echo Git is not properly installed! & Echo The installation will be canceled. If this is a mistake, remove the initial check from this batch file. & Echo Press any key to close this dialog & Pause > nul & Exit"
Echo Git environment variable wasnt found; Pulling will be canceled
Echo.
Echo Press any key to exit.
Pause > nul
Exit;
)
 
 
for /f i in ('git rev-parse --is-inside-work-tree 2^>^&1') do (
if /I "i"=="true" (
goto success
) else (
echo Current directory isn't a Git repository!
echo By continuing, Git will be set up here.
set /P "input=Press 'y' to continue and configure Git here; 'n' to abort this action: "
 
REM Check if the length of the input at 4th index is empty (3 chars or less) and if it starts with 'y'
set "choice=!input:~0,1!"
if /I "!choice!"=="y" (
if "!input:~3!"=="" (
echo Continuing...
echo Setting Git up in the current directory...
git init
) else (
goto wrongDirError
)
) else (
:wrongDirError
echo Aborting...
echo.
echo Press any key to exit.
pause > nul
exit
)
)
)
 
:success
Echo.
 
if ""=="" (
echo No branch name input provided. Pulling the 'main' branch.
set "branchToPull=main"
)
 
 
set "gitConfigRemoteName=%~2"
 
if "^"==^"" (
echo No input remote repo name provided. Setting to default 'origin'.
set "gitConfigRemoteName=origin"
)
rem Read configurations from the config.txt file
for /F "tokens=1,* delims== " G in (config.txt) do (
if "G"=="gitConfigUser" (
set "gitConfigUser=H"
if "!gitConfigUser!"=="" set "gitConfigUser="
)
if "G"=="gitConfigPassword" (
set "gitConfigPassword=H"
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
if "G"=="gitConfigURL" (
set "gitConfigURL=H"
if "!gitConfigURL!"=="" set "gitConfigURL="
)
)
rem Removing quotes from the config values
set "gitConfigUser=!gitConfigUser:"=!"
set "gitConfigPassword=!gitConfigPassword:"=!"
set "gitConfigURL=!gitConfigURL:"=!"
 
rem Check if the string is a space character and set it to an empty variable; space is always appended >:-( though git should deal with these strings correctly nevertheless
if "^"==^" " set "gitConfigUser="
if "^"==^" " set "gitConfigPassword="
if "^"==^" " set "gitConfigURL="
 
 
rem read current/already defined Git Config to see if theyre blank; not using --global flag!
for /F "delims=" i in ('git config user.name') do set currentGitConfigUser=i
for /F "delims=" i in ('git config user.password') do set currentGitConfigPassword=i
for /F "delims=" i in ('git config --get remote..url') do set currentGitConfigURL=i
 
if "!currentGitConfigUser!"==" " set "currentGitConfigUser="
if "!currentGitConfigPassword!"==" " set "currentGitConfigPassword="
if "!currentGitConfigURL!"==" " set "currentGitConfigURL="
 
if ==0 (
REM do nothing
goto dontSkip
) else if ==1 (
goto skipUserConfig
) else (
goto skipConfig
)
 
:dontSkip
 
REM set TAB="<TAB>"
set "TAB=   "
 
Echo Current User Name: "!currentGitConfigUser!"  Read User Name: "!gitConfigUser!"
Echo Current User PWD: "!currentGitConfigPassword!"  Read User PWD: "!gitConfigPassword!"
Echo.
Echo Pulling from Host with Name: "%gitConfigRemoteName%"
Echo Current URL under this Name: "!currentGitConfigURL!"  Read URL: "!gitConfigURL!"
 
Echo.
Echo.
 
if not "!gitConfigUser!"=="" (
if "!currentGitConfigUser!"=="" (
echo Current local Git Username is not set -> new Name: "!gitConfigUser!"
git config user.name "!gitConfigUser!"
)else (
echo Current local Git Username is already set; if the overwriteGitConfigData flag is true the current Username: "!currentGitConfigUser!" will be set to "!gitConfigUser!"
if "!overwriteGitConfigData!"=="true" (
git config user.name "!gitConfigUser!"&Echo Overwriting successful; Username "!currentGitConfigUser!" changed to "!gitConfigUser!"
REM git config --global --replace-all "!gitConfigUser!"
)
)
)
 
Echo.
Echo.
 
if not "!gitConfigPassword!"=="" (
if "!currentGitConfigPassword!"=="" (
echo Current local Git Password is not set -> new Password: "!gitConfigPassword!"
git config user.password "!gitConfigPassword!"
)else (
 
echo Current local Git Password is already set; if the overwriteGitConfigData flag is true the current Password: "!currentGitConfigPassword!" will be set to "!gitConfigPassword!"
if "!overwriteGitConfigData!"=="true" (
git config user.password "!gitConfigPassword!"&Echo Overwriting successful; Password "!currentGitConfigPassword!" changed to "!gitConfigPassword!"
REM git config --replace-all --global user.password "!gitConfigPassword!"
)
)
)
 
:skipUserConfig
Echo.
Echo.
 
if not "!gitConfigURL!"=="" (
echo get displayed
echo !gitConfigURL!
echo "!currentGitConfigURL!"
 
if "!currentGitConfigURL!"=="" (
echo Current local Git fetch URL is not set -> new URL: "!gitConfigURL!"
git remote add  "!gitConfigURL!"
) else (
echo Current local Git fetch URL is already set; if the overwriteGitConfigData flag is true the current URL: "!currentGitConfigURL!" will be set to "!gitConfigURL!"
if "!overwriteGitConfigData!"=="true" (
git remote add !gitConfigRemoteName! "!gitConfigURL!" & Echo Overwriting successful; URL "!currentGitConfigURL!" changed to "!gitConfigURL!"
)
)
) else (
Echo Either Config.txt url was empty
)
:skipConfig
 
git pull %gitConfigRemoteName% %branchToPull%
 
 
if not %errorlevel% == 0(
Echo.
Echo Git ran into an Error when pulling.
Echo Have you committed your local changes?
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
Echo Resetting uncommited local changes ...
 
git reset --hard
git pull %gitConfigRemoteName% %branchToPull%
 
) else (
goto invalidNumberLength
)
) else (
:invalidNumberLength
Echo Aborting...
Echo.
Echo Press any key to exit.
Pause > nul
Exit
)
)
endlocal
@echo off
setlocal EnableDelayedExpansion
 
set "overwriteGitConfigData=true"
 
set "skipConfig=0"
REM 0==dont skip; 1==skip userConfig; >1==skip
 
 
where git >nul 2>nul && (
echo Git is installed.
) || (
start cmd.exe /k "color 4f & title Error & Echo. & Echo. & Echo Git is not properly installed! & Echo The installation will be canceled. If this is a mistake, remove the initial check from this batch file. & Echo Press any key to close this dialog & Pause > nul & Exit"
Echo Git environment variable wasnt found; Pulling will be canceled
Echo.
Echo Press any key to exit.
Pause > nul
Exit;
)
 
 
for /f i in ('git rev-parse --is-inside-work-tree 2^>^&1') do (
if /I "i"=="true" (
goto success
) else (
echo Current directory isn't a Git repository!
echo By continuing, Git will be set up here.
set /P "input=Press 'y' to continue and configure Git here; 'n' to abort this action: "
 
REM Check if the length of the input at 4th index is empty (3 chars or less) and if it starts with 'y'
set "choice=!input:~0,1!"
if /I "!choice!"=="y" (
if "!input:~3!"=="" (
echo Continuing...
echo Setting Git up in the current directory...
git init
) else (
goto wrongDirError
)
) else (
:wrongDirError
echo Aborting...
echo.
echo Press any key to exit.
pause > nul
exit
)
)
)
 
:success
Echo.
 
if ""=="" (
echo No branch name input provided. Pulling the 'main' branch.
set "branchToPull=main"
)
 
 
set "gitConfigRemoteName=%~2"
 
if "^"==^"" (
echo No input remote repo name provided. Setting to default 'origin'.
set "gitConfigRemoteName=origin"
)
rem Read configurations from the config.txt file
for /F "tokens=1,* delims== " G in (config.txt) do (
if "G"=="gitConfigUser" (
set "gitConfigUser=H"
if "!gitConfigUser!"=="" set "gitConfigUser="
)
if "G"=="gitConfigPassword" (
set "gitConfigPassword=H"
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
if "G"=="gitConfigURL" (
set "gitConfigURL=H"
if "!gitConfigURL!"=="" set "gitConfigURL="
)
)
rem Removing quotes from the config values
set "gitConfigUser=!gitConfigUser:"=!"
set "gitConfigPassword=!gitConfigPassword:"=!"
set "gitConfigURL=!gitConfigURL:"=!"
 
rem Check if the string is a space character and set it to an empty variable; space is always appended >:-( though git should deal with these strings correctly nevertheless
if "^"==^" " set "gitConfigUser="
if "^"==^" " set "gitConfigPassword="
if "^"==^" " set "gitConfigURL="
 
 
rem read current/already defined Git Config to see if theyre blank; not using --global flag!
for /F "delims=" i in ('git config user.name') do set currentGitConfigUser=i
for /F "delims=" i in ('git config user.password') do set currentGitConfigPassword=i
for /F "delims=" i in ('git config --get remote..url') do set currentGitConfigURL=i
 
if "!currentGitConfigUser!"==" " set "currentGitConfigUser="
if "!currentGitConfigPassword!"==" " set "currentGitConfigPassword="
if "!currentGitConfigURL!"==" " set "currentGitConfigURL="
 
if ==0 (
REM do nothing
goto dontSkip
) else if ==1 (
goto skipUserConfig
) else (
goto skipConfig
)
 
:dontSkip
 
REM set TAB="<TAB>"
set "TAB=   "
 
Echo Current User Name: "!currentGitConfigUser!"  Read User Name: "!gitConfigUser!"
Echo Current User PWD: "!currentGitConfigPassword!"  Read User PWD: "!gitConfigPassword!"
Echo.
Echo Pulling from Host with Name: "%gitConfigRemoteName%"
Echo Current URL under this Name: "!currentGitConfigURL!"  Read URL: "!gitConfigURL!"
 
Echo.
Echo.
 
if not "!gitConfigUser!"=="" (
if "!currentGitConfigUser!"=="" (
echo Current local Git Username is not set -> new Name: "!gitConfigUser!"
git config user.name "!gitConfigUser!"
)else (
echo Current local Git Username is already set; if the overwriteGitConfigData flag is true the current Username: "!currentGitConfigUser!" will be set to "!gitConfigUser!"
if "!overwriteGitConfigData!"=="true" (
git config user.name "!gitConfigUser!"&Echo Overwriting successful; Username "!currentGitConfigUser!" changed to "!gitConfigUser!"
REM git config --global --replace-all "!gitConfigUser!"
)
)
)
 
Echo.
Echo.
 
if not "!gitConfigPassword!"=="" (
if "!currentGitConfigPassword!"=="" (
echo Current local Git Password is not set -> new Password: "!gitConfigPassword!"
git config user.password "!gitConfigPassword!"
)else (
 
echo Current local Git Password is already set; if the overwriteGitConfigData flag is true the current Password: "!currentGitConfigPassword!" will be set to "!gitConfigPassword!"
if "!overwriteGitConfigData!"=="true" (
git config user.password "!gitConfigPassword!"&Echo Overwriting successful; Password "!currentGitConfigPassword!" changed to "!gitConfigPassword!"
REM git config --replace-all --global user.password "!gitConfigPassword!"
)
)
)
 
:skipUserConfig
Echo.
Echo.
 
if not "!gitConfigURL!"=="" (
echo get displayed
echo !gitConfigURL!
echo "!currentGitConfigURL!"
 
if "!currentGitConfigURL!"=="" (
echo Current local Git fetch URL is not set -> new URL: "!gitConfigURL!"
git remote add  "!gitConfigURL!"
) else (
echo Current local Git fetch URL is already set; if the overwriteGitConfigData flag is true the current URL: "!currentGitConfigURL!" will be set to "!gitConfigURL!"
if "!overwriteGitConfigData!"=="true" (
git remote add !gitConfigRemoteName! "!gitConfigURL!" & Echo Overwriting successful; URL "!currentGitConfigURL!" changed to "!gitConfigURL!"
)
)
) else (
Echo Either Config.txt url was empty
)
:skipConfig
 
git pull %gitConfigRemoteName% %branchToPull%
 
 
if not %errorlevel% == 0(
Echo.
Echo Git ran into an Error when pulling.
Echo Have you committed your local changes?
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
Echo Resetting uncommited local changes ...
 
git reset --hard
git pull %gitConfigRemoteName% %branchToPull%
 
) else (
goto invalidNumberLength
)
) else (
:invalidNumberLength
Echo Aborting...
Echo.
Echo Press any key to exit.
Pause > nul
Exit
)
)
endlocal
@echo off
setlocal EnableDelayedExpansion
 
set "overwriteGitConfigData=true"
 
set "skipConfig=0"
REM 0==dont skip; 1==skip userConfig; >1==skip
 
 
where git >nul 2>nul && (
echo Git is installed.
) || (
start cmd.exe /k "color 4f & title Error & Echo. & Echo. & Echo Git is not properly installed! & Echo The installation will be canceled. If this is a mistake, remove the initial check from this batch file. & Echo Press any key to close this dialog & Pause > nul & Exit"
Echo Git environment variable wasnt found; Pulling will be canceled
Echo.
Echo Press any key to exit.
Pause > nul
Exit;
)
 
 
for /f i in ('git rev-parse --is-inside-work-tree 2^>^&1') do (
if /I "i"=="true" (
goto success
) else (
echo Current directory isn't a Git repository!
echo By continuing, Git will be set up here.
set /P "input=Press 'y' to continue and configure Git here; 'n' to abort this action: "
 
REM Check if the length of the input at 4th index is empty (3 chars or less) and if it starts with 'y'
set "choice=!input:~0,1!"
if /I "!choice!"=="y" (
if "!input:~3!"=="" (
echo Continuing...
echo Setting Git up in the current directory...
git init
) else (
goto wrongDirError
)
) else (
:wrongDirError
echo Aborting...
echo.
echo Press any key to exit.
pause > nul
exit
)
)
)
 
:success
Echo.
 
if ""=="" (
echo No branch name input provided. Pulling the 'main' branch.
set "branchToPull=main"
)
 
 
set "gitConfigRemoteName=%~2"
 
if "^"==^"" (
echo No input remote repo name provided. Setting to default 'origin'.
set "gitConfigRemoteName=origin"
)
rem Read configurations from the config.txt file
for /F "tokens=1,* delims== " G in (config.txt) do (
if "G"=="gitConfigUser" (
set "gitConfigUser=H"
if "!gitConfigUser!"=="" set "gitConfigUser="
)
if "G"=="gitConfigPassword" (
set "gitConfigPassword=H"
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
if "G"=="gitConfigURL" (
set "gitConfigURL=H"
if "!gitConfigURL!"=="" set "gitConfigURL="
)
)
rem Removing quotes from the config values
set "gitConfigUser=!gitConfigUser:"=!"
set "gitConfigPassword=!gitConfigPassword:"=!"
set "gitConfigURL=!gitConfigURL:"=!"
 
rem Check if the string is a space character and set it to an empty variable; space is always appended >:-( though git should deal with these strings correctly nevertheless
if "^"==^" " set "gitConfigUser="
if "^"==^" " set "gitConfigPassword="
if "^"==^" " set "gitConfigURL="
 
 
rem read current/already defined Git Config to see if theyre blank; not using --global flag!
for /F "delims=" i in ('git config user.name') do set currentGitConfigUser=i
for /F "delims=" i in ('git config user.password') do set currentGitConfigPassword=i
for /F "delims=" i in ('git config --get remote..url') do set currentGitConfigURL=i
 
if "!currentGitConfigUser!"==" " set "currentGitConfigUser="
if "!currentGitConfigPassword!"==" " set "currentGitConfigPassword="
if "!currentGitConfigURL!"==" " set "currentGitConfigURL="
 
if ==0 (
REM do nothing
goto dontSkip
) else if ==1 (
goto skipUserConfig
) else (
goto skipConfig
)
 
:dontSkip
 
REM set TAB="<TAB>"
set "TAB=   "
 
Echo Current User Name: "!currentGitConfigUser!"  Read User Name: "!gitConfigUser!"
Echo Current User PWD: "!currentGitConfigPassword!"  Read User PWD: "!gitConfigPassword!"
Echo.
Echo Pulling from Host with Name: "%gitConfigRemoteName%"
Echo Current URL under this Name: "!currentGitConfigURL!"  Read URL: "!gitConfigURL!"
 
Echo.
Echo.
 
if not "!gitConfigUser!"=="" (
if "!currentGitConfigUser!"=="" (
echo Current local Git Username is not set -> new Name: "!gitConfigUser!"
git config user.name "!gitConfigUser!"
)else (
echo Current local Git Username is already set; if the overwriteGitConfigData flag is true the current Username: "!currentGitConfigUser!" will be set to "!gitConfigUser!"
if "!overwriteGitConfigData!"=="true" (
git config user.name "!gitConfigUser!"&Echo Overwriting successful; Username "!currentGitConfigUser!" changed to "!gitConfigUser!"
REM git config --global --replace-all "!gitConfigUser!"
)
)
)
 
Echo.
Echo.
 
if not "!gitConfigPassword!"=="" (
if "!currentGitConfigPassword!"=="" (
echo Current local Git Password is not set -> new Password: "!gitConfigPassword!"
git config user.password "!gitConfigPassword!"
)else (
 
echo Current local Git Password is already set; if the overwriteGitConfigData flag is true the current Password: "!currentGitConfigPassword!" will be set to "!gitConfigPassword!"
if "!overwriteGitConfigData!"=="true" (
git config user.password "!gitConfigPassword!"&Echo Overwriting successful; Password "!currentGitConfigPassword!" changed to "!gitConfigPassword!"
REM git config --replace-all --global user.password "!gitConfigPassword!"
)
)
)
 
:skipUserConfig
Echo.
Echo.
 
if not "!gitConfigURL!"=="" (
echo get displayed
echo !gitConfigURL!
echo "!currentGitConfigURL!"
 
if "!currentGitConfigURL!"=="" (
echo Current local Git fetch URL is not set -> new URL: "!gitConfigURL!"
git remote add  "!gitConfigURL!"
) else (
echo Current local Git fetch URL is already set; if the overwriteGitConfigData flag is true the current URL: "!currentGitConfigURL!" will be set to "!gitConfigURL!"
if "!overwriteGitConfigData!"=="true" (
git remote add !gitConfigRemoteName! "!gitConfigURL!" & Echo Overwriting successful; URL "!currentGitConfigURL!" changed to "!gitConfigURL!"
)
)
) else (
Echo Either Config.txt url was empty
)
:skipConfig
 
git pull %gitConfigRemoteName% %branchToPull%
 
 
if not %errorlevel% == 0(
Echo.
Echo Git ran into an Error when pulling.
Echo Have you committed your local changes?
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
Echo Resetting uncommited local changes ...
 
git reset --hard
git pull %gitConfigRemoteName% %branchToPull%
 
) else (
goto invalidNumberLength
)
) else (
:invalidNumberLength
Echo Aborting...
Echo.
Echo Press any key to exit.
Pause > nul
Exit
)
)
endlocal
@echo off
setlocal EnableDelayedExpansion
 
set "overwriteGitConfigData=true"
 
set "skipConfig=0"
REM 0==dont skip; 1==skip userConfig; >1==skip
 
 
where git >nul 2>nul && (
echo Git is installed.
) || (
start cmd.exe /k "color 4f & title Error & Echo. & Echo. & Echo Git is not properly installed! & Echo The installation will be canceled. If this is a mistake, remove the initial check from this batch file. & Echo Press any key to close this dialog & Pause > nul & Exit"
Echo Git environment variable wasnt found; Pulling will be canceled
Echo.
Echo Press any key to exit.
Pause > nul
Exit;
)
 
 
for /f i in ('git rev-parse --is-inside-work-tree 2^>^&1') do (
if /I "i"=="true" (
goto success
) else (
echo Current directory isn't a Git repository!
echo By continuing, Git will be set up here.
set /P "input=Press 'y' to continue and configure Git here; 'n' to abort this action: "
 
REM Check if the length of the input at 4th index is empty (3 chars or less) and if it starts with 'y'
set "choice=!input:~0,1!"
if /I "!choice!"=="y" (
if "!input:~3!"=="" (
echo Continuing...
echo Setting Git up in the current directory...
git init
) else (
goto wrongDirError
)
) else (
:wrongDirError
echo Aborting...
echo.
echo Press any key to exit.
pause > nul
exit
)
)
)
 
:success
Echo.
 
if ""=="" (
echo No branch name input provided. Pulling the 'main' branch.
set "branchToPull=main"
)
 
 
set "gitConfigRemoteName=%~2"
 
if "^"==^"" (
echo No input remote repo name provided. Setting to default 'origin'.
set "gitConfigRemoteName=origin"
)
rem Read configurations from the config.txt file
for /F "tokens=1,* delims== " G in (config.txt) do (
if "G"=="gitConfigUser" (
set "gitConfigUser=H"
if "!gitConfigUser!"=="" set "gitConfigUser="
)
if "G"=="gitConfigPassword" (
set "gitConfigPassword=H"
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
if "G"=="gitConfigURL" (
set "gitConfigURL=H"
if "!gitConfigURL!"=="" set "gitConfigURL="
)
)
rem Removing quotes from the config values
set "gitConfigUser=!gitConfigUser:"=!"
set "gitConfigPassword=!gitConfigPassword:"=!"
set "gitConfigURL=!gitConfigURL:"=!"
 
rem Check if the string is a space character and set it to an empty variable; space is always appended >:-( though git should deal with these strings correctly nevertheless
if "^"==^" " set "gitConfigUser="
if "^"==^" " set "gitConfigPassword="
if "^"==^" " set "gitConfigURL="
 
 
rem read current/already defined Git Config to see if theyre blank; not using --global flag!
for /F "delims=" i in ('git config user.name') do set currentGitConfigUser=i
for /F "delims=" i in ('git config user.password') do set currentGitConfigPassword=i
for /F "delims=" i in ('git config --get remote..url') do set currentGitConfigURL=i
 
if "!currentGitConfigUser!"==" " set "currentGitConfigUser="
if "!currentGitConfigPassword!"==" " set "currentGitConfigPassword="
if "!currentGitConfigURL!"==" " set "currentGitConfigURL="
 
if ==0 (
REM do nothing
goto dontSkip
) else if ==1 (
goto skipUserConfig
) else (
goto skipConfig
)
 
:dontSkip
 
REM set TAB="<TAB>"
set "TAB=   "
 
Echo Current User Name: "!currentGitConfigUser!"  Read User Name: "!gitConfigUser!"
Echo Current User PWD: "!currentGitConfigPassword!"  Read User PWD: "!gitConfigPassword!"
Echo.
Echo Pulling from Host with Name: "%gitConfigRemoteName%"
Echo Current URL under this Name: "!currentGitConfigURL!"  Read URL: "!gitConfigURL!"
 
Echo.
Echo.
 
if not "!gitConfigUser!"=="" (
if "!currentGitConfigUser!"=="" (
echo Current local Git Username is not set -> new Name: "!gitConfigUser!"
git config user.name "!gitConfigUser!"
)else (
echo Current local Git Username is already set; if the overwriteGitConfigData flag is true the current Username: "!currentGitConfigUser!" will be set to "!gitConfigUser!"
if "!overwriteGitConfigData!"=="true" (
git config user.name "!gitConfigUser!"&Echo Overwriting successful; Username "!currentGitConfigUser!" changed to "!gitConfigUser!"
REM git config --global --replace-all "!gitConfigUser!"
)
)
)
 
Echo.
Echo.
 
if not "!gitConfigPassword!"=="" (
if "!currentGitConfigPassword!"=="" (
echo Current local Git Password is not set -> new Password: "!gitConfigPassword!"
git config user.password "!gitConfigPassword!"
)else (
 
echo Current local Git Password is already set; if the overwriteGitConfigData flag is true the current Password: "!currentGitConfigPassword!" will be set to "!gitConfigPassword!"
if "!overwriteGitConfigData!"=="true" (
git config user.password "!gitConfigPassword!"&Echo Overwriting successful; Password "!currentGitConfigPassword!" changed to "!gitConfigPassword!"
REM git config --replace-all --global user.password "!gitConfigPassword!"
)
)
)
 
:skipUserConfig
Echo.
Echo.
 
if not "!gitConfigURL!"=="" (
echo get displayed
echo !gitConfigURL!
echo "!currentGitConfigURL!"
 
if "!currentGitConfigURL!"=="" (
echo Current local Git fetch URL is not set -> new URL: "!gitConfigURL!"
git remote add  "!gitConfigURL!"
) else (
echo Current local Git fetch URL is already set; if the overwriteGitConfigData flag is true the current URL: "!currentGitConfigURL!" will be set to "!gitConfigURL!"
if "!overwriteGitConfigData!"=="true" (
git remote add !gitConfigRemoteName! "!gitConfigURL!" & Echo Overwriting successful; URL "!currentGitConfigURL!" changed to "!gitConfigURL!"
)
)
) else (
Echo Either Config.txt url was empty
)
:skipConfig
 
git pull %gitConfigRemoteName% %branchToPull%
 
 
if not %errorlevel% == 0(
Echo.
Echo Git ran into an Error when pulling.
Echo Have you committed your local changes?
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
Echo Resetting uncommited local changes ...
 
git reset --hard
git pull %gitConfigRemoteName% %branchToPull%
 
) else (
goto invalidNumberLength
)
) else (
:invalidNumberLength
Echo Aborting...
Echo.
Echo Press any key to exit.
Pause > nul
Exit
)
)
endlocal
@echo off
setlocal EnableDelayedExpansion
 
set "overwriteGitConfigData=true"
 
set "skipConfig=0"
REM 0==dont skip; 1==skip userConfig; >1==skip
 
 
where git >nul 2>nul && (
echo Git is installed.
) || (
start cmd.exe /k "color 4f & title Error & Echo. & Echo. & Echo Git is not properly installed! & Echo The installation will be canceled. If this is a mistake, remove the initial check from this batch file. & Echo Press any key to close this dialog & Pause > nul & Exit"
Echo Git environment variable wasnt found; Pulling will be canceled
Echo.
Echo Press any key to exit.
Pause > nul
Exit;
)
 
 
for /f i in ('git rev-parse --is-inside-work-tree 2^>^&1') do (
if /I "i"=="true" (
goto success
) else (
echo Current directory isn't a Git repository!
echo By continuing, Git will be set up here.
set /P "input=Press 'y' to continue and configure Git here; 'n' to abort this action: "
 
REM Check if the length of the input at 4th index is empty (3 chars or less) and if it starts with 'y'
set "choice=!input:~0,1!"
if /I "!choice!"=="y" (
if "!input:~3!"=="" (
echo Continuing...
echo Setting Git up in the current directory...
git init
) else (
goto wrongDirError
)
) else (
:wrongDirError
echo Aborting...
echo.
echo Press any key to exit.
pause > nul
exit
)
)
)
 
:success
Echo.
 
if ""=="" (
echo No branch name input provided. Pulling the 'main' branch.
set "branchToPull=main"
)
 
 
set "gitConfigRemoteName=%~2"
 
if "^"==^"" (
echo No input remote repo name provided. Setting to default 'origin'.
set "gitConfigRemoteName=origin"
)
rem Read configurations from the config.txt file
for /F "tokens=1,* delims== " G in (config.txt) do (
if "G"=="gitConfigUser" (
set "gitConfigUser=H"
if "!gitConfigUser!"=="" set "gitConfigUser="
)
if "G"=="gitConfigPassword" (
set "gitConfigPassword=H"
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
if "G"=="gitConfigURL" (
set "gitConfigURL=H"
if "!gitConfigURL!"=="" set "gitConfigURL="
)
)
rem Removing quotes from the config values
set "gitConfigUser=!gitConfigUser:"=!"
set "gitConfigPassword=!gitConfigPassword:"=!"
set "gitConfigURL=!gitConfigURL:"=!"
 
rem Check if the string is a space character and set it to an empty variable; space is always appended >:-( though git should deal with these strings correctly nevertheless
if "^"==^" " set "gitConfigUser="
if "^"==^" " set "gitConfigPassword="
if "^"==^" " set "gitConfigURL="
 
 
rem read current/already defined Git Config to see if theyre blank; not using --global flag!
for /F "delims=" i in ('git config user.name') do set currentGitConfigUser=i
for /F "delims=" i in ('git config user.password') do set currentGitConfigPassword=i
for /F "delims=" i in ('git config --get remote..url') do set currentGitConfigURL=i
 
if "!currentGitConfigUser!"==" " set "currentGitConfigUser="
if "!currentGitConfigPassword!"==" " set "currentGitConfigPassword="
if "!currentGitConfigURL!"==" " set "currentGitConfigURL="
 
if ==0 (
REM do nothing
goto dontSkip
) else if ==1 (
goto skipUserConfig
) else (
goto skipConfig
)
 
:dontSkip
 
REM set TAB="<TAB>"
set "TAB=   "
 
Echo Current User Name: "!currentGitConfigUser!"  Read User Name: "!gitConfigUser!"
Echo Current User PWD: "!currentGitConfigPassword!"  Read User PWD: "!gitConfigPassword!"
Echo.
Echo Pulling from Host with Name: "%gitConfigRemoteName%"
Echo Current URL under this Name: "!currentGitConfigURL!"  Read URL: "!gitConfigURL!"
 
Echo.
Echo.
 
if not "!gitConfigUser!"=="" (
if "!currentGitConfigUser!"=="" (
echo Current local Git Username is not set -> new Name: "!gitConfigUser!"
git config user.name "!gitConfigUser!"
)else (
echo Current local Git Username is already set; if the overwriteGitConfigData flag is true the current Username: "!currentGitConfigUser!" will be set to "!gitConfigUser!"
if "!overwriteGitConfigData!"=="true" (
git config user.name "!gitConfigUser!"&Echo Overwriting successful; Username "!currentGitConfigUser!" changed to "!gitConfigUser!"
REM git config --global --replace-all "!gitConfigUser!"
)
)
)
 
Echo.
Echo.
 
if not "!gitConfigPassword!"=="" (
if "!currentGitConfigPassword!"=="" (
echo Current local Git Password is not set -> new Password: "!gitConfigPassword!"
git config user.password "!gitConfigPassword!"
)else (
 
echo Current local Git Password is already set; if the overwriteGitConfigData flag is true the current Password: "!currentGitConfigPassword!" will be set to "!gitConfigPassword!"
if "!overwriteGitConfigData!"=="true" (
git config user.password "!gitConfigPassword!"&Echo Overwriting successful; Password "!currentGitConfigPassword!" changed to "!gitConfigPassword!"
REM git config --replace-all --global user.password "!gitConfigPassword!"
)
)
)
 
:skipUserConfig
Echo.
Echo.
 
if not "!gitConfigURL!"=="" (
echo get displayed
echo !gitConfigURL!
echo "!currentGitConfigURL!"
 
if "!currentGitConfigURL!"=="" (
echo Current local Git fetch URL is not set -> new URL: "!gitConfigURL!"
git remote add  "!gitConfigURL!"
) else (
echo Current local Git fetch URL is already set; if the overwriteGitConfigData flag is true the current URL: "!currentGitConfigURL!" will be set to "!gitConfigURL!"
if "!overwriteGitConfigData!"=="true" (
git remote add !gitConfigRemoteName! "!gitConfigURL!" & Echo Overwriting successful; URL "!currentGitConfigURL!" changed to "!gitConfigURL!"
)
)
) else (
Echo Either Config.txt url was empty
)
:skipConfig
 
git pull %gitConfigRemoteName% %branchToPull%
 
 
if not %errorlevel% == 0(
Echo.
Echo Git ran into an Error when pulling.
Echo Have you committed your local changes?
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
Echo Resetting uncommited local changes ...
 
git reset --hard
git pull %gitConfigRemoteName% %branchToPull%
 
) else (
goto invalidNumberLength
)
) else (
:invalidNumberLength
Echo Aborting...
Echo.
Echo Press any key to exit.
Pause > nul
Exit
)
)
endlocal
@echo off
setlocal EnableDelayedExpansion
 
set "overwriteGitConfigData=true"
 
set "skipConfig=0"
REM 0==dont skip; 1==skip userConfig; >1==skip
 
 
where git >nul 2>nul && (
echo Git is installed.
) || (
start cmd.exe /k "color 4f & title Error & Echo. & Echo. & Echo Git is not properly installed! & Echo The installation will be canceled. If this is a mistake, remove the initial check from this batch file. & Echo Press any key to close this dialog & Pause > nul & Exit"
Echo Git environment variable wasnt found; Pulling will be canceled
Echo.
Echo Press any key to exit.
Pause > nul
Exit;
)
 
 
for /f i in ('git rev-parse --is-inside-work-tree 2^>^&1') do (
if /I "i"=="true" (
goto success
) else (
echo Current directory isn't a Git repository!
echo By continuing, Git will be set up here.
set /P "input=Press 'y' to continue and configure Git here; 'n' to abort this action: "
 
REM Check if the length of the input at 4th index is empty (3 chars or less) and if it starts with 'y'
set "choice=!input:~0,1!"
if /I "!choice!"=="y" (
if "!input:~3!"=="" (
echo Continuing...
echo Setting Git up in the current directory...
git init
) else (
goto wrongDirError
)
) else (
:wrongDirError
echo Aborting...
echo.
echo Press any key to exit.
pause > nul
exit
)
)
)
 
:success
Echo.
 
if ""=="" (
echo No branch name input provided. Pulling the 'main' branch.
set "branchToPull=main"
)
 
 
set "gitConfigRemoteName=%~2"
 
if "^"==^"" (
echo No input remote repo name provided. Setting to default 'origin'.
set "gitConfigRemoteName=origin"
)
rem Read configurations from the config.txt file
for /F "tokens=1,* delims== " G in (config.txt) do (
if "G"=="gitConfigUser" (
set "gitConfigUser=H"
if "!gitConfigUser!"=="" set "gitConfigUser="
)
if "G"=="gitConfigPassword" (
set "gitConfigPassword=H"
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
if "G"=="gitConfigURL" (
set "gitConfigURL=H"
if "!gitConfigURL!"=="" set "gitConfigURL="
)
)
rem Removing quotes from the config values
set "gitConfigUser=!gitConfigUser:"=!"
set "gitConfigPassword=!gitConfigPassword:"=!"
set "gitConfigURL=!gitConfigURL:"=!"
 
rem Check if the string is a space character and set it to an empty variable; space is always appended >:-( though git should deal with these strings correctly nevertheless
if "^"==^" " set "gitConfigUser="
if "^"==^" " set "gitConfigPassword="
if "^"==^" " set "gitConfigURL="
 
 
rem read current/already defined Git Config to see if theyre blank; not using --global flag!
for /F "delims=" i in ('git config user.name') do set currentGitConfigUser=i
for /F "delims=" i in ('git config user.password') do set currentGitConfigPassword=i
for /F "delims=" i in ('git config --get remote..url') do set currentGitConfigURL=i
 
if "!currentGitConfigUser!"==" " set "currentGitConfigUser="
if "!currentGitConfigPassword!"==" " set "currentGitConfigPassword="
if "!currentGitConfigURL!"==" " set "currentGitConfigURL="
 
if ==0 (
REM do nothing
goto dontSkip
) else if ==1 (
goto skipUserConfig
) else (
goto skipConfig
)
 
:dontSkip
 
REM set TAB="<TAB>"
set "TAB=   "
 
Echo Current User Name: "!currentGitConfigUser!"  Read User Name: "!gitConfigUser!"
Echo Current User PWD: "!currentGitConfigPassword!"  Read User PWD: "!gitConfigPassword!"
Echo.
Echo Pulling from Host with Name: "%gitConfigRemoteName%"
Echo Current URL under this Name: "!currentGitConfigURL!"  Read URL: "!gitConfigURL!"
 
Echo.
Echo.
 
if not "!gitConfigUser!"=="" (
if "!currentGitConfigUser!"=="" (
echo Current local Git Username is not set -> new Name: "!gitConfigUser!"
git config user.name "!gitConfigUser!"
)else (
echo Current local Git Username is already set; if the overwriteGitConfigData flag is true the current Username: "!currentGitConfigUser!" will be set to "!gitConfigUser!"
if "!overwriteGitConfigData!"=="true" (
git config user.name "!gitConfigUser!"&Echo Overwriting successful; Username "!currentGitConfigUser!" changed to "!gitConfigUser!"
REM git config --global --replace-all "!gitConfigUser!"
)
)
)
 
Echo.
Echo.
 
if not "!gitConfigPassword!"=="" (
if "!currentGitConfigPassword!"=="" (
echo Current local Git Password is not set -> new Password: "!gitConfigPassword!"
git config user.password "!gitConfigPassword!"
)else (
 
echo Current local Git Password is already set; if the overwriteGitConfigData flag is true the current Password: "!currentGitConfigPassword!" will be set to "!gitConfigPassword!"
if "!overwriteGitConfigData!"=="true" (
git config user.password "!gitConfigPassword!"&Echo Overwriting successful; Password "!currentGitConfigPassword!" changed to "!gitConfigPassword!"
REM git config --replace-all --global user.password "!gitConfigPassword!"
)
)
)
 
:skipUserConfig
Echo.
Echo.
 
if not "!gitConfigURL!"=="" (
echo get displayed
echo !gitConfigURL!
echo "!currentGitConfigURL!"
 
if "!currentGitConfigURL!"=="" (
echo Current local Git fetch URL is not set -> new URL: "!gitConfigURL!"
git remote add  "!gitConfigURL!"
) else (
echo Current local Git fetch URL is already set; if the overwriteGitConfigData flag is true the current URL: "!currentGitConfigURL!" will be set to "!gitConfigURL!"
if "!overwriteGitConfigData!"=="true" (
git remote add !gitConfigRemoteName! "!gitConfigURL!" & Echo Overwriting successful; URL "!currentGitConfigURL!" changed to "!gitConfigURL!"
)
)
) else (
Echo Either Config.txt url was empty
)
:skipConfig
 
git pull %gitConfigRemoteName% %branchToPull%
 
 
if not %errorlevel% == 0(
Echo.
Echo Git ran into an Error when pulling.
Echo Have you committed your local changes?
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
Echo Resetting uncommited local changes ...
 
git reset --hard
git pull %gitConfigRemoteName% %branchToPull%
 
) else (
goto invalidNumberLength
)
) else (
:invalidNumberLength
Echo Aborting...
Echo.
Echo Press any key to exit.
Pause > nul
Exit
)
)
endlocal
@echo off
setlocal EnableDelayedExpansion
 
set "overwriteGitConfigData=true"
 
set "skipConfig=0"
REM 0==dont skip; 1==skip userConfig; >1==skip
 
 
where git >nul 2>nul && (
echo Git is installed.
) || (
start cmd.exe /k "color 4f & title Error & Echo. & Echo. & Echo Git is not properly installed! & Echo The installation will be canceled. If this is a mistake, remove the initial check from this batch file. & Echo Press any key to close this dialog & Pause > nul & Exit"
Echo Git environment variable wasnt found; Pulling will be canceled
Echo.
Echo Press any key to exit.
Pause > nul
Exit;
)
 
 
for /f i in ('git rev-parse --is-inside-work-tree 2^>^&1') do (
if /I "i"=="true" (
goto success
) else (
echo Current directory isn't a Git repository!
echo By continuing, Git will be set up here.
set /P "input=Press 'y' to continue and configure Git here; 'n' to abort this action: "
 
REM Check if the length of the input at 4th index is empty (3 chars or less) and if it starts with 'y'
set "choice=!input:~0,1!"
if /I "!choice!"=="y" (
if "!input:~3!"=="" (
echo Continuing...
echo Setting Git up in the current directory...
git init
) else (
goto wrongDirError
)
) else (
:wrongDirError
echo Aborting...
echo.
echo Press any key to exit.
pause > nul
exit
)
)
)
 
:success
Echo.
 
if ""=="" (
echo No branch name input provided. Pulling the 'main' branch.
set "branchToPull=main"
)
 
 
set "gitConfigRemoteName=%~2"
 
if "^"==^"" (
echo No input remote repo name provided. Setting to default 'origin'.
set "gitConfigRemoteName=origin"
)
rem Read configurations from the config.txt file
for /F "tokens=1,* delims== " G in (config.txt) do (
if "G"=="gitConfigUser" (
set "gitConfigUser=H"
if "!gitConfigUser!"=="" set "gitConfigUser="
)
if "G"=="gitConfigPassword" (
set "gitConfigPassword=H"
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
if "G"=="gitConfigURL" (
set "gitConfigURL=H"
if "!gitConfigURL!"=="" set "gitConfigURL="
)
)
rem Removing quotes from the config values
set "gitConfigUser=!gitConfigUser:"=!"
set "gitConfigPassword=!gitConfigPassword:"=!"
set "gitConfigURL=!gitConfigURL:"=!"
 
rem Check if the string is a space character and set it to an empty variable; space is always appended >:-( though git should deal with these strings correctly nevertheless
if "^"==^" " set "gitConfigUser="
if "^"==^" " set "gitConfigPassword="
if "^"==^" " set "gitConfigURL="
 
 
rem read current/already defined Git Config to see if theyre blank; not using --global flag!
for /F "delims=" i in ('git config user.name') do set currentGitConfigUser=i
for /F "delims=" i in ('git config user.password') do set currentGitConfigPassword=i
for /F "delims=" i in ('git config --get remote..url') do set currentGitConfigURL=i
 
if "!currentGitConfigUser!"==" " set "currentGitConfigUser="
if "!currentGitConfigPassword!"==" " set "currentGitConfigPassword="
if "!currentGitConfigURL!"==" " set "currentGitConfigURL="
 
if ==0 (
REM do nothing
goto dontSkip
) else if ==1 (
goto skipUserConfig
) else (
goto skipConfig
)
 
:dontSkip
 
REM set TAB="<TAB>"
set "TAB=   "
 
Echo Current User Name: "!currentGitConfigUser!"  Read User Name: "!gitConfigUser!"
Echo Current User PWD: "!currentGitConfigPassword!"  Read User PWD: "!gitConfigPassword!"
Echo.
Echo Pulling from Host with Name: "%gitConfigRemoteName%"
Echo Current URL under this Name: "!currentGitConfigURL!"  Read URL: "!gitConfigURL!"
 
Echo.
Echo.
 
if not "!gitConfigUser!"=="" (
if "!currentGitConfigUser!"=="" (
echo Current local Git Username is not set -> new Name: "!gitConfigUser!"
git config user.name "!gitConfigUser!"
)else (
echo Current local Git Username is already set; if the overwriteGitConfigData flag is true the current Username: "!currentGitConfigUser!" will be set to "!gitConfigUser!"
if "!overwriteGitConfigData!"=="true" (
git config user.name "!gitConfigUser!"&Echo Overwriting successful; Username "!currentGitConfigUser!" changed to "!gitConfigUser!"
REM git config --global --replace-all "!gitConfigUser!"
)
)
)
 
Echo.
Echo.
 
if not "!gitConfigPassword!"=="" (
if "!currentGitConfigPassword!"=="" (
echo Current local Git Password is not set -> new Password: "!gitConfigPassword!"
git config user.password "!gitConfigPassword!"
)else (
 
echo Current local Git Password is already set; if the overwriteGitConfigData flag is true the current Password: "!currentGitConfigPassword!" will be set to "!gitConfigPassword!"
if "!overwriteGitConfigData!"=="true" (
git config user.password "!gitConfigPassword!"&Echo Overwriting successful; Password "!currentGitConfigPassword!" changed to "!gitConfigPassword!"
REM git config --replace-all --global user.password "!gitConfigPassword!"
)
)
)
 
:skipUserConfig
Echo.
Echo.
 
if not "!gitConfigURL!"=="" (
echo get displayed
echo !gitConfigURL!
echo "!currentGitConfigURL!"
 
if "!currentGitConfigURL!"=="" (
echo Current local Git fetch URL is not set -> new URL: "!gitConfigURL!"
git remote add  "!gitConfigURL!"
) else (
echo Current local Git fetch URL is already set; if the overwriteGitConfigData flag is true the current URL: "!currentGitConfigURL!" will be set to "!gitConfigURL!"
if "!overwriteGitConfigData!"=="true" (
git remote add !gitConfigRemoteName! "!gitConfigURL!" & Echo Overwriting successful; URL "!currentGitConfigURL!" changed to "!gitConfigURL!"
)
)
) else (
Echo Either Config.txt url was empty
)
:skipConfig
 
git pull %gitConfigRemoteName% %branchToPull%
 
 
if not %errorlevel% == 0(
Echo.
Echo Git ran into an Error when pulling.
Echo Have you committed your local changes?
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
Echo Resetting uncommited local changes ...
 
git reset --hard
git pull %gitConfigRemoteName% %branchToPull%
 
) else (
goto invalidNumberLength
)
) else (
:invalidNumberLength
Echo Aborting...
Echo.
Echo Press any key to exit.
Pause > nul
Exit
)
)
endlocal
@echo off
setlocal EnableDelayedExpansion
 
set "overwriteGitConfigData=true"
 
set "skipConfig=0"
REM 0==dont skip; 1==skip userConfig; >1==skip
 
 
where git >nul 2>nul && (
echo Git is installed.
) || (
start cmd.exe /k "color 4f & title Error & Echo. & Echo. & Echo Git is not properly installed! & Echo The installation will be canceled. If this is a mistake, remove the initial check from this batch file. & Echo Press any key to close this dialog & Pause > nul & Exit"
Echo Git environment variable wasnt found; Pulling will be canceled
Echo.
Echo Press any key to exit.
Pause > nul
Exit;
)
 
 
for /f i in ('git rev-parse --is-inside-work-tree 2^>^&1') do (
if /I "i"=="true" (
goto success
) else (
echo Current directory isn't a Git repository!
echo By continuing, Git will be set up here.
set /P "input=Press 'y' to continue and configure Git here; 'n' to abort this action: "
 
REM Check if the length of the input at 4th index is empty (3 chars or less) and if it starts with 'y'
set "choice=!input:~0,1!"
if /I "!choice!"=="y" (
if "!input:~3!"=="" (
echo Continuing...
echo Setting Git up in the current directory...
git init
) else (
goto wrongDirError
)
) else (
:wrongDirError
echo Aborting...
echo.
echo Press any key to exit.
pause > nul
exit
)
)
)
 
:success
Echo.
 
if ""=="" (
echo No branch name input provided. Pulling the 'main' branch.
set "branchToPull=main"
)
 
 
set "gitConfigRemoteName=%~2"
 
if "^"==^"" (
echo No input remote repo name provided. Setting to default 'origin'.
set "gitConfigRemoteName=origin"
)
rem Read configurations from the config.txt file
for /F "tokens=1,* delims== " G in (config.txt) do (
if "G"=="gitConfigUser" (
set "gitConfigUser=H"
if "!gitConfigUser!"=="" set "gitConfigUser="
)
if "G"=="gitConfigPassword" (
set "gitConfigPassword=H"
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
if "G"=="gitConfigURL" (
set "gitConfigURL=H"
if "!gitConfigURL!"=="" set "gitConfigURL="
)
)
rem Removing quotes from the config values
set "gitConfigUser=!gitConfigUser:"=!"
set "gitConfigPassword=!gitConfigPassword:"=!"
set "gitConfigURL=!gitConfigURL:"=!"
 
rem Check if the string is a space character and set it to an empty variable; space is always appended >:-( though git should deal with these strings correctly nevertheless
if "^"==^" " set "gitConfigUser="
if "^"==^" " set "gitConfigPassword="
if "^"==^" " set "gitConfigURL="
 
 
rem read current/already defined Git Config to see if theyre blank; not using --global flag!
for /F "delims=" i in ('git config user.name') do set currentGitConfigUser=i
for /F "delims=" i in ('git config user.password') do set currentGitConfigPassword=i
for /F "delims=" i in ('git config --get remote..url') do set currentGitConfigURL=i
 
if "!currentGitConfigUser!"==" " set "currentGitConfigUser="
if "!currentGitConfigPassword!"==" " set "currentGitConfigPassword="
if "!currentGitConfigURL!"==" " set "currentGitConfigURL="
 
if ==0 (
REM do nothing
goto dontSkip
) else if ==1 (
goto skipUserConfig
) else (
goto skipConfig
)
 
:dontSkip
 
REM set TAB="<TAB>"
set "TAB=   "
 
Echo Current User Name: "!currentGitConfigUser!"  Read User Name: "!gitConfigUser!"
Echo Current User PWD: "!currentGitConfigPassword!"  Read User PWD: "!gitConfigPassword!"
Echo.
Echo Pulling from Host with Name: "%gitConfigRemoteName%"
Echo Current URL under this Name: "!currentGitConfigURL!"  Read URL: "!gitConfigURL!"
 
Echo.
Echo.
 
if not "!gitConfigUser!"=="" (
if "!currentGitConfigUser!"=="" (
echo Current local Git Username is not set -> new Name: "!gitConfigUser!"
git config user.name "!gitConfigUser!"
)else (
echo Current local Git Username is already set; if the overwriteGitConfigData flag is true the current Username: "!currentGitConfigUser!" will be set to "!gitConfigUser!"
if "!overwriteGitConfigData!"=="true" (
git config user.name "!gitConfigUser!"&Echo Overwriting successful; Username "!currentGitConfigUser!" changed to "!gitConfigUser!"
REM git config --global --replace-all "!gitConfigUser!"
)
)
)
 
Echo.
Echo.
 
if not "!gitConfigPassword!"=="" (
if "!currentGitConfigPassword!"=="" (
echo Current local Git Password is not set -> new Password: "!gitConfigPassword!"
git config user.password "!gitConfigPassword!"
)else (
 
echo Current local Git Password is already set; if the overwriteGitConfigData flag is true the current Password: "!currentGitConfigPassword!" will be set to "!gitConfigPassword!"
if "!overwriteGitConfigData!"=="true" (
git config user.password "!gitConfigPassword!"&Echo Overwriting successful; Password "!currentGitConfigPassword!" changed to "!gitConfigPassword!"
REM git config --replace-all --global user.password "!gitConfigPassword!"
)
)
)
 
:skipUserConfig
Echo.
Echo.
 
if not "!gitConfigURL!"=="" (
echo get displayed
echo !gitConfigURL!
echo "!currentGitConfigURL!"
 
if "!currentGitConfigURL!"=="" (
echo Current local Git fetch URL is not set -> new URL: "!gitConfigURL!"
git remote add  "!gitConfigURL!"
) else (
echo Current local Git fetch URL is already set; if the overwriteGitConfigData flag is true the current URL: "!currentGitConfigURL!" will be set to "!gitConfigURL!"
if "!overwriteGitConfigData!"=="true" (
git remote add !gitConfigRemoteName! "!gitConfigURL!" & Echo Overwriting successful; URL "!currentGitConfigURL!" changed to "!gitConfigURL!"
)
)
) else (
Echo Either Config.txt url was empty
)
:skipConfig
 
git pull %gitConfigRemoteName% %branchToPull%
 
 
if not %errorlevel% == 0(
Echo.
Echo Git ran into an Error when pulling.
Echo Have you committed your local changes?
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
Echo Resetting uncommited local changes ...
 
git reset --hard
git pull %gitConfigRemoteName% %branchToPull%
 
) else (
goto invalidNumberLength
)
) else (
:invalidNumberLength
Echo Aborting...
Echo.
Echo Press any key to exit.
Pause > nul
Exit
)
)
endlocal
@echo off
setlocal EnableDelayedExpansion
 
set "overwriteGitConfigData=true"
 
set "skipConfig=0"
REM 0==dont skip; 1==skip userConfig; >1==skip
 
 
where git >nul 2>nul && (
echo Git is installed.
) || (
start cmd.exe /k "color 4f & title Error & Echo. & Echo. & Echo Git is not properly installed! & Echo The installation will be canceled. If this is a mistake, remove the initial check from this batch file. & Echo Press any key to close this dialog & Pause > nul & Exit"
Echo Git environment variable wasnt found; Pulling will be canceled
Echo.
Echo Press any key to exit.
Pause > nul
Exit;
)
 
 
for /f i in ('git rev-parse --is-inside-work-tree 2^>^&1') do (
if /I "i"=="true" (
goto success
) else (
echo Current directory isn't a Git repository!
echo By continuing, Git will be set up here.
set /P "input=Press 'y' to continue and configure Git here; 'n' to abort this action: "
 
REM Check if the length of the input at 4th index is empty (3 chars or less) and if it starts with 'y'
set "choice=!input:~0,1!"
if /I "!choice!"=="y" (
if "!input:~3!"=="" (
echo Continuing...
echo Setting Git up in the current directory...
git init
) else (
goto wrongDirError
)
) else (
:wrongDirError
echo Aborting...
echo.
echo Press any key to exit.
pause > nul
exit
)
)
)
 
:success
Echo.
 
if ""=="" (
echo No branch name input provided. Pulling the 'main' branch.
set "branchToPull=main"
)
 
 
set "gitConfigRemoteName=%~2"
 
if "^"==^"" (
echo No input remote repo name provided. Setting to default 'origin'.
set "gitConfigRemoteName=origin"
)
rem Read configurations from the config.txt file
for /F "tokens=1,* delims== " G in (config.txt) do (
if "G"=="gitConfigUser" (
set "gitConfigUser=H"
if "!gitConfigUser!"=="" set "gitConfigUser="
)
if "G"=="gitConfigPassword" (
set "gitConfigPassword=H"
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
if "G"=="gitConfigURL" (
set "gitConfigURL=H"
if "!gitConfigURL!"=="" set "gitConfigURL="
)
)
rem Removing quotes from the config values
set "gitConfigUser=!gitConfigUser:"=!"
set "gitConfigPassword=!gitConfigPassword:"=!"
set "gitConfigURL=!gitConfigURL:"=!"
 
rem Check if the string is a space character and set it to an empty variable; space is always appended >:-( though git should deal with these strings correctly nevertheless
if "^"==^" " set "gitConfigUser="
if "^"==^" " set "gitConfigPassword="
if "^"==^" " set "gitConfigURL="
 
 
rem read current/already defined Git Config to see if theyre blank; not using --global flag!
for /F "delims=" i in ('git config user.name') do set currentGitConfigUser=i
for /F "delims=" i in ('git config user.password') do set currentGitConfigPassword=i
for /F "delims=" i in ('git config --get remote..url') do set currentGitConfigURL=i
 
if "!currentGitConfigUser!"==" " set "currentGitConfigUser="
if "!currentGitConfigPassword!"==" " set "currentGitConfigPassword="
if "!currentGitConfigURL!"==" " set "currentGitConfigURL="
 
if ==0 (
REM do nothing
goto dontSkip
) else if ==1 (
goto skipUserConfig
) else (
goto skipConfig
)
 
:dontSkip
 
REM set TAB="<TAB>"
set "TAB=   "
 
Echo Current User Name: "!currentGitConfigUser!"  Read User Name: "!gitConfigUser!"
Echo Current User PWD: "!currentGitConfigPassword!"  Read User PWD: "!gitConfigPassword!"
Echo.
Echo Pulling from Host with Name: "%gitConfigRemoteName%"
Echo Current URL under this Name: "!currentGitConfigURL!"  Read URL: "!gitConfigURL!"
 
Echo.
Echo.
 
if not "!gitConfigUser!"=="" (
if "!currentGitConfigUser!"=="" (
echo Current local Git Username is not set -> new Name: "!gitConfigUser!"
git config user.name "!gitConfigUser!"
)else (
echo Current local Git Username is already set; if the overwriteGitConfigData flag is true the current Username: "!currentGitConfigUser!" will be set to "!gitConfigUser!"
if "!overwriteGitConfigData!"=="true" (
git config user.name "!gitConfigUser!"&Echo Overwriting successful; Username "!currentGitConfigUser!" changed to "!gitConfigUser!"
REM git config --global --replace-all "!gitConfigUser!"
)
)
)
 
Echo.
Echo.
 
if not "!gitConfigPassword!"=="" (
if "!currentGitConfigPassword!"=="" (
echo Current local Git Password is not set -> new Password: "!gitConfigPassword!"
git config user.password "!gitConfigPassword!"
)else (
 
echo Current local Git Password is already set; if the overwriteGitConfigData flag is true the current Password: "!currentGitConfigPassword!" will be set to "!gitConfigPassword!"
if "!overwriteGitConfigData!"=="true" (
git config user.password "!gitConfigPassword!"&Echo Overwriting successful; Password "!currentGitConfigPassword!" changed to "!gitConfigPassword!"
REM git config --replace-all --global user.password "!gitConfigPassword!"
)
)
)
 
:skipUserConfig
Echo.
Echo.
 
if not "!gitConfigURL!"=="" (
echo get displayed
echo !gitConfigURL!
echo "!currentGitConfigURL!"
 
if "!currentGitConfigURL!"=="" (
echo Current local Git fetch URL is not set -> new URL: "!gitConfigURL!"
git remote add  "!gitConfigURL!"
) else (
echo Current local Git fetch URL is already set; if the overwriteGitConfigData flag is true the current URL: "!currentGitConfigURL!" will be set to "!gitConfigURL!"
if "!overwriteGitConfigData!"=="true" (
git remote add !gitConfigRemoteName! "!gitConfigURL!" & Echo Overwriting successful; URL "!currentGitConfigURL!" changed to "!gitConfigURL!"
)
)
) else (
Echo Either Config.txt url was empty
)
:skipConfig
 
git pull %gitConfigRemoteName% %branchToPull%
 
 
if not %errorlevel% == 0(
Echo.
Echo Git ran into an Error when pulling.
Echo Have you committed your local changes?
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
Echo Resetting uncommited local changes ...
 
git reset --hard
git pull %gitConfigRemoteName% %branchToPull%
 
) else (
goto invalidNumberLength
)
) else (
:invalidNumberLength
Echo Aborting...
Echo.
Echo Press any key to exit.
Pause > nul
Exit
)
)
endlocal
@echo off
setlocal EnableDelayedExpansion
 
set "overwriteGitConfigData=true"
 
set "skipConfig=0"
REM 0==dont skip; 1==skip userConfig; >1==skip
 
 
where git >nul 2>nul && (
echo Git is installed.
) || (
start cmd.exe /k "color 4f & title Error & Echo. & Echo. & Echo Git is not properly installed! & Echo The installation will be canceled. If this is a mistake, remove the initial check from this batch file. & Echo Press any key to close this dialog & Pause > nul & Exit"
Echo Git environment variable wasnt found; Pulling will be canceled
Echo.
Echo Press any key to exit.
Pause > nul
Exit;
)
 
 
for /f i in ('git rev-parse --is-inside-work-tree 2^>^&1') do (
if /I "i"=="true" (
goto success
) else (
echo Current directory isn't a Git repository!
echo By continuing, Git will be set up here.
set /P "input=Press 'y' to continue and configure Git here; 'n' to abort this action: "
 
REM Check if the length of the input at 4th index is empty (3 chars or less) and if it starts with 'y'
set "choice=!input:~0,1!"
if /I "!choice!"=="y" (
if "!input:~3!"=="" (
echo Continuing...
echo Setting Git up in the current directory...
git init
) else (
goto wrongDirError
)
) else (
:wrongDirError
echo Aborting...
echo.
echo Press any key to exit.
pause > nul
exit
)
)
)
 
:success
Echo.
 
if ""=="" (
echo No branch name input provided. Pulling the 'main' branch.
set "branchToPull=main"
)
 
 
set "gitConfigRemoteName=%~2"
 
if "^"==^"" (
echo No input remote repo name provided. Setting to default 'origin'.
set "gitConfigRemoteName=origin"
)
rem Read configurations from the config.txt file
for /F "tokens=1,* delims== " G in (config.txt) do (
if "G"=="gitConfigUser" (
set "gitConfigUser=H"
if "!gitConfigUser!"=="" set "gitConfigUser="
)
if "G"=="gitConfigPassword" (
set "gitConfigPassword=H"
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
if "G"=="gitConfigURL" (
set "gitConfigURL=H"
if "!gitConfigURL!"=="" set "gitConfigURL="
)
)
rem Removing quotes from the config values
set "gitConfigUser=!gitConfigUser:"=!"
set "gitConfigPassword=!gitConfigPassword:"=!"
set "gitConfigURL=!gitConfigURL:"=!"
 
rem Check if the string is a space character and set it to an empty variable; space is always appended >:-( though git should deal with these strings correctly nevertheless
if "^"==^" " set "gitConfigUser="
if "^"==^" " set "gitConfigPassword="
if "^"==^" " set "gitConfigURL="
 
 
rem read current/already defined Git Config to see if theyre blank; not using --global flag!
for /F "delims=" i in ('git config user.name') do set currentGitConfigUser=i
for /F "delims=" i in ('git config user.password') do set currentGitConfigPassword=i
for /F "delims=" i in ('git config --get remote..url') do set currentGitConfigURL=i
 
if "!currentGitConfigUser!"==" " set "currentGitConfigUser="
if "!currentGitConfigPassword!"==" " set "currentGitConfigPassword="
if "!currentGitConfigURL!"==" " set "currentGitConfigURL="
 
if ==0 (
REM do nothing
goto dontSkip
) else if ==1 (
goto skipUserConfig
) else (
goto skipConfig
)
 
:dontSkip
 
REM set TAB="<TAB>"
set "TAB=   "
 
Echo Current User Name: "!currentGitConfigUser!"  Read User Name: "!gitConfigUser!"
Echo Current User PWD: "!currentGitConfigPassword!"  Read User PWD: "!gitConfigPassword!"
Echo.
Echo Pulling from Host with Name: "%gitConfigRemoteName%"
Echo Current URL under this Name: "!currentGitConfigURL!"  Read URL: "!gitConfigURL!"
 
Echo.
Echo.
 
if not "!gitConfigUser!"=="" (
if "!currentGitConfigUser!"=="" (
echo Current local Git Username is not set -> new Name: "!gitConfigUser!"
git config user.name "!gitConfigUser!"
)else (
echo Current local Git Username is already set; if the overwriteGitConfigData flag is true the current Username: "!currentGitConfigUser!" will be set to "!gitConfigUser!"
if "!overwriteGitConfigData!"=="true" (
git config user.name "!gitConfigUser!"&Echo Overwriting successful; Username "!currentGitConfigUser!" changed to "!gitConfigUser!"
REM git config --global --replace-all "!gitConfigUser!"
)
)
)
 
Echo.
Echo.
 
if not "!gitConfigPassword!"=="" (
if "!currentGitConfigPassword!"=="" (
echo Current local Git Password is not set -> new Password: "!gitConfigPassword!"
git config user.password "!gitConfigPassword!"
)else (
 
echo Current local Git Password is already set; if the overwriteGitConfigData flag is true the current Password: "!currentGitConfigPassword!" will be set to "!gitConfigPassword!"
if "!overwriteGitConfigData!"=="true" (
git config user.password "!gitConfigPassword!"&Echo Overwriting successful; Password "!currentGitConfigPassword!" changed to "!gitConfigPassword!"
REM git config --replace-all --global user.password "!gitConfigPassword!"
)
)
)
 
:skipUserConfig
Echo.
Echo.
 
if not "!gitConfigURL!"=="" (
echo get displayed
echo !gitConfigURL!
echo "!currentGitConfigURL!"
 
if "!currentGitConfigURL!"=="" (
echo Current local Git fetch URL is not set -> new URL: "!gitConfigURL!"
git remote add  "!gitConfigURL!"
) else (
echo Current local Git fetch URL is already set; if the overwriteGitConfigData flag is true the current URL: "!currentGitConfigURL!" will be set to "!gitConfigURL!"
if "!overwriteGitConfigData!"=="true" (
git remote add !gitConfigRemoteName! "!gitConfigURL!" & Echo Overwriting successful; URL "!currentGitConfigURL!" changed to "!gitConfigURL!"
)
)
) else (
Echo Either Config.txt url was empty
)
:skipConfig
 
git pull %gitConfigRemoteName% %branchToPull%
 
 
if not %errorlevel% == 0(
Echo.
Echo Git ran into an Error when pulling.
Echo Have you committed your local changes?
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
Echo Resetting uncommited local changes ...
 
git reset --hard
git pull %gitConfigRemoteName% %branchToPull%
 
) else (
goto invalidNumberLength
)
) else (
:invalidNumberLength
Echo Aborting...
Echo.
Echo Press any key to exit.
Pause > nul
Exit
)
)
endlocal
@echo off
setlocal EnableDelayedExpansion
 
set "overwriteGitConfigData=true"
 
set "skipConfig=0"
REM 0==dont skip; 1==skip userConfig; >1==skip
 
 
where git >nul 2>nul && (
echo Git is installed.
) || (
start cmd.exe /k "color 4f & title Error & Echo. & Echo. & Echo Git is not properly installed! & Echo The installation will be canceled. If this is a mistake, remove the initial check from this batch file. & Echo Press any key to close this dialog & Pause > nul & Exit"
Echo Git environment variable wasnt found; Pulling will be canceled
Echo.
Echo Press any key to exit.
Pause > nul
Exit;
)
 
 
for /f i in ('git rev-parse --is-inside-work-tree 2^>^&1') do (
if /I "i"=="true" (
goto success
) else (
echo Current directory isn't a Git repository!
echo By continuing, Git will be set up here.
set /P "input=Press 'y' to continue and configure Git here; 'n' to abort this action: "
 
REM Check if the length of the input at 4th index is empty (3 chars or less) and if it starts with 'y'
set "choice=!input:~0,1!"
if /I "!choice!"=="y" (
if "!input:~3!"=="" (
echo Continuing...
echo Setting Git up in the current directory...
git init
) else (
goto wrongDirError
)
) else (
:wrongDirError
echo Aborting...
echo.
echo Press any key to exit.
pause > nul
exit
)
)
)
 
:success
Echo.
 
if ""=="" (
echo No branch name input provided. Pulling the 'main' branch.
set "branchToPull=main"
)
 
 
set "gitConfigRemoteName=%~2"
 
if "^"==^"" (
echo No input remote repo name provided. Setting to default 'origin'.
set "gitConfigRemoteName=origin"
)
rem Read configurations from the config.txt file
for /F "tokens=1,* delims== " G in (config.txt) do (
if "G"=="gitConfigUser" (
set "gitConfigUser=H"
if "!gitConfigUser!"=="" set "gitConfigUser="
)
if "G"=="gitConfigPassword" (
set "gitConfigPassword=H"
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
if "G"=="gitConfigURL" (
set "gitConfigURL=H"
if "!gitConfigURL!"=="" set "gitConfigURL="
)
)
rem Removing quotes from the config values
set "gitConfigUser=!gitConfigUser:"=!"
set "gitConfigPassword=!gitConfigPassword:"=!"
set "gitConfigURL=!gitConfigURL:"=!"
 
rem Check if the string is a space character and set it to an empty variable; space is always appended >:-( though git should deal with these strings correctly nevertheless
if "^"==^" " set "gitConfigUser="
if "^"==^" " set "gitConfigPassword="
if "^"==^" " set "gitConfigURL="
 
 
rem read current/already defined Git Config to see if theyre blank; not using --global flag!
for /F "delims=" i in ('git config user.name') do set currentGitConfigUser=i
for /F "delims=" i in ('git config user.password') do set currentGitConfigPassword=i
for /F "delims=" i in ('git config --get remote..url') do set currentGitConfigURL=i
 
if "!currentGitConfigUser!"==" " set "currentGitConfigUser="
if "!currentGitConfigPassword!"==" " set "currentGitConfigPassword="
if "!currentGitConfigURL!"==" " set "currentGitConfigURL="
 
if ==0 (
REM do nothing
goto dontSkip
) else if ==1 (
goto skipUserConfig
) else (
goto skipConfig
)
 
:dontSkip
 
REM set TAB="<TAB>"
set "TAB=   "
 
Echo Current User Name: "!currentGitConfigUser!"  Read User Name: "!gitConfigUser!"
Echo Current User PWD: "!currentGitConfigPassword!"  Read User PWD: "!gitConfigPassword!"
Echo.
Echo Pulling from Host with Name: "%gitConfigRemoteName%"
Echo Current URL under this Name: "!currentGitConfigURL!"  Read URL: "!gitConfigURL!"
 
Echo.
Echo.
 
if not "!gitConfigUser!"=="" (
if "!currentGitConfigUser!"=="" (
echo Current local Git Username is not set -> new Name: "!gitConfigUser!"
git config user.name "!gitConfigUser!"
)else (
echo Current local Git Username is already set; if the overwriteGitConfigData flag is true the current Username: "!currentGitConfigUser!" will be set to "!gitConfigUser!"
if "!overwriteGitConfigData!"=="true" (
git config user.name "!gitConfigUser!"&Echo Overwriting successful; Username "!currentGitConfigUser!" changed to "!gitConfigUser!"
REM git config --global --replace-all "!gitConfigUser!"
)
)
)
 
Echo.
Echo.
 
if not "!gitConfigPassword!"=="" (
if "!currentGitConfigPassword!"=="" (
echo Current local Git Password is not set -> new Password: "!gitConfigPassword!"
git config user.password "!gitConfigPassword!"
)else (
 
echo Current local Git Password is already set; if the overwriteGitConfigData flag is true the current Password: "!currentGitConfigPassword!" will be set to "!gitConfigPassword!"
if "!overwriteGitConfigData!"=="true" (
git config user.password "!gitConfigPassword!"&Echo Overwriting successful; Password "!currentGitConfigPassword!" changed to "!gitConfigPassword!"
REM git config --replace-all --global user.password "!gitConfigPassword!"
)
)
)
 
:skipUserConfig
Echo.
Echo.
 
if not "!gitConfigURL!"=="" (
echo get displayed
echo !gitConfigURL!
echo "!currentGitConfigURL!"
 
if "!currentGitConfigURL!"=="" (
echo Current local Git fetch URL is not set -> new URL: "!gitConfigURL!"
git remote add  "!gitConfigURL!"
) else (
echo Current local Git fetch URL is already set; if the overwriteGitConfigData flag is true the current URL: "!currentGitConfigURL!" will be set to "!gitConfigURL!"
if "!overwriteGitConfigData!"=="true" (
git remote add !gitConfigRemoteName! "!gitConfigURL!" & Echo Overwriting successful; URL "!currentGitConfigURL!" changed to "!gitConfigURL!"
)
)
) else (
Echo Either Config.txt url was empty
)
:skipConfig
 
git pull %gitConfigRemoteName% %branchToPull%
 
 
if not %errorlevel% == 0(
Echo.
Echo Git ran into an Error when pulling.
Echo Have you committed your local changes?
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
Echo Resetting uncommited local changes ...
 
git reset --hard
git pull %gitConfigRemoteName% %branchToPull%
 
) else (
goto invalidNumberLength
)
) else (
:invalidNumberLength
Echo Aborting...
Echo.
Echo Press any key to exit.
Pause > nul
Exit
)
)
endlocal
@echo off
setlocal EnableDelayedExpansion
 
set "overwriteGitConfigData=true"
 
set "skipConfig=0"
 
echo Git is installed.
 
Echo Git environment variable wasnt found; Pulling will be canceled
Echo.
Echo Press any key to exit.
Pause > nul
Exit;
)
 
echo Continuing...
echo Setting Git up in the current directory...
set "choice=!input:~0,1!"
if /I "!choice!"=="y" (
if "!input:~3!"=="" (
echo.
goto wrongDirError
)
) else (
:wrongDirError
echo Aborting...
echo.
)
Echo.
)
if ""=="" (
echo No branch name input provided. Pulling the 'main' branch.
Echo.
set "gitConfigRemoteName=%~2"
if ""=="" (
set "gitConfigRemoteName=origin"
echo No branch name input provided. Pulling the 'main' branch.
set "branchToPull=main"
)
 
 
set "gitConfigRemoteName=%~2"
 
if "^"==^"" (
echo No input remote repo name provided. Setting to default 'origin'.
set "gitConfigRemoteName=origin"
)
rem Read configurations from the config.txt file
for /F "tokens=1,* delims== " G in (config.txt) do (
if "G"=="gitConfigUser" (
set "gitConfigUser=H"
if "!gitConfigUser!"=="" set "gitConfigUser="
)
if "G"=="gitConfigPassword" (
set "gitConfigPassword=H"
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
if "G"=="gitConfigURL" (
set "gitConfigURL=H"
if "!gitConfigURL!"=="" set "gitConfigURL="
)
)
rem Removing quotes from the config values
set "gitConfigUser=!gitConfigUser:"=!"
set "gitConfigPassword=!gitConfigPassword:"=!"
set "gitConfigURL=!gitConfigURL:"=!"
 
rem Check if the string is a space character and set it to an empty variable; space is always appended >:-( though git should deal with these strings correctly nevertheless
if "^"==^" " set "gitConfigUser="
if "^"==^" " set "gitConfigPassword="
if "^"==^" " set "gitConfigURL="
 
 
rem read current/already defined Git Config to see if theyre blank; not using --global flag!
for /F "delims=" i in ('git config user.name') do set currentGitConfigUser=i
for /F "delims=" i in ('git config user.password') do set currentGitConfigPassword=i
for /F "delims=" i in ('git config --get remote..url') do set currentGitConfigURL=i
 
if "!currentGitConfigUser!"==" " set "currentGitConfigUser="
if "!currentGitConfigPassword!"==" " set "currentGitConfigPassword="
if "!currentGitConfigURL!"==" " set "currentGitConfigURL="
 
if ==0 (
REM do nothing
goto dontSkip
) else if ==1 (
goto skipUserConfig
) else (
goto skipConfig
)
 
:dontSkip
 
REM set TAB="<TAB>"
set "TAB=   "
 
Echo Current User Name: "!currentGitConfigUser!"  Read User Name: "!gitConfigUser!"
Echo Current User PWD: "!currentGitConfigPassword!"  Read User PWD: "!gitConfigPassword!"
Echo.
Echo Pulling from Host with Name: "%gitConfigRemoteName%"
Echo Current URL under this Name: "!currentGitConfigURL!"  Read URL: "!gitConfigURL!"
 
Echo.
Echo.
 
if not "!gitConfigUser!"=="" (
if "!currentGitConfigUser!"=="" (
echo Current local Git Username is not set -> new Name: "!gitConfigUser!"
git config user.name "!gitConfigUser!"
)else (
echo Current local Git Username is already set; if the overwriteGitConfigData flag is true the current Username: "!currentGitConfigUser!" will be set to "!gitConfigUser!"
if "!overwriteGitConfigData!"=="true" (
git config user.name "!gitConfigUser!"&Echo Overwriting successful; Username "!currentGitConfigUser!" changed to "!gitConfigUser!"
REM git config --global --replace-all "!gitConfigUser!"
)
)
)
 
Echo.
Echo.
 
if not "!gitConfigPassword!"=="" (
if "!currentGitConfigPassword!"=="" (
echo Current local Git Password is not set -> new Password: "!gitConfigPassword!"
git config user.password "!gitConfigPassword!"
)else (
 
echo Current local Git Password is already set; if the overwriteGitConfigData flag is true the current Password: "!currentGitConfigPassword!" will be set to "!gitConfigPassword!"
if "!overwriteGitConfigData!"=="true" (
git config user.password "!gitConfigPassword!"&Echo Overwriting successful; Password "!currentGitConfigPassword!" changed to "!gitConfigPassword!"
REM git config --replace-all --global user.password "!gitConfigPassword!"
)
)
)
 
:skipUserConfig
Echo.
Echo.
 
if not "!gitConfigURL!"=="" (
echo get displayed
echo !gitConfigURL!
echo "!currentGitConfigURL!"
 
if "!currentGitConfigURL!"=="" (
echo Current local Git fetch URL is not set -> new URL: "!gitConfigURL!"
git remote add  "!gitConfigURL!"
) else (
echo Current local Git fetch URL is already set; if the overwriteGitConfigData flag is true the current URL: "!currentGitConfigURL!" will be set to "!gitConfigURL!"
if "!overwriteGitConfigData!"=="true" (
git remote add !gitConfigRemoteName! "!gitConfigURL!" & Echo Overwriting successful; URL "!currentGitConfigURL!" changed to "!gitConfigURL!"
)
)
) else (
Echo Either Config.txt url was empty
)
:skipConfig
 
git pull %gitConfigRemoteName% %branchToPull%
 
 
if not %errorlevel% == 0(
Echo.
Echo Git ran into an Error when pulling.
Echo Have you committed your local changes?
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
Echo Resetting uncommited local changes ...
 
git reset --hard
git pull %gitConfigRemoteName% %branchToPull%
 
) else (
goto invalidNumberLength
)
) else (
:invalidNumberLength
Echo Aborting...
Echo.
Echo Press any key to exit.
Pause > nul
Exit
)
)
endlocal
if "G"=="gitConfigPassword" (
set "gitConfigPassword=H"
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
if "G"=="gitConfigURL" (
set "gitConfigURL=H"
if "!gitConfigURL!"=="" set "gitConfigURL="
)
)
rem Removing quotes from the config values
set "gitConfigUser=!gitConfigUser:"=!"
set "gitConfigPassword=!gitConfigPassword:"=!"
set "gitConfigURL=!gitConfigURL:"=!"
 
rem Check if the string is a space character and set it to an empty variable; space is always appended >:-( though git should deal with these strings correctly nevertheless
if "^"==^" " set "gitConfigUser="
if "^"==^" " set "gitConfigPassword="
if "^"==^" " set "gitConfigURL="
 
 
rem read current/already defined Git Config to see if theyre blank; not using --global flag!
for /F "delims=" i in ('git config user.name') do set currentGitConfigUser=i
for /F "delims=" i in ('git config user.password') do set currentGitConfigPassword=i
for /F "delims=" i in ('git config --get remote..url') do set currentGitConfigURL=i
 
if "!currentGitConfigUser!"==" " set "currentGitConfigUser="
if "!currentGitConfigPassword!"==" " set "currentGitConfigPassword="
if "!currentGitConfigURL!"==" " set "currentGitConfigURL="
 
if ==0 (
REM do nothing
goto dontSkip
) else if ==1 (
goto skipUserConfig
) else (
goto skipConfig
)
 
:dontSkip
 
REM set TAB="<TAB>"
set "TAB=   "
 
Echo Current User Name: "!currentGitConfigUser!"  Read User Name: "!gitConfigUser!"
Echo Current User PWD: "!currentGitConfigPassword!"  Read User PWD: "!gitConfigPassword!"
Echo.
Echo Pulling from Host with Name: "%gitConfigRemoteName%"
Echo Current URL under this Name: "!currentGitConfigURL!"  Read URL: "!gitConfigURL!"
 
Echo.
Echo.
 
if not "!gitConfigUser!"=="" (
if "!currentGitConfigUser!"=="" (
echo Current local Git Username is not set -> new Name: "!gitConfigUser!"
git config user.name "!gitConfigUser!"
)else (
echo Current local Git Username is already set; if the overwriteGitConfigData flag is true the current Username: "!currentGitConfigUser!" will be set to "!gitConfigUser!"
if "!overwriteGitConfigData!"=="true" (
git config user.name "!gitConfigUser!"&Echo Overwriting successful; Username "!currentGitConfigUser!" changed to "!gitConfigUser!"
REM git config --global --replace-all "!gitConfigUser!"
)
)
)
 
Echo.
Echo.
 
if not "!gitConfigPassword!"=="" (
if "!currentGitConfigPassword!"=="" (
echo Current local Git Password is not set -> new Password: "!gitConfigPassword!"
git config user.password "!gitConfigPassword!"
)else (
 
echo Current local Git Password is already set; if the overwriteGitConfigData flag is true the current Password: "!currentGitConfigPassword!" will be set to "!gitConfigPassword!"
if "!overwriteGitConfigData!"=="true" (
git config user.password "!gitConfigPassword!"&Echo Overwriting successful; Password "!currentGitConfigPassword!" changed to "!gitConfigPassword!"
REM git config --replace-all --global user.password "!gitConfigPassword!"
)
)
)
 
:skipUserConfig
Echo.
Echo.
 
if not "!gitConfigURL!"=="" (
echo get displayed
echo !gitConfigURL!
echo "!currentGitConfigURL!"
 
if "!currentGitConfigURL!"=="" (
echo Current local Git fetch URL is not set -> new URL: "!gitConfigURL!"
git remote add  "!gitConfigURL!"
) else (
echo Current local Git fetch URL is already set; if the overwriteGitConfigData flag is true the current URL: "!currentGitConfigURL!" will be set to "!gitConfigURL!"
if "!overwriteGitConfigData!"=="true" (
git remote add !gitConfigRemoteName! "!gitConfigURL!" & Echo Overwriting successful; URL "!currentGitConfigURL!" changed to "!gitConfigURL!"
)
)
) else (
Echo Either Config.txt url was empty
)
:skipConfig
 
git pull %gitConfigRemoteName% %branchToPull%
 
 
if not %errorlevel% == 0(
Echo.
Echo Git ran into an Error when pulling.
Echo Have you committed your local changes?
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
Echo Resetting uncommited local changes ...
 
git reset --hard
git pull %gitConfigRemoteName% %branchToPull%
 
) else (
goto invalidNumberLength
)
) else (
:invalidNumberLength
Echo Aborting...
Echo.
Echo Press any key to exit.
Pause > nul
Exit
)
)
endlocal
@echo off
setlocal EnableDelayedExpansion
 
set "overwriteGitConfigData=true"
 
set "skipConfig=0"
 
where git >nul 2>nul && (
echo Git is installed.
) || (
if /I "i"=="true" (
Echo Press any key to exit.
)
) else (
if /I "i"=="true" (
)
set /P "input=Press 'y' to continue and configure Git here; 'n' to abort this action: "
set "branchToPull=main"
set "choice=!input:~0,1!"
if "^"==^"" (
echo No input remote repo name provided. Setting to default 'origin'.
)
)
rem Read configurations from the config.txt file
for /F "tokens=1,* delims== " G in (config.txt) do (
Echo.
set "gitConfigUser=H"
echo No branch name input provided. Pulling the 'main' branch.
if "!gitConfigUser!"=="" set "gitConfigUser="
 
if "G"=="gitConfigPassword" (
echo No input remote repo name provided. Setting to default 'origin'.
set "gitConfigURL=H"
if "!gitConfigURL!"=="" set "gitConfigURL="
)
set "gitConfigUser=H"
set "gitConfigUser=!gitConfigUser:"=!"
set "gitConfigPassword=!gitConfigPassword:"=!"
set "gitConfigURL=!gitConfigURL:"=!"
 
 
 
rem read current/already defined Git Config to see if theyre blank; not using --global flag!
for /F "delims=" i in ('git config user.name') do set currentGitConfigUser=i
for /F "delims=" i in ('git config user.password') do set currentGitConfigPassword=i
if "!currentGitConfigURL!"==" " set "currentGitConfigURL="
 
if ==0 (
REM do nothing
goto dontSkip
) else if ==1 (
goto skipUserConfig
) else (
if "!currentGitConfigUser!"=="" (
echo Current local Git Username is not set -> new Name: "!gitConfigUser!"
 
)
echo Current local Git Username is already set; if the overwriteGitConfigData flag is true the current Username: "!currentGitConfigUser!" will be set to "!gitConfigUser!"
if "!currentGitConfigPassword!"=="" (
echo Current local Git Password is not set -> new Password: "!gitConfigPassword!"
echo Current local Git Password is already set; if the overwriteGitConfigData flag is true the current Password: "!currentGitConfigPassword!" will be set to "!gitConfigPassword!"
if "!overwriteGitConfigData!"=="true" (
echo get displayed
echo !gitConfigURL!
echo "!currentGitConfigURL!"
Echo Either Config.txt url was empty
)
)
:skipConfig
git pull %gitConfigRemoteName% %branchToPull%
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
@echo off
) else (
where git >nul 2>nul && (
Pause > nul
)
 
echo Git is installed.
set /P "input=Press 'y' to continue and configure Git here; 'n' to abort this action: "
 
REM Check if the length of the input at 4th index is empty (3 chars or less) and if it starts with 'y'
set "choice=!input:~0,1!"
if /I "!choice!"=="y" (
)
)
) else (
 
)
)
 
set "gitConfigPassword=!gitConfigPassword:"=!"
set "gitConfigURL=!gitConfigURL:"=!"
 
set "gitConfigPassword=H"
if "!gitConfigPassword!"=="" set "gitConfigPassword="
if "!currentGitConfigPassword!"==" " set "currentGitConfigPassword="
if "!currentGitConfigURL!"==" " set "currentGitConfigURL="
if "^"==^" " set "gitConfigURL="
goto skipConfig
if "!currentGitConfigUser!"==" " set "currentGitConfigUser="
 
goto skipUserConfig
Echo.
 
Echo Current User Name: "!currentGitConfigUser!"  Read User Name: "!gitConfigUser!"
Echo Current User PWD: "!currentGitConfigPassword!"  Read User PWD: "!gitConfigPassword!"
)else (
if not "!gitConfigUser!"=="" (
if "!currentGitConfigUser!"=="" (
echo !gitConfigURL!
echo "!currentGitConfigURL!"
git config user.password "!gitConfigPassword!"
) else (
)
if not %errorlevel% == 0(
if not "!gitConfigURL!"=="" (
echo get displayed
 
git reset --hard
:skipConfig
 
git pull %gitConfigRemoteName% %branchToPull%
 
 
if not %errorlevel% == 0(
Echo.
Echo Git ran into an Error when pulling.
Echo Have you committed your local changes?
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
Echo Resetting uncommited local changes ...
 
git reset --hard
git pull %gitConfigRemoteName% %branchToPull%
 
) else (
goto invalidNumberLength
)
) else (
:invalidNumberLength
Echo Aborting...
Echo.
Echo Press any key to exit.
Pause > nul
Exit
)
)
endlocal
@echo off
setlocal EnableDelayedExpansion
 
set "overwriteGitConfigData=true"
 
Echo Press any key to exit.
for /f i in ('git rev-parse --is-inside-work-tree 2^>^&1') do (
)
 
) else (
goto wrongDirError
if /I "i"=="true" (
goto success
Echo.
)
) else (
)
 
)
 
:success
Echo.
if "G"=="gitConfigUser" (
if ""=="" (
echo No branch name input provided. Pulling the 'main' branch.
set "branchToPull=main"
)
if "!gitConfigURL!"=="" set "gitConfigURL="
set "gitConfigRemoteName=%~2"
 
for /F "delims=" i in ('git config user.name') do set currentGitConfigUser=i
for /F "delims=" i in ('git config user.password') do set currentGitConfigPassword=i
for /F "delims=" i in ('git config --get remote..url') do set currentGitConfigURL=i
 
if "!currentGitConfigUser!"==" " set "currentGitConfigUser="
)
rem Removing quotes from the config values
) else (
if "^"==^" " set "gitConfigURL="
goto skipConfig
 
rem read current/already defined Git Config to see if theyre blank; not using --global flag!
for /F "delims=" i in ('git config user.name') do set currentGitConfigUser=i
for /F "delims=" i in ('git config user.password') do set currentGitConfigPassword=i
for /F "delims=" i in ('git config --get remote..url') do set currentGitConfigURL=i
 
if "!currentGitConfigUser!"==" " set "currentGitConfigUser="
if "!currentGitConfigPassword!"==" " set "currentGitConfigPassword="
if "!currentGitConfigURL!"==" " set "currentGitConfigURL="
if not "!gitConfigUser!"=="" (
if "!currentGitConfigUser!"=="" (
 
REM git config --global --replace-all "!gitConfigUser!"
)
)
)else (
git config user.password "!gitConfigPassword!"
)else (
 
:skipUserConfig
Echo.
Echo.
 
if not "!gitConfigURL!"=="" (
Exit
)
)
 
if not %errorlevel% == 0(
Pause > nul
if "~3^"==^"" (
) else (
goto invalidNumberLength
echo Continuing...
)
echo Press any key to exit.
pause > nul
exit
goto success
echo No branch name input provided. Pulling the 'main' branch.
set "branchToPull=main"
:wrongDirError
set "gitConfigRemoteName=origin"
)
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
if "G"=="gitConfigURL" (
set "gitConfigUser=H"
if "^"==^" " set "gitConfigPassword="
if "^"==^" " set "gitConfigURL="
rem Check if the string is a space character and set it to an empty variable; space is always appended >:-( though git should deal with these strings correctly nevertheless
if "^"==^" " set "gitConfigUser="
goto skipUserConfig
 
Echo Current User Name: "!currentGitConfigUser!"  Read User Name: "!gitConfigUser!"
Echo Current User PWD: "!currentGitConfigPassword!"  Read User PWD: "!gitConfigPassword!"
Echo.
Echo Pulling from Host with Name: "%gitConfigRemoteName%"
Echo Current URL under this Name: "!currentGitConfigURL!"  Read URL: "!gitConfigURL!"
)
echo Current local Git Username is not set -> new Name: "!gitConfigUser!"
git config user.name "!gitConfigUser!"
)else (
 
Echo.
 
if not "!gitConfigPassword!"=="" (
if "!currentGitConfigPassword!"=="" (
if /I "^"==^"y" (
Echo.
Echo.
 
if not "!gitConfigURL!"=="" (
echo get displayed
echo !gitConfigURL!
echo By continuing, Git will be set up here.
Echo Either Config.txt url was empty
goto wrongDirError
)
 
exit
Exit
 
REM 0==dont skip; 1==skip userConfig; >1==skip
if "^"==^"" (
echo No input remote repo name provided. Setting to default 'origin'.
set "gitConfigRemoteName=origin"
)
rem Read configurations from the config.txt file
for /F "tokens=1,* delims== " G in (config.txt) do (
 
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
if "G"=="gitConfigURL" (
set "gitConfigURL=H"
for /F "delims=" i in ('git config user.password') do set currentGitConfigPassword=i
for /F "delims=" i in ('git config --get remote..url') do set currentGitConfigURL=i
rem read current/already defined Git Config to see if theyre blank; not using --global flag!
goto skipConfig
if "!currentGitConfigURL!"==" " set "currentGitConfigURL="
 
echo Current local Git Username is not set -> new Name: "!gitConfigUser!"
:dontSkip
 
echo Current local Git Password is already set; if the overwriteGitConfigData flag is true the current Password: "!currentGitConfigPassword!" will be set to "!gitConfigPassword!"
Echo Current URL under this Name: "!currentGitConfigURL!"  Read URL: "!gitConfigURL!"
 
if "!currentGitConfigURL!"=="" (
echo Current local Git fetch URL is not set -> new URL: "!gitConfigURL!"
 
Echo.
 
if not %errorlevel% == 0(
REM git config --replace-all --global user.password "!gitConfigPassword!"
)
:invalidNumberLength
if not "!gitConfigURL!"=="" (
echo get displayed
echo !gitConfigURL!
echo "!currentGitConfigURL!"
 
if "!currentGitConfigURL!"=="" (
echo Current local Git fetch URL is not set -> new URL: "!gitConfigURL!"
git remote add  "!gitConfigURL!"
) else (
echo Current local Git fetch URL is already set; if the overwriteGitConfigData flag is true the current URL: "!currentGitConfigURL!" will be set to "!gitConfigURL!"
if "!overwriteGitConfigData!"=="true" (
git remote add !gitConfigRemoteName! "!gitConfigURL!" & Echo Overwriting successful; URL "!currentGitConfigURL!" changed to "!gitConfigURL!"
)
)
) else (
Echo Either Config.txt url was empty
)
:skipConfig
 
git pull %gitConfigRemoteName% %branchToPull%
 
 
if not %errorlevel% == 0(
Echo.
Echo Git ran into an Error when pulling.
Echo Have you committed your local changes?
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
Echo Resetting uncommited local changes ...
 
git reset --hard
git pull %gitConfigRemoteName% %branchToPull%
 
) else (
goto invalidNumberLength
)
) else (
:invalidNumberLength
Echo Aborting...
Echo.
Echo Press any key to exit.
Pause > nul
Exit
)
)
endlocal
@echo off
setlocal EnableDelayedExpansion
 
set "overwriteGitConfigData=true"
 
set "skipConfig=0"
REM 0==dont skip; 1==skip userConfig; >1==skip
 
 
where git >nul 2>nul && (
echo Git is installed.
) || (
start cmd.exe /k "color 4f & title Error & Echo. & Echo. & Echo Git is not properly installed! & Echo The installation will be canceled. If this is a mistake, remove the initial check from this batch file. & Echo Press any key to close this dialog & Pause > nul & Exit"
Echo Git environment variable wasnt found; Pulling will be canceled
Echo.
Echo Press any key to exit.
Pause > nul
Exit;
)
 
 
for /f i in ('git rev-parse --is-inside-work-tree 2^>^&1') do (
if /I "i"=="true" (
goto success
) else (
echo Current directory isn't a Git repository!
echo By continuing, Git will be set up here.
set /P "input=Press 'y' to continue and configure Git here; 'n' to abort this action: "
 
REM Check if the length of the input at 4th index is empty (3 chars or less) and if it starts with 'y'
set "choice=!input:~0,1!"
if /I "!choice!"=="y" (
if "!input:~3!"=="" (
echo Continuing...
echo Setting Git up in the current directory...
git init
) else (
goto wrongDirError
)
) else (
:wrongDirError
echo Aborting...
echo.
echo Press any key to exit.
pause > nul
exit
)
)
)
 
:success
Echo.
 
if ""=="" (
echo No branch name input provided. Pulling the 'main' branch.
set "branchToPull=main"
)
 
 
set "gitConfigRemoteName=%~2"
 
if "^"==^"" (
echo No input remote repo name provided. Setting to default 'origin'.
set "gitConfigRemoteName=origin"
)
rem Read configurations from the config.txt file
for /F "tokens=1,* delims== " G in (config.txt) do (
if "G"=="gitConfigUser" (
set "gitConfigUser=H"
if "!gitConfigUser!"=="" set "gitConfigUser="
)
if "G"=="gitConfigPassword" (
set "gitConfigPassword=H"
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
if "G"=="gitConfigURL" (
set "gitConfigURL=H"
if "!gitConfigURL!"=="" set "gitConfigURL="
)
)
rem Removing quotes from the config values
set "gitConfigUser=!gitConfigUser:"=!"
set "gitConfigPassword=!gitConfigPassword:"=!"
set "gitConfigURL=!gitConfigURL:"=!"
 
rem Check if the string is a space character and set it to an empty variable; space is always appended >:-( though git should deal with these strings correctly nevertheless
if "^"==^" " set "gitConfigUser="
if "^"==^" " set "gitConfigPassword="
if "^"==^" " set "gitConfigURL="
 
 
rem read current/already defined Git Config to see if theyre blank; not using --global flag!
for /F "delims=" i in ('git config user.name') do set currentGitConfigUser=i
for /F "delims=" i in ('git config user.password') do set currentGitConfigPassword=i
for /F "delims=" i in ('git config --get remote..url') do set currentGitConfigURL=i
 
if "!currentGitConfigUser!"==" " set "currentGitConfigUser="
if "!currentGitConfigPassword!"==" " set "currentGitConfigPassword="
if "!currentGitConfigURL!"==" " set "currentGitConfigURL="
 
if ==0 (
REM do nothing
goto dontSkip
) else if ==1 (
goto skipUserConfig
) else (
goto skipConfig
)
 
:dontSkip
 
REM set TAB="<TAB>"
set "TAB=   "
 
Echo Current User Name: "!currentGitConfigUser!"  Read User Name: "!gitConfigUser!"
Echo Current User PWD: "!currentGitConfigPassword!"  Read User PWD: "!gitConfigPassword!"
Echo.
Echo Pulling from Host with Name: "%gitConfigRemoteName%"
Echo Current URL under this Name: "!currentGitConfigURL!"  Read URL: "!gitConfigURL!"
 
Echo.
Echo.
 
if not "!gitConfigUser!"=="" (
if "!currentGitConfigUser!"=="" (
echo Current local Git Username is not set -> new Name: "!gitConfigUser!"
git config user.name "!gitConfigUser!"
)else (
echo Current local Git Username is already set; if the overwriteGitConfigData flag is true the current Username: "!currentGitConfigUser!" will be set to "!gitConfigUser!"
if "!overwriteGitConfigData!"=="true" (
git config user.name "!gitConfigUser!"&Echo Overwriting successful; Username "!currentGitConfigUser!" changed to "!gitConfigUser!"
REM git config --global --replace-all "!gitConfigUser!"
)
)
)
 
Echo.
Echo.
 
if not "!gitConfigPassword!"=="" (
if "!currentGitConfigPassword!"=="" (
echo Current local Git Password is not set -> new Password: "!gitConfigPassword!"
git config user.password "!gitConfigPassword!"
)else (
 
echo Current local Git Password is already set; if the overwriteGitConfigData flag is true the current Password: "!currentGitConfigPassword!" will be set to "!gitConfigPassword!"
if "!overwriteGitConfigData!"=="true" (
git config user.password "!gitConfigPassword!"&Echo Overwriting successful; Password "!currentGitConfigPassword!" changed to "!gitConfigPassword!"
REM git config --replace-all --global user.password "!gitConfigPassword!"
)
)
)
 
:skipUserConfig
Echo.
Echo.
 
if not "!gitConfigURL!"=="" (
echo get displayed
echo !gitConfigURL!
echo "!currentGitConfigURL!"
 
if "!currentGitConfigURL!"=="" (
echo Current local Git fetch URL is not set -> new URL: "!gitConfigURL!"
git remote add  "!gitConfigURL!"
) else (
echo Current local Git fetch URL is already set; if the overwriteGitConfigData flag is true the current URL: "!currentGitConfigURL!" will be set to "!gitConfigURL!"
if "!overwriteGitConfigData!"=="true" (
git remote add !gitConfigRemoteName! "!gitConfigURL!" & Echo Overwriting successful; URL "!currentGitConfigURL!" changed to "!gitConfigURL!"
)
)
) else (
Echo Either Config.txt url was empty
)
:skipConfig
 
git pull %gitConfigRemoteName% %branchToPull%
 
 
if not %errorlevel% == 0(
Echo.
Echo Git ran into an Error when pulling.
Echo Have you committed your local changes?
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
Echo Resetting uncommited local changes ...
 
git reset --hard
git pull %gitConfigRemoteName% %branchToPull%
 
) else (
goto invalidNumberLength
)
) else (
:invalidNumberLength
Echo Aborting...
Echo.
Echo Press any key to exit.
Pause > nul
Exit
)
)
endlocal
@echo off
setlocal EnableDelayedExpansion
 
set "overwriteGitConfigData=true"
 
set "skipConfig=0"
REM 0==dont skip; 1==skip userConfig; >1==skip
 
 
where git >nul 2>nul && (
echo Git is installed.
) || (
start cmd.exe /k "color 4f & title Error & Echo. & Echo. & Echo Git is not properly installed! & Echo The installation will be canceled. If this is a mistake, remove the initial check from this batch file. & Echo Press any key to close this dialog & Pause > nul & Exit"
Echo Git environment variable wasnt found; Pulling will be canceled
Echo.
Echo Press any key to exit.
Pause > nul
Exit;
)
 
 
for /f i in ('git rev-parse --is-inside-work-tree 2^>^&1') do (
if /I "i"=="true" (
goto success
) else (
echo Current directory isn't a Git repository!
echo By continuing, Git will be set up here.
set /P "input=Press 'y' to continue and configure Git here; 'n' to abort this action: "
 
REM Check if the length of the input at 4th index is empty (3 chars or less) and if it starts with 'y'
set "choice=!input:~0,1!"
if /I "!choice!"=="y" (
if "!input:~3!"=="" (
echo Continuing...
echo Setting Git up in the current directory...
git init
) else (
goto wrongDirError
)
) else (
:wrongDirError
echo Aborting...
echo.
echo Press any key to exit.
pause > nul
exit
)
)
)
 
:success
Echo.
 
if ""=="" (
echo No branch name input provided. Pulling the 'main' branch.
set "branchToPull=main"
)
 
 
set "gitConfigRemoteName=%~2"
 
if "^"==^"" (
echo No input remote repo name provided. Setting to default 'origin'.
set "gitConfigRemoteName=origin"
)
rem Read configurations from the config.txt file
for /F "tokens=1,* delims== " G in (config.txt) do (
if "G"=="gitConfigUser" (
set "gitConfigUser=H"
if "!gitConfigUser!"=="" set "gitConfigUser="
)
if "G"=="gitConfigPassword" (
set "gitConfigPassword=H"
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
if "G"=="gitConfigURL" (
set "gitConfigURL=H"
if "!gitConfigURL!"=="" set "gitConfigURL="
)
)
rem Removing quotes from the config values
set "gitConfigUser=!gitConfigUser:"=!"
set "gitConfigPassword=!gitConfigPassword:"=!"
set "gitConfigURL=!gitConfigURL:"=!"
 
rem Check if the string is a space character and set it to an empty variable; space is always appended >:-( though git should deal with these strings correctly nevertheless
if "^"==^" " set "gitConfigUser="
if "^"==^" " set "gitConfigPassword="
if "^"==^" " set "gitConfigURL="
 
 
rem read current/already defined Git Config to see if theyre blank; not using --global flag!
for /F "delims=" i in ('git config user.name') do set currentGitConfigUser=i
for /F "delims=" i in ('git config user.password') do set currentGitConfigPassword=i
for /F "delims=" i in ('git config --get remote..url') do set currentGitConfigURL=i
 
if "!currentGitConfigUser!"==" " set "currentGitConfigUser="
if "!currentGitConfigPassword!"==" " set "currentGitConfigPassword="
if "!currentGitConfigURL!"==" " set "currentGitConfigURL="
 
if ==0 (
REM do nothing
goto dontSkip
) else if ==1 (
goto skipUserConfig
) else (
goto skipConfig
)
 
:dontSkip
 
REM set TAB="<TAB>"
set "TAB=   "
 
Echo Current User Name: "!currentGitConfigUser!"  Read User Name: "!gitConfigUser!"
Echo Current User PWD: "!currentGitConfigPassword!"  Read User PWD: "!gitConfigPassword!"
Echo.
Echo Pulling from Host with Name: "%gitConfigRemoteName%"
Echo Current URL under this Name: "!currentGitConfigURL!"  Read URL: "!gitConfigURL!"
 
Echo.
Echo.
 
if not "!gitConfigUser!"=="" (
if "!currentGitConfigUser!"=="" (
echo Current local Git Username is not set -> new Name: "!gitConfigUser!"
git config user.name "!gitConfigUser!"
)else (
echo Current local Git Username is already set; if the overwriteGitConfigData flag is true the current Username: "!currentGitConfigUser!" will be set to "!gitConfigUser!"
if "!overwriteGitConfigData!"=="true" (
git config user.name "!gitConfigUser!"&Echo Overwriting successful; Username "!currentGitConfigUser!" changed to "!gitConfigUser!"
REM git config --global --replace-all "!gitConfigUser!"
)
)
)
 
Echo.
Echo.
 
if not "!gitConfigPassword!"=="" (
if "!currentGitConfigPassword!"=="" (
echo Current local Git Password is not set -> new Password: "!gitConfigPassword!"
git config user.password "!gitConfigPassword!"
)else (
 
echo Current local Git Password is already set; if the overwriteGitConfigData flag is true the current Password: "!currentGitConfigPassword!" will be set to "!gitConfigPassword!"
if "!overwriteGitConfigData!"=="true" (
git config user.password "!gitConfigPassword!"&Echo Overwriting successful; Password "!currentGitConfigPassword!" changed to "!gitConfigPassword!"
REM git config --replace-all --global user.password "!gitConfigPassword!"
)
)
)
 
:skipUserConfig
Echo.
Echo.
 
if not "!gitConfigURL!"=="" (
echo get displayed
echo !gitConfigURL!
echo "!currentGitConfigURL!"
 
if "!currentGitConfigURL!"=="" (
echo Current local Git fetch URL is not set -> new URL: "!gitConfigURL!"
git remote add  "!gitConfigURL!"
) else (
echo Current local Git fetch URL is already set; if the overwriteGitConfigData flag is true the current URL: "!currentGitConfigURL!" will be set to "!gitConfigURL!"
if "!overwriteGitConfigData!"=="true" (
git remote add !gitConfigRemoteName! "!gitConfigURL!" & Echo Overwriting successful; URL "!currentGitConfigURL!" changed to "!gitConfigURL!"
)
)
) else (
Echo Either Config.txt url was empty
)
:skipConfig
 
git pull %gitConfigRemoteName% %branchToPull%
 
 
if not %errorlevel% == 0(
Echo.
Echo Git ran into an Error when pulling.
Echo Have you committed your local changes?
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
Echo Resetting uncommited local changes ...
 
git reset --hard
git pull %gitConfigRemoteName% %branchToPull%
 
) else (
goto invalidNumberLength
)
) else (
:invalidNumberLength
Echo Aborting...
Echo.
Echo Press any key to exit.
Pause > nul
Exit
)
)
endlocal
@echo off
setlocal EnableDelayedExpansion
 
set "overwriteGitConfigData=true"
 
set "skipConfig=0"
REM 0==dont skip; 1==skip userConfig; >1==skip
 
 
where git >nul 2>nul && (
echo Git is installed.
) || (
start cmd.exe /k "color 4f & title Error & Echo. & Echo. & Echo Git is not properly installed! & Echo The installation will be canceled. If this is a mistake, remove the initial check from this batch file. & Echo Press any key to close this dialog & Pause > nul & Exit"
Echo Git environment variable wasnt found; Pulling will be canceled
Echo.
Echo Press any key to exit.
Pause > nul
Exit;
)
 
 
for /f i in ('git rev-parse --is-inside-work-tree 2^>^&1') do (
if /I "i"=="true" (
goto success
) else (
echo Current directory isn't a Git repository!
echo By continuing, Git will be set up here.
set /P "input=Press 'y' to continue and configure Git here; 'n' to abort this action: "
 
REM Check if the length of the input at 4th index is empty (3 chars or less) and if it starts with 'y'
set "choice=!input:~0,1!"
if /I "!choice!"=="y" (
if "!input:~3!"=="" (
echo Continuing...
echo Setting Git up in the current directory...
git init
) else (
goto wrongDirError
)
) else (
:wrongDirError
echo Aborting...
echo.
echo Press any key to exit.
pause > nul
exit
)
)
)
 
:success
Echo.
 
if ""=="" (
echo No branch name input provided. Pulling the 'main' branch.
set "branchToPull=main"
)
 
 
set "gitConfigRemoteName=%~2"
 
if "^"==^"" (
echo No input remote repo name provided. Setting to default 'origin'.
set "gitConfigRemoteName=origin"
)
rem Read configurations from the config.txt file
for /F "tokens=1,* delims== " G in (config.txt) do (
if "G"=="gitConfigUser" (
set "gitConfigUser=H"
if "!gitConfigUser!"=="" set "gitConfigUser="
)
if "G"=="gitConfigPassword" (
set "gitConfigPassword=H"
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
if "G"=="gitConfigURL" (
set "gitConfigURL=H"
if "!gitConfigURL!"=="" set "gitConfigURL="
)
)
rem Removing quotes from the config values
set "gitConfigUser=!gitConfigUser:"=!"
set "gitConfigPassword=!gitConfigPassword:"=!"
set "gitConfigURL=!gitConfigURL:"=!"
 
rem Check if the string is a space character and set it to an empty variable; space is always appended >:-( though git should deal with these strings correctly nevertheless
if "^"==^" " set "gitConfigUser="
if "^"==^" " set "gitConfigPassword="
if "^"==^" " set "gitConfigURL="
 
 
rem read current/already defined Git Config to see if theyre blank; not using --global flag!
for /F "delims=" i in ('git config user.name') do set currentGitConfigUser=i
for /F "delims=" i in ('git config user.password') do set currentGitConfigPassword=i
for /F "delims=" i in ('git config --get remote..url') do set currentGitConfigURL=i
 
if "!currentGitConfigUser!"==" " set "currentGitConfigUser="
if "!currentGitConfigPassword!"==" " set "currentGitConfigPassword="
if "!currentGitConfigURL!"==" " set "currentGitConfigURL="
 
if ==0 (
REM do nothing
goto dontSkip
) else if ==1 (
goto skipUserConfig
) else (
goto skipConfig
)
 
:dontSkip
 
REM set TAB="<TAB>"
set "TAB=   "
 
Echo Current User Name: "!currentGitConfigUser!"  Read User Name: "!gitConfigUser!"
Echo Current User PWD: "!currentGitConfigPassword!"  Read User PWD: "!gitConfigPassword!"
Echo.
Echo Pulling from Host with Name: "%gitConfigRemoteName%"
Echo Current URL under this Name: "!currentGitConfigURL!"  Read URL: "!gitConfigURL!"
 
Echo.
Echo.
 
if not "!gitConfigUser!"=="" (
if "!currentGitConfigUser!"=="" (
echo Current local Git Username is not set -> new Name: "!gitConfigUser!"
git config user.name "!gitConfigUser!"
)else (
echo Current local Git Username is already set; if the overwriteGitConfigData flag is true the current Username: "!currentGitConfigUser!" will be set to "!gitConfigUser!"
if "!overwriteGitConfigData!"=="true" (
git config user.name "!gitConfigUser!"&Echo Overwriting successful; Username "!currentGitConfigUser!" changed to "!gitConfigUser!"
REM git config --global --replace-all "!gitConfigUser!"
)
)
)
 
Echo.
Echo.
 
if not "!gitConfigPassword!"=="" (
if "!currentGitConfigPassword!"=="" (
echo Current local Git Password is not set -> new Password: "!gitConfigPassword!"
git config user.password "!gitConfigPassword!"
)else (
 
echo Current local Git Password is already set; if the overwriteGitConfigData flag is true the current Password: "!currentGitConfigPassword!" will be set to "!gitConfigPassword!"
if "!overwriteGitConfigData!"=="true" (
git config user.password "!gitConfigPassword!"&Echo Overwriting successful; Password "!currentGitConfigPassword!" changed to "!gitConfigPassword!"
REM git config --replace-all --global user.password "!gitConfigPassword!"
)
)
)
 
:skipUserConfig
Echo.
Echo.
 
if not "!gitConfigURL!"=="" (
echo get displayed
echo !gitConfigURL!
echo "!currentGitConfigURL!"
 
if "!currentGitConfigURL!"=="" (
echo Current local Git fetch URL is not set -> new URL: "!gitConfigURL!"
git remote add  "!gitConfigURL!"
) else (
echo Current local Git fetch URL is already set; if the overwriteGitConfigData flag is true the current URL: "!currentGitConfigURL!" will be set to "!gitConfigURL!"
if "!overwriteGitConfigData!"=="true" (
git remote add !gitConfigRemoteName! "!gitConfigURL!" & Echo Overwriting successful; URL "!currentGitConfigURL!" changed to "!gitConfigURL!"
)
)
) else (
Echo Either Config.txt url was empty
)
:skipConfig
 
git pull %gitConfigRemoteName% %branchToPull%
 
 
if not %errorlevel% == 0(
Echo.
Echo Git ran into an Error when pulling.
Echo Have you committed your local changes?
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
Echo Resetting uncommited local changes ...
 
git reset --hard
git pull %gitConfigRemoteName% %branchToPull%
 
) else (
goto invalidNumberLength
)
) else (
:invalidNumberLength
Echo Aborting...
Echo.
Echo Press any key to exit.
Pause > nul
Exit
)
)
endlocal
@echo off
setlocal EnableDelayedExpansion
 
set "overwriteGitConfigData=true"
 
set "skipConfig=0"
REM 0==dont skip; 1==skip userConfig; >1==skip
 
 
where git >nul 2>nul && (
echo Git is installed.
) || (
start cmd.exe /k "color 4f & title Error & Echo. & Echo. & Echo Git is not properly installed! & Echo The installation will be canceled. If this is a mistake, remove the initial check from this batch file. & Echo Press any key to close this dialog & Pause > nul & Exit"
Echo Git environment variable wasnt found; Pulling will be canceled
Echo.
Echo Press any key to exit.
Pause > nul
Exit;
)
 
 
for /f i in ('git rev-parse --is-inside-work-tree 2^>^&1') do (
if /I "i"=="true" (
goto success
) else (
echo Current directory isn't a Git repository!
echo By continuing, Git will be set up here.
set /P "input=Press 'y' to continue and configure Git here; 'n' to abort this action: "
 
REM Check if the length of the input at 4th index is empty (3 chars or less) and if it starts with 'y'
set "choice=!input:~0,1!"
if /I "!choice!"=="y" (
if "!input:~3!"=="" (
echo Continuing...
echo Setting Git up in the current directory...
git init
) else (
goto wrongDirError
)
) else (
:wrongDirError
echo Aborting...
echo.
echo Press any key to exit.
pause > nul
exit
)
)
)
 
:success
Echo.
 
if ""=="" (
echo No branch name input provided. Pulling the 'main' branch.
set "branchToPull=main"
)
 
 
set "gitConfigRemoteName=%~2"
 
if "^"==^"" (
echo No input remote repo name provided. Setting to default 'origin'.
set "gitConfigRemoteName=origin"
)
rem Read configurations from the config.txt file
for /F "tokens=1,* delims== " G in (config.txt) do (
if "G"=="gitConfigUser" (
set "gitConfigUser=H"
if "!gitConfigUser!"=="" set "gitConfigUser="
)
if "G"=="gitConfigPassword" (
set "gitConfigPassword=H"
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
if "G"=="gitConfigURL" (
set "gitConfigURL=H"
if "!gitConfigURL!"=="" set "gitConfigURL="
)
)
rem Removing quotes from the config values
set "gitConfigUser=!gitConfigUser:"=!"
set "gitConfigPassword=!gitConfigPassword:"=!"
set "gitConfigURL=!gitConfigURL:"=!"
 
rem Check if the string is a space character and set it to an empty variable; space is always appended >:-( though git should deal with these strings correctly nevertheless
if "^"==^" " set "gitConfigUser="
if "^"==^" " set "gitConfigPassword="
if "^"==^" " set "gitConfigURL="
 
 
rem read current/already defined Git Config to see if theyre blank; not using --global flag!
for /F "delims=" i in ('git config user.name') do set currentGitConfigUser=i
for /F "delims=" i in ('git config user.password') do set currentGitConfigPassword=i
for /F "delims=" i in ('git config --get remote..url') do set currentGitConfigURL=i
 
if "!currentGitConfigUser!"==" " set "currentGitConfigUser="
if "!currentGitConfigPassword!"==" " set "currentGitConfigPassword="
if "!currentGitConfigURL!"==" " set "currentGitConfigURL="
 
if ==0 (
REM do nothing
goto dontSkip
) else if ==1 (
goto skipUserConfig
) else (
goto skipConfig
)
 
:dontSkip
 
REM set TAB="<TAB>"
set "TAB=   "
 
Echo Current User Name: "!currentGitConfigUser!"  Read User Name: "!gitConfigUser!"
Echo Current User PWD: "!currentGitConfigPassword!"  Read User PWD: "!gitConfigPassword!"
Echo.
Echo Pulling from Host with Name: "%gitConfigRemoteName%"
Echo Current URL under this Name: "!currentGitConfigURL!"  Read URL: "!gitConfigURL!"
 
Echo.
Echo.
 
if not "!gitConfigUser!"=="" (
if "!currentGitConfigUser!"=="" (
echo Current local Git Username is not set -> new Name: "!gitConfigUser!"
git config user.name "!gitConfigUser!"
)else (
echo Current local Git Username is already set; if the overwriteGitConfigData flag is true the current Username: "!currentGitConfigUser!" will be set to "!gitConfigUser!"
if "!overwriteGitConfigData!"=="true" (
git config user.name "!gitConfigUser!"&Echo Overwriting successful; Username "!currentGitConfigUser!" changed to "!gitConfigUser!"
REM git config --global --replace-all "!gitConfigUser!"
)
)
)
 
Echo.
Echo.
 
if not "!gitConfigPassword!"=="" (
if "!currentGitConfigPassword!"=="" (
echo Current local Git Password is not set -> new Password: "!gitConfigPassword!"
git config user.password "!gitConfigPassword!"
)else (
 
echo Current local Git Password is already set; if the overwriteGitConfigData flag is true the current Password: "!currentGitConfigPassword!" will be set to "!gitConfigPassword!"
if "!overwriteGitConfigData!"=="true" (
git config user.password "!gitConfigPassword!"&Echo Overwriting successful; Password "!currentGitConfigPassword!" changed to "!gitConfigPassword!"
REM git config --replace-all --global user.password "!gitConfigPassword!"
)
)
)
 
:skipUserConfig
Echo.
Echo.
 
if not "!gitConfigURL!"=="" (
echo get displayed
echo !gitConfigURL!
echo "!currentGitConfigURL!"
 
if "!currentGitConfigURL!"=="" (
echo Current local Git fetch URL is not set -> new URL: "!gitConfigURL!"
git remote add  "!gitConfigURL!"
) else (
echo Current local Git fetch URL is already set; if the overwriteGitConfigData flag is true the current URL: "!currentGitConfigURL!" will be set to "!gitConfigURL!"
if "!overwriteGitConfigData!"=="true" (
git remote add !gitConfigRemoteName! "!gitConfigURL!" & Echo Overwriting successful; URL "!currentGitConfigURL!" changed to "!gitConfigURL!"
)
)
) else (
Echo Either Config.txt url was empty
)
:skipConfig
 
git pull %gitConfigRemoteName% %branchToPull%
 
 
if not %errorlevel% == 0(
Echo.
Echo Git ran into an Error when pulling.
Echo Have you committed your local changes?
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
Echo Resetting uncommited local changes ...
 
git reset --hard
git pull %gitConfigRemoteName% %branchToPull%
 
) else (
goto invalidNumberLength
)
) else (
:invalidNumberLength
Echo Aborting...
Echo.
Echo Press any key to exit.
Pause > nul
Exit
)
)
endlocal
@echo off
setlocal EnableDelayedExpansion
 
set "overwriteGitConfigData=true"
 
set "skipConfig=0"
REM 0==dont skip; 1==skip userConfig; >1==skip
 
 
where git >nul 2>nul && (
echo Git is installed.
) || (
start cmd.exe /k "color 4f & title Error & Echo. & Echo. & Echo Git is not properly installed! & Echo The installation will be canceled. If this is a mistake, remove the initial check from this batch file. & Echo Press any key to close this dialog & Pause > nul & Exit"
Echo Git environment variable wasnt found; Pulling will be canceled
Echo.
Echo Press any key to exit.
Pause > nul
Exit;
)
 
 
for /f i in ('git rev-parse --is-inside-work-tree 2^>^&1') do (
if /I "i"=="true" (
goto success
) else (
echo Current directory isn't a Git repository!
echo By continuing, Git will be set up here.
set /P "input=Press 'y' to continue and configure Git here; 'n' to abort this action: "
 
REM Check if the length of the input at 4th index is empty (3 chars or less) and if it starts with 'y'
set "choice=!input:~0,1!"
if /I "!choice!"=="y" (
if "!input:~3!"=="" (
echo Continuing...
echo Setting Git up in the current directory...
git init
) else (
goto wrongDirError
)
) else (
:wrongDirError
echo Aborting...
echo.
echo Press any key to exit.
pause > nul
exit
)
)
)
 
:success
Echo.
 
if ""=="" (
echo No branch name input provided. Pulling the 'main' branch.
set "branchToPull=main"
)
 
 
set "gitConfigRemoteName=%~2"
 
if "^"==^"" (
echo No input remote repo name provided. Setting to default 'origin'.
set "gitConfigRemoteName=origin"
)
rem Read configurations from the config.txt file
for /F "tokens=1,* delims== " G in (config.txt) do (
if "G"=="gitConfigUser" (
set "gitConfigUser=H"
if "!gitConfigUser!"=="" set "gitConfigUser="
)
if "G"=="gitConfigPassword" (
set "gitConfigPassword=H"
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
if "G"=="gitConfigURL" (
set "gitConfigURL=H"
if "!gitConfigURL!"=="" set "gitConfigURL="
)
)
rem Removing quotes from the config values
set "gitConfigUser=!gitConfigUser:"=!"
set "gitConfigPassword=!gitConfigPassword:"=!"
set "gitConfigURL=!gitConfigURL:"=!"
 
rem Check if the string is a space character and set it to an empty variable; space is always appended >:-( though git should deal with these strings correctly nevertheless
if "^"==^" " set "gitConfigUser="
if "^"==^" " set "gitConfigPassword="
if "^"==^" " set "gitConfigURL="
 
 
rem read current/already defined Git Config to see if theyre blank; not using --global flag!
for /F "delims=" i in ('git config user.name') do set currentGitConfigUser=i
for /F "delims=" i in ('git config user.password') do set currentGitConfigPassword=i
for /F "delims=" i in ('git config --get remote..url') do set currentGitConfigURL=i
 
if "!currentGitConfigUser!"==" " set "currentGitConfigUser="
if "!currentGitConfigPassword!"==" " set "currentGitConfigPassword="
if "!currentGitConfigURL!"==" " set "currentGitConfigURL="
 
if ==0 (
REM do nothing
goto dontSkip
) else if ==1 (
goto skipUserConfig
) else (
goto skipConfig
)
 
:dontSkip
 
REM set TAB="<TAB>"
set "TAB=   "
 
Echo Current User Name: "!currentGitConfigUser!"  Read User Name: "!gitConfigUser!"
Echo Current User PWD: "!currentGitConfigPassword!"  Read User PWD: "!gitConfigPassword!"
Echo.
Echo Pulling from Host with Name: "%gitConfigRemoteName%"
Echo Current URL under this Name: "!currentGitConfigURL!"  Read URL: "!gitConfigURL!"
 
Echo.
Echo.
 
if not "!gitConfigUser!"=="" (
if "!currentGitConfigUser!"=="" (
echo Current local Git Username is not set -> new Name: "!gitConfigUser!"
git config user.name "!gitConfigUser!"
)else (
echo Current local Git Username is already set; if the overwriteGitConfigData flag is true the current Username: "!currentGitConfigUser!" will be set to "!gitConfigUser!"
if "!overwriteGitConfigData!"=="true" (
git config user.name "!gitConfigUser!"&Echo Overwriting successful; Username "!currentGitConfigUser!" changed to "!gitConfigUser!"
REM git config --global --replace-all "!gitConfigUser!"
)
)
)
 
Echo.
Echo.
 
if not "!gitConfigPassword!"=="" (
if "!currentGitConfigPassword!"=="" (
echo Current local Git Password is not set -> new Password: "!gitConfigPassword!"
git config user.password "!gitConfigPassword!"
)else (
 
echo Current local Git Password is already set; if the overwriteGitConfigData flag is true the current Password: "!currentGitConfigPassword!" will be set to "!gitConfigPassword!"
if "!overwriteGitConfigData!"=="true" (
git config user.password "!gitConfigPassword!"&Echo Overwriting successful; Password "!currentGitConfigPassword!" changed to "!gitConfigPassword!"
REM git config --replace-all --global user.password "!gitConfigPassword!"
)
)
)
 
:skipUserConfig
Echo.
Echo.
 
if not "!gitConfigURL!"=="" (
echo get displayed
echo !gitConfigURL!
echo "!currentGitConfigURL!"
 
if "!currentGitConfigURL!"=="" (
echo Current local Git fetch URL is not set -> new URL: "!gitConfigURL!"
git remote add  "!gitConfigURL!"
) else (
echo Current local Git fetch URL is already set; if the overwriteGitConfigData flag is true the current URL: "!currentGitConfigURL!" will be set to "!gitConfigURL!"
if "!overwriteGitConfigData!"=="true" (
git remote add !gitConfigRemoteName! "!gitConfigURL!" & Echo Overwriting successful; URL "!currentGitConfigURL!" changed to "!gitConfigURL!"
)
)
) else (
Echo Either Config.txt url was empty
)
:skipConfig
 
git pull %gitConfigRemoteName% %branchToPull%
 
 
if not %errorlevel% == 0(
Echo.
Echo Git ran into an Error when pulling.
Echo Have you committed your local changes?
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
Echo Resetting uncommited local changes ...
 
git reset --hard
git pull %gitConfigRemoteName% %branchToPull%
 
) else (
goto invalidNumberLength
)
) else (
:invalidNumberLength
Echo Aborting...
Echo.
Echo Press any key to exit.
Pause > nul
Exit
)
)
endlocal
@echo off
setlocal EnableDelayedExpansion
 
set "overwriteGitConfigData=true"
 
set "skipConfig=0"
REM 0==dont skip; 1==skip userConfig; >1==skip
 
 
where git >nul 2>nul && (
echo Git is installed.
) || (
start cmd.exe /k "color 4f & title Error & Echo. & Echo. & Echo Git is not properly installed! & Echo The installation will be canceled. If this is a mistake, remove the initial check from this batch file. & Echo Press any key to close this dialog & Pause > nul & Exit"
Echo Git environment variable wasnt found; Pulling will be canceled
Echo.
Echo Press any key to exit.
Pause > nul
Exit;
)
 
 
for /f i in ('git rev-parse --is-inside-work-tree 2^>^&1') do (
if /I "i"=="true" (
goto success
) else (
echo Current directory isn't a Git repository!
echo By continuing, Git will be set up here.
set /P "input=Press 'y' to continue and configure Git here; 'n' to abort this action: "
 
REM Check if the length of the input at 4th index is empty (3 chars or less) and if it starts with 'y'
set "choice=!input:~0,1!"
if /I "!choice!"=="y" (
if "!input:~3!"=="" (
echo Continuing...
echo Setting Git up in the current directory...
git init
) else (
goto wrongDirError
)
) else (
:wrongDirError
echo Aborting...
echo.
echo Press any key to exit.
pause > nul
exit
)
)
)
 
:success
Echo.
 
if ""=="" (
echo No branch name input provided. Pulling the 'main' branch.
set "branchToPull=main"
)
 
 
set "gitConfigRemoteName=%~2"
 
if "^"==^"" (
echo No input remote repo name provided. Setting to default 'origin'.
set "gitConfigRemoteName=origin"
)
rem Read configurations from the config.txt file
for /F "tokens=1,* delims== " G in (config.txt) do (
if "G"=="gitConfigUser" (
set "gitConfigUser=H"
if "!gitConfigUser!"=="" set "gitConfigUser="
)
if "G"=="gitConfigPassword" (
set "gitConfigPassword=H"
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
if "G"=="gitConfigURL" (
set "gitConfigURL=H"
if "!gitConfigURL!"=="" set "gitConfigURL="
)
)
rem Removing quotes from the config values
set "gitConfigUser=!gitConfigUser:"=!"
set "gitConfigPassword=!gitConfigPassword:"=!"
set "gitConfigURL=!gitConfigURL:"=!"
 
rem Check if the string is a space character and set it to an empty variable; space is always appended >:-( though git should deal with these strings correctly nevertheless
if "^"==^" " set "gitConfigUser="
if "^"==^" " set "gitConfigPassword="
if "^"==^" " set "gitConfigURL="
 
 
rem read current/already defined Git Config to see if theyre blank; not using --global flag!
for /F "delims=" i in ('git config user.name') do set currentGitConfigUser=i
for /F "delims=" i in ('git config user.password') do set currentGitConfigPassword=i
for /F "delims=" i in ('git config --get remote..url') do set currentGitConfigURL=i
 
if "!currentGitConfigUser!"==" " set "currentGitConfigUser="
if "!currentGitConfigPassword!"==" " set "currentGitConfigPassword="
if "!currentGitConfigURL!"==" " set "currentGitConfigURL="
 
if ==0 (
REM do nothing
goto dontSkip
) else if ==1 (
goto skipUserConfig
) else (
goto skipConfig
)
 
:dontSkip
 
REM set TAB="<TAB>"
set "TAB=   "
 
Echo Current User Name: "!currentGitConfigUser!"  Read User Name: "!gitConfigUser!"
Echo Current User PWD: "!currentGitConfigPassword!"  Read User PWD: "!gitConfigPassword!"
Echo.
Echo Pulling from Host with Name: "%gitConfigRemoteName%"
Echo Current URL under this Name: "!currentGitConfigURL!"  Read URL: "!gitConfigURL!"
 
Echo.
Echo.
 
if not "!gitConfigUser!"=="" (
if "!currentGitConfigUser!"=="" (
echo Current local Git Username is not set -> new Name: "!gitConfigUser!"
git config user.name "!gitConfigUser!"
)else (
echo Current local Git Username is already set; if the overwriteGitConfigData flag is true the current Username: "!currentGitConfigUser!" will be set to "!gitConfigUser!"
if "!overwriteGitConfigData!"=="true" (
git config user.name "!gitConfigUser!"&Echo Overwriting successful; Username "!currentGitConfigUser!" changed to "!gitConfigUser!"
REM git config --global --replace-all "!gitConfigUser!"
)
)
)
 
Echo.
Echo.
 
if not "!gitConfigPassword!"=="" (
if "!currentGitConfigPassword!"=="" (
echo Current local Git Password is not set -> new Password: "!gitConfigPassword!"
git config user.password "!gitConfigPassword!"
)else (
 
echo Current local Git Password is already set; if the overwriteGitConfigData flag is true the current Password: "!currentGitConfigPassword!" will be set to "!gitConfigPassword!"
if "!overwriteGitConfigData!"=="true" (
git config user.password "!gitConfigPassword!"&Echo Overwriting successful; Password "!currentGitConfigPassword!" changed to "!gitConfigPassword!"
REM git config --replace-all --global user.password "!gitConfigPassword!"
)
)
)
 
:skipUserConfig
Echo.
Echo.
 
if not "!gitConfigURL!"=="" (
echo get displayed
echo !gitConfigURL!
echo "!currentGitConfigURL!"
 
if "!currentGitConfigURL!"=="" (
echo Current local Git fetch URL is not set -> new URL: "!gitConfigURL!"
git remote add  "!gitConfigURL!"
) else (
echo Current local Git fetch URL is already set; if the overwriteGitConfigData flag is true the current URL: "!currentGitConfigURL!" will be set to "!gitConfigURL!"
if "!overwriteGitConfigData!"=="true" (
git remote add !gitConfigRemoteName! "!gitConfigURL!" & Echo Overwriting successful; URL "!currentGitConfigURL!" changed to "!gitConfigURL!"
)
)
) else (
Echo Either Config.txt url was empty
)
:skipConfig
 
git pull %gitConfigRemoteName% %branchToPull%
 
 
if not %errorlevel% == 0(
Echo.
Echo Git ran into an Error when pulling.
Echo Have you committed your local changes?
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
Echo Resetting uncommited local changes ...
 
git reset --hard
git pull %gitConfigRemoteName% %branchToPull%
 
) else (
goto invalidNumberLength
)
) else (
:invalidNumberLength
Echo Aborting...
Echo.
Echo Press any key to exit.
Pause > nul
Exit
)
)
endlocal
@echo off
setlocal EnableDelayedExpansion
 
set "overwriteGitConfigData=true"
 
set "skipConfig=0"
REM 0==dont skip; 1==skip userConfig; >1==skip
 
 
where git >nul 2>nul && (
echo Git is installed.
) || (
start cmd.exe /k "color 4f & title Error & Echo. & Echo. & Echo Git is not properly installed! & Echo The installation will be canceled. If this is a mistake, remove the initial check from this batch file. & Echo Press any key to close this dialog & Pause > nul & Exit"
 
Echo Press any key to exit.
Pause > nul
set "choice=!input:~0,1!"
git init
) else (
exit
)
)
 
 
)
 
)
)
rem Read configurations from the config.txt file
 
for /F "tokens=1,* delims== " G in (config.txt) do (
set "gitConfigPassword=H"
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
set "gitConfigURL=H"
if "!gitConfigURL!"=="" set "gitConfigURL="
)
)
rem Check if the string is a space character and set it to an empty variable; space is always appended >:-( though git should deal with these strings correctly nevertheless
set "gitConfigUser=!gitConfigUser:"=!"
set "gitConfigPassword=!gitConfigPassword:"=!"
 
if "^"==^" " set "gitConfigUser="
if "!currentGitConfigPassword!"==" " set "currentGitConfigPassword="
 
rem read current/already defined Git Config to see if theyre blank; not using --global flag!
)
 
:dontSkip
 
if ==0 (
REM do nothing
goto dontSkip
git config user.name "!gitConfigUser!"&Echo Overwriting successful; Username "!currentGitConfigUser!" changed to "!gitConfigUser!"
REM git config --global --replace-all "!gitConfigUser!"
)
if "!currentGitConfigUser!"=="" (
if not "!gitConfigPassword!"=="" (
REM git config --global --replace-all "!gitConfigUser!"
REM git config --replace-all --global user.password "!gitConfigPassword!"
 
if not "!gitConfigPassword!"=="" (
if "!currentGitConfigURL!"=="" (
echo Current local Git fetch URL is not set -> new URL: "!gitConfigURL!"
Echo.
Echo Either Config.txt url was empty
)
)
)
) else (
Pause > nul
Echo Git ran into an Error when pulling.
Echo Have you committed your local changes?
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
pause > nul
exit
)
 
where git >nul 2>nul && (
rem Read configurations from the config.txt file
)
 
set "gitConfigPassword=!gitConfigPassword:"=!"
set "gitConfigURL=!gitConfigURL:"=!"
 
rem Check if the string is a space character and set it to an empty variable; space is always appended >:-( though git should deal with these strings correctly nevertheless
if ""=="" (
echo No branch name input provided. Pulling the 'main' branch.
set "branchToPull=main"
 
rem Read configurations from the config.txt file
for /F "tokens=1,* delims== " G in (config.txt) do (
)else (
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
 
Echo.
Echo.
 
if "!overwriteGitConfigData!"=="true" (
git config user.password "!gitConfigPassword!"&Echo Overwriting successful; Password "!currentGitConfigPassword!" changed to "!gitConfigPassword!"
Echo.
Echo Pulling from Host with Name: "%gitConfigRemoteName%"
Echo Current URL under this Name: "!currentGitConfigURL!"  Read URL: "!gitConfigURL!"
:skipConfig
)else (
echo Current local Git Username is already set; if the overwriteGitConfigData flag is true the current Username: "!currentGitConfigUser!" will be set to "!gitConfigUser!"
if "!overwriteGitConfigData!"=="true" (
Echo Press any key to exit.
Pause > nul
Exit
)
)
endlocal
Echo.
 
where git >nul 2>nul && (
echo Git is installed.
) || (
) || (
for /f i in ('git rev-parse --is-inside-work-tree 2^>^&1') do (
if /I "i"=="true" (
echo By continuing, Git will be set up here.
set "choice=!input:~0,1!"
git init
)
exit
)
)
echo No input remote repo name provided. Setting to default 'origin'.
set "gitConfigRemoteName=origin"
if "G"=="gitConfigUser" (
set "gitConfigUser=H"
if "!gitConfigUser!"=="" set "gitConfigUser="
 
rem read current/already defined Git Config to see if theyre blank; not using --global flag!
rem Check if the string is a space character and set it to an empty variable; space is always appended >:-( though git should deal with these strings correctly nevertheless
if "^"==^" " set "gitConfigUser="
goto skipConfig
)
) else (
Echo Pulling from Host with Name: "%gitConfigRemoteName%"
Echo Current URL under this Name: "!currentGitConfigURL!"  Read URL: "!gitConfigURL!"
if not "!gitConfigUser!"=="" (
if "!currentGitConfigUser!"=="" (
)
)
)
 
Echo.
echo "!currentGitConfigURL!"
echo Current local Git Password is already set; if the overwriteGitConfigData flag is true the current Password: "!currentGitConfigPassword!" will be set to "!gitConfigPassword!"
if "!overwriteGitConfigData!"=="true" (
git config user.password "!gitConfigPassword!"&Echo Overwriting successful; Password "!currentGitConfigPassword!" changed to "!gitConfigPassword!"
 
git reset --hard
git pull %gitConfigRemoteName% %branchToPull%
 
Pause > nul
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
echo Current directory isn't a Git repository!
:invalidNumberLength
echo Setting Git up in the current directory...
git init
 
where git >nul 2>nul && (
 
)
 
)
set /P "input=Press 'y' to continue and configure Git here; 'n' to abort this action: "
 
REM Check if the length of the input at 4th index is empty (3 chars or less) and if it starts with 'y'
set "choice=!input:~0,1!"
REM do nothing
pause > nul
 
 
set "gitConfigRemoteName=%~2"
git config user.name "!gitConfigUser!"
if "G"=="gitConfigPassword" (
set "gitConfigPassword=H"
Echo.
Echo.
 
if not "!gitConfigPassword!"=="" (
if ==0 (
)else (
 
echo Current local Git Password is already set; if the overwriteGitConfigData flag is true the current Password: "!currentGitConfigPassword!" will be set to "!gitConfigPassword!"
if "!overwriteGitConfigData!"=="true" (
)else (
echo Current local Git Username is already set; if the overwriteGitConfigData flag is true the current Username: "!currentGitConfigUser!" will be set to "!gitConfigUser!"
 
if not "!gitConfigURL!"=="" (
git config user.password "!gitConfigPassword!"&Echo Overwriting successful; Password "!currentGitConfigPassword!" changed to "!gitConfigPassword!"
REM git config --replace-all --global user.password "!gitConfigPassword!"
)
)
)
 
:skipUserConfig
Echo.
Echo.
 
if not "!gitConfigURL!"=="" (
echo get displayed
echo !gitConfigURL!
echo "!currentGitConfigURL!"
 
if "!currentGitConfigURL!"=="" (
echo Current local Git fetch URL is not set -> new URL: "!gitConfigURL!"
git remote add  "!gitConfigURL!"
) else (
echo Current local Git fetch URL is already set; if the overwriteGitConfigData flag is true the current URL: "!currentGitConfigURL!" will be set to "!gitConfigURL!"
if "!overwriteGitConfigData!"=="true" (
git remote add !gitConfigRemoteName! "!gitConfigURL!" & Echo Overwriting successful; URL "!currentGitConfigURL!" changed to "!gitConfigURL!"
)
)
) else (
Echo Either Config.txt url was empty
)
:skipConfig
 
git pull %gitConfigRemoteName% %branchToPull%
 
 
if not %errorlevel% == 0(
Echo.
Echo Git ran into an Error when pulling.
Echo Have you committed your local changes?
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
Echo Resetting uncommited local changes ...
 
git reset --hard
git pull %gitConfigRemoteName% %branchToPull%
 
) else (
goto invalidNumberLength
)
) else (
:invalidNumberLength
Echo Aborting...
Echo.
Echo Press any key to exit.
Pause > nul
Exit
)
)
endlocal
@echo off
setlocal EnableDelayedExpansion
 
set "overwriteGitConfigData=true"
 
set "skipConfig=0"
REM 0==dont skip; 1==skip userConfig; >1==skip
 
 
where git >nul 2>nul && (
echo Git is installed.
) || (
start cmd.exe /k "color 4f & title Error & Echo. & Echo. & Echo Git is not properly installed! & Echo The installation will be canceled. If this is a mistake, remove the initial check from this batch file. & Echo Press any key to close this dialog & Pause > nul & Exit"
Echo Git environment variable wasnt found; Pulling will be canceled
Echo.
Echo Press any key to exit.
Echo.
for /f i in ('git rev-parse --is-inside-work-tree 2^>^&1') do (
if /I "i"=="true" (
for /f i in ('git rev-parse --is-inside-work-tree 2^>^&1') do (
)
set /P "input=Press 'y' to continue and configure Git here; 'n' to abort this action: "
 
echo Continuing...
echo Setting Git up in the current directory...
echo No branch name input provided. Pulling the 'main' branch.
set "branchToPull=main"
)
) else (
goto wrongDirError
 
exit
)
)
if "!gitConfigUser!"=="" set "gitConfigUser="
 
if "G"=="gitConfigPassword" (
:success
set "gitConfigPassword=H"
Echo.
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
set "branchToPull=main"
set "gitConfigURL=H"
if "^"==^"" (
if "^"==^" " set "gitConfigUser="
if "^"==^" " set "gitConfigPassword="
echo No input remote repo name provided. Setting to default 'origin'.
set "gitConfigRemoteName=origin"
)
 
 
for /F "tokens=1,* delims== " G in (config.txt) do (
for /F "delims=" i in ('git config user.name') do set currentGitConfigUser=i
for /F "delims=" i in ('git config user.password') do set currentGitConfigPassword=i
if "!gitConfigUser!"=="" set "gitConfigUser="
for /F "delims=" i in ('git config --get remote..url') do set currentGitConfigURL=i
if "G"=="gitConfigPassword" (
set "gitConfigPassword=H"
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
if "G"=="gitConfigURL" (
set "gitConfigURL=H"
if "!gitConfigURL!"=="" set "gitConfigURL="
)
)
if ==0 (
REM do nothing
goto dontSkip
set "gitConfigURL=!gitConfigURL:"=!"
) else (
 
rem Check if the string is a space character and set it to an empty variable; space is always appended >:-( though git should deal with these strings correctly nevertheless
)
if "^"==^" " set "gitConfigUser="
if "^"==^" " set "gitConfigPassword="
if "^"==^" " set "gitConfigURL="
 
 
if not "!gitConfigUser!"=="" (
 
REM git config --global --replace-all "!gitConfigUser!"
)
)
echo Current local Git Username is not set -> new Name: "!gitConfigUser!"
git config user.password "!gitConfigPassword!"
)
 
 
Echo.
 
git remote add  "!gitConfigURL!"
 
)
echo "!currentGitConfigURL!"
 
) else (
)
) else (
Echo Either Config.txt url was empty
)
:skipConfig
 
git pull %gitConfigRemoteName% %branchToPull%
 
 
if not %errorlevel% == 0(
Echo.
Echo Git ran into an Error when pulling.
Echo Have you committed your local changes?
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
Echo Resetting uncommited local changes ...
 
git reset --hard
git pull %gitConfigRemoteName% %branchToPull%
 
) else (
goto invalidNumberLength
)
) else (
:invalidNumberLength
Echo Aborting...
Echo.
Echo Press any key to exit.
Pause > nul
Exit
)
)
endlocal
@echo off
setlocal EnableDelayedExpansion
 
set "overwriteGitConfigData=true"
 
set "skipConfig=0"
REM 0==dont skip; 1==skip userConfig; >1==skip
 
 
where git >nul 2>nul && (
echo Git is installed.
) || (
start cmd.exe /k "color 4f & title Error & Echo. & Echo. & Echo Git is not properly installed! & Echo The installation will be canceled. If this is a mistake, remove the initial check from this batch file. & Echo Press any key to close this dialog & Pause > nul & Exit"
Echo Git environment variable wasnt found; Pulling will be canceled
Echo.
Echo Press any key to exit.
Pause > nul
Exit;
)
 
 
for /f i in ('git rev-parse --is-inside-work-tree 2^>^&1') do (
if /I "i"=="true" (
goto success
) else (
echo Current directory isn't a Git repository!
echo By continuing, Git will be set up here.
set /P "input=Press 'y' to continue and configure Git here; 'n' to abort this action: "
 
REM Check if the length of the input at 4th index is empty (3 chars or less) and if it starts with 'y'
set "choice=!input:~0,1!"
if /I "!choice!"=="y" (
if "!input:~3!"=="" (
echo Continuing...
echo Setting Git up in the current directory...
git init
) else (
goto wrongDirError
)
) else (
:wrongDirError
echo Aborting...
echo.
echo Press any key to exit.
pause > nul
exit
)
)
)
 
:success
Echo.
 
if ""=="" (
echo No branch name input provided. Pulling the 'main' branch.
set "branchToPull=main"
)
 
 
set "gitConfigRemoteName=%~2"
 
if "^"==^"" (
echo No input remote repo name provided. Setting to default 'origin'.
set "gitConfigRemoteName=origin"
)
rem Read configurations from the config.txt file
for /F "tokens=1,* delims== " G in (config.txt) do (
if "G"=="gitConfigUser" (
set "gitConfigUser=H"
if "!gitConfigUser!"=="" set "gitConfigUser="
)
if "G"=="gitConfigPassword" (
set "gitConfigPassword=H"
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
if "G"=="gitConfigURL" (
set "gitConfigURL=H"
if "!gitConfigURL!"=="" set "gitConfigURL="
)
)
rem Removing quotes from the config values
set "gitConfigUser=!gitConfigUser:"=!"
set "gitConfigPassword=!gitConfigPassword:"=!"
set "gitConfigURL=!gitConfigURL:"=!"
 
rem Check if the string is a space character and set it to an empty variable; space is always appended >:-( though git should deal with these strings correctly nevertheless
if "^"==^" " set "gitConfigUser="
if "^"==^" " set "gitConfigPassword="
if "^"==^" " set "gitConfigURL="
 
 
rem read current/already defined Git Config to see if theyre blank; not using --global flag!
for /F "delims=" i in ('git config user.name') do set currentGitConfigUser=i
for /F "delims=" i in ('git config user.password') do set currentGitConfigPassword=i
for /F "delims=" i in ('git config --get remote..url') do set currentGitConfigURL=i
 
if "!currentGitConfigUser!"==" " set "currentGitConfigUser="
if "!currentGitConfigPassword!"==" " set "currentGitConfigPassword="
if "!currentGitConfigURL!"==" " set "currentGitConfigURL="
 
if ==0 (
REM do nothing
goto dontSkip
) else if ==1 (
goto skipUserConfig
) else (
goto skipConfig
)
 
:dontSkip
 
REM set TAB="<TAB>"
set "TAB=   "
 
Echo Current User Name: "!currentGitConfigUser!"  Read User Name: "!gitConfigUser!"
Echo Current User PWD: "!currentGitConfigPassword!"  Read User PWD: "!gitConfigPassword!"
Echo.
Echo Pulling from Host with Name: "%gitConfigRemoteName%"
Echo Current URL under this Name: "!currentGitConfigURL!"  Read URL: "!gitConfigURL!"
 
Echo.
Echo.
 
if not "!gitConfigUser!"=="" (
if "!currentGitConfigUser!"=="" (
echo Current local Git Username is not set -> new Name: "!gitConfigUser!"
git config user.name "!gitConfigUser!"
)else (
echo Current local Git Username is already set; if the overwriteGitConfigData flag is true the current Username: "!currentGitConfigUser!" will be set to "!gitConfigUser!"
if "!overwriteGitConfigData!"=="true" (
git config user.name "!gitConfigUser!"&Echo Overwriting successful; Username "!currentGitConfigUser!" changed to "!gitConfigUser!"
REM git config --global --replace-all "!gitConfigUser!"
)
)
)
 
Echo.
Echo.
 
if not "!gitConfigPassword!"=="" (
if "!currentGitConfigPassword!"=="" (
echo Current local Git Password is not set -> new Password: "!gitConfigPassword!"
git config user.password "!gitConfigPassword!"
)else (
 
echo Current local Git Password is already set; if the overwriteGitConfigData flag is true the current Password: "!currentGitConfigPassword!" will be set to "!gitConfigPassword!"
if "!overwriteGitConfigData!"=="true" (
git config user.password "!gitConfigPassword!"&Echo Overwriting successful; Password "!currentGitConfigPassword!" changed to "!gitConfigPassword!"
REM git config --replace-all --global user.password "!gitConfigPassword!"
)
)
)
 
:skipUserConfig
Echo.
Echo.
 
if not "!gitConfigURL!"=="" (
echo get displayed
echo !gitConfigURL!
echo "!currentGitConfigURL!"
 
if "!currentGitConfigURL!"=="" (
echo Current local Git fetch URL is not set -> new URL: "!gitConfigURL!"
git remote add  "!gitConfigURL!"
) else (
echo Current local Git fetch URL is already set; if the overwriteGitConfigData flag is true the current URL: "!currentGitConfigURL!" will be set to "!gitConfigURL!"
if "!overwriteGitConfigData!"=="true" (
git remote add !gitConfigRemoteName! "!gitConfigURL!" & Echo Overwriting successful; URL "!currentGitConfigURL!" changed to "!gitConfigURL!"
)
)
) else (
Echo Either Config.txt url was empty
)
:skipConfig
 
git pull %gitConfigRemoteName% %branchToPull%
 
 
if not %errorlevel% == 0(
Echo.
Echo Git ran into an Error when pulling.
Echo Have you committed your local changes?
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
Echo Resetting uncommited local changes ...
 
git reset --hard
git pull %gitConfigRemoteName% %branchToPull%
 
) else (
goto invalidNumberLength
)
) else (
:invalidNumberLength
Echo Aborting...
Echo.
Echo Press any key to exit.
Pause > nul
Exit
)
)
endlocal
@echo off
setlocal EnableDelayedExpansion
 
set "overwriteGitConfigData=true"
 
set "skipConfig=0"
REM 0==dont skip; 1==skip userConfig; >1==skip
 
 
where git >nul 2>nul && (
echo Git is installed.
) || (
start cmd.exe /k "color 4f & title Error & Echo. & Echo. & Echo Git is not properly installed! & Echo The installation will be canceled. If this is a mistake, remove the initial check from this batch file. & Echo Press any key to close this dialog & Pause > nul & Exit"
Echo Git environment variable wasnt found; Pulling will be canceled
Echo.
Echo Press any key to exit.
Pause > nul
Exit;
)
 
 
for /f i in ('git rev-parse --is-inside-work-tree 2^>^&1') do (
if /I "i"=="true" (
goto success
) else (
echo Current directory isn't a Git repository!
echo By continuing, Git will be set up here.
set /P "input=Press 'y' to continue and configure Git here; 'n' to abort this action: "
 
REM Check if the length of the input at 4th index is empty (3 chars or less) and if it starts with 'y'
set "choice=!input:~0,1!"
if /I "!choice!"=="y" (
if "!input:~3!"=="" (
echo Continuing...
echo Setting Git up in the current directory...
git init
) else (
goto wrongDirError
)
) else (
:wrongDirError
echo Aborting...
echo.
echo Press any key to exit.
pause > nul
exit
)
)
)
 
:success
Echo.
 
if ""=="" (
echo No branch name input provided. Pulling the 'main' branch.
set "branchToPull=main"
)
 
 
set "gitConfigRemoteName=%~2"
 
if "^"==^"" (
echo No input remote repo name provided. Setting to default 'origin'.
set "gitConfigRemoteName=origin"
)
rem Read configurations from the config.txt file
for /F "tokens=1,* delims== " G in (config.txt) do (
if "G"=="gitConfigUser" (
set "gitConfigUser=H"
if "!gitConfigUser!"=="" set "gitConfigUser="
)
if "G"=="gitConfigPassword" (
set "gitConfigPassword=H"
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
if "G"=="gitConfigURL" (
set "gitConfigURL=H"
if "!gitConfigURL!"=="" set "gitConfigURL="
)
)
rem Removing quotes from the config values
set "gitConfigUser=!gitConfigUser:"=!"
set "gitConfigPassword=!gitConfigPassword:"=!"
set "gitConfigURL=!gitConfigURL:"=!"
 
rem Check if the string is a space character and set it to an empty variable; space is always appended >:-( though git should deal with these strings correctly nevertheless
if "^"==^" " set "gitConfigUser="
if "^"==^" " set "gitConfigPassword="
if "^"==^" " set "gitConfigURL="
 
 
rem read current/already defined Git Config to see if theyre blank; not using --global flag!
for /F "delims=" i in ('git config user.name') do set currentGitConfigUser=i
for /F "delims=" i in ('git config user.password') do set currentGitConfigPassword=i
for /F "delims=" i in ('git config --get remote..url') do set currentGitConfigURL=i
 
if "!currentGitConfigUser!"==" " set "currentGitConfigUser="
if "!currentGitConfigPassword!"==" " set "currentGitConfigPassword="
if "!currentGitConfigURL!"==" " set "currentGitConfigURL="
 
if ==0 (
REM do nothing
goto dontSkip
) else if ==1 (
goto skipUserConfig
) else (
goto skipConfig
)
 
:dontSkip
 
REM set TAB="<TAB>"
set "TAB=   "
 
Echo Current User Name: "!currentGitConfigUser!"  Read User Name: "!gitConfigUser!"
Echo Current User PWD: "!currentGitConfigPassword!"  Read User PWD: "!gitConfigPassword!"
Echo.
Echo Pulling from Host with Name: "%gitConfigRemoteName%"
Echo Current URL under this Name: "!currentGitConfigURL!"  Read URL: "!gitConfigURL!"
 
Echo.
Echo.
 
if not "!gitConfigUser!"=="" (
if "!currentGitConfigUser!"=="" (
echo Current local Git Username is not set -> new Name: "!gitConfigUser!"
git config user.name "!gitConfigUser!"
)else (
echo Current local Git Username is already set; if the overwriteGitConfigData flag is true the current Username: "!currentGitConfigUser!" will be set to "!gitConfigUser!"
if "!overwriteGitConfigData!"=="true" (
git config user.name "!gitConfigUser!"&Echo Overwriting successful; Username "!currentGitConfigUser!" changed to "!gitConfigUser!"
REM git config --global --replace-all "!gitConfigUser!"
)
)
)
 
Echo.
Echo.
 
if not "!gitConfigPassword!"=="" (
if "!currentGitConfigPassword!"=="" (
echo Current local Git Password is not set -> new Password: "!gitConfigPassword!"
git config user.password "!gitConfigPassword!"
)else (
 
echo Current local Git Password is already set; if the overwriteGitConfigData flag is true the current Password: "!currentGitConfigPassword!" will be set to "!gitConfigPassword!"
if "!overwriteGitConfigData!"=="true" (
git config user.password "!gitConfigPassword!"&Echo Overwriting successful; Password "!currentGitConfigPassword!" changed to "!gitConfigPassword!"
REM git config --replace-all --global user.password "!gitConfigPassword!"
)
)
)
 
:skipUserConfig
Echo.
Echo.
 
if not "!gitConfigURL!"=="" (
echo get displayed
echo !gitConfigURL!
echo "!currentGitConfigURL!"
 
if "!currentGitConfigURL!"=="" (
echo Current local Git fetch URL is not set -> new URL: "!gitConfigURL!"
git remote add  "!gitConfigURL!"
) else (
echo Current local Git fetch URL is already set; if the overwriteGitConfigData flag is true the current URL: "!currentGitConfigURL!" will be set to "!gitConfigURL!"
if "!overwriteGitConfigData!"=="true" (
git remote add !gitConfigRemoteName! "!gitConfigURL!" & Echo Overwriting successful; URL "!currentGitConfigURL!" changed to "!gitConfigURL!"
)
)
) else (
Echo Either Config.txt url was empty
)
:skipConfig
 
git pull %gitConfigRemoteName% %branchToPull%
 
 
if not %errorlevel% == 0(
Echo.
Echo Git ran into an Error when pulling.
Echo Have you committed your local changes?
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
Echo Resetting uncommited local changes ...
 
git reset --hard
git pull %gitConfigRemoteName% %branchToPull%
 
) else (
goto invalidNumberLength
)
) else (
:invalidNumberLength
Echo Aborting...
Echo.
Echo Press any key to exit.
Pause > nul
Exit
)
)
endlocal
@echo off
setlocal EnableDelayedExpansion
 
set "overwriteGitConfigData=true"
 
set "skipConfig=0"
REM 0==dont skip; 1==skip userConfig; >1==skip
 
 
where git >nul 2>nul && (
echo Git is installed.
) || (
start cmd.exe /k "color 4f & title Error & Echo. & Echo. & Echo Git is not properly installed! & Echo The installation will be canceled. If this is a mistake, remove the initial check from this batch file. & Echo Press any key to close this dialog & Pause > nul & Exit"
Echo Git environment variable wasnt found; Pulling will be canceled
Echo.
Echo Press any key to exit.
Pause > nul
Exit;
)
 
 
for /f i in ('git rev-parse --is-inside-work-tree 2^>^&1') do (
if /I "i"=="true" (
goto success
) else (
echo Current directory isn't a Git repository!
echo By continuing, Git will be set up here.
set /P "input=Press 'y' to continue and configure Git here; 'n' to abort this action: "
 
REM Check if the length of the input at 4th index is empty (3 chars or less) and if it starts with 'y'
set "choice=!input:~0,1!"
if /I "!choice!"=="y" (
if "!input:~3!"=="" (
echo Continuing...
echo Setting Git up in the current directory...
git init
) else (
goto wrongDirError
)
) else (
:wrongDirError
echo Aborting...
echo.
echo Press any key to exit.
pause > nul
exit
)
)
)
 
:success
Echo.
 
if ""=="" (
echo No branch name input provided. Pulling the 'main' branch.
set "branchToPull=main"
)
 
 
set "gitConfigRemoteName=%~2"
 
if "^"==^"" (
echo No input remote repo name provided. Setting to default 'origin'.
set "gitConfigRemoteName=origin"
)
rem Read configurations from the config.txt file
for /F "tokens=1,* delims== " G in (config.txt) do (
if "G"=="gitConfigUser" (
set "gitConfigUser=H"
if "!gitConfigUser!"=="" set "gitConfigUser="
)
if "G"=="gitConfigPassword" (
set "gitConfigPassword=H"
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
if "G"=="gitConfigURL" (
set "gitConfigURL=H"
if "!gitConfigURL!"=="" set "gitConfigURL="
)
)
rem Removing quotes from the config values
set "gitConfigUser=!gitConfigUser:"=!"
set "gitConfigPassword=!gitConfigPassword:"=!"
set "gitConfigURL=!gitConfigURL:"=!"
 
rem Check if the string is a space character and set it to an empty variable; space is always appended >:-( though git should deal with these strings correctly nevertheless
if "^"==^" " set "gitConfigUser="
if "^"==^" " set "gitConfigPassword="
if "^"==^" " set "gitConfigURL="
 
 
rem read current/already defined Git Config to see if theyre blank; not using --global flag!
for /F "delims=" i in ('git config user.name') do set currentGitConfigUser=i
for /F "delims=" i in ('git config user.password') do set currentGitConfigPassword=i
for /F "delims=" i in ('git config --get remote..url') do set currentGitConfigURL=i
 
if "!currentGitConfigUser!"==" " set "currentGitConfigUser="
if "!currentGitConfigPassword!"==" " set "currentGitConfigPassword="
if "!currentGitConfigURL!"==" " set "currentGitConfigURL="
 
if ==0 (
REM do nothing
goto dontSkip
) else if ==1 (
goto skipUserConfig
) else (
goto skipConfig
)
 
:dontSkip
 
REM set TAB="<TAB>"
set "TAB=   "
 
Echo Current User Name: "!currentGitConfigUser!"  Read User Name: "!gitConfigUser!"
Echo Current User PWD: "!currentGitConfigPassword!"  Read User PWD: "!gitConfigPassword!"
Echo.
Echo Pulling from Host with Name: "%gitConfigRemoteName%"
Echo Current URL under this Name: "!currentGitConfigURL!"  Read URL: "!gitConfigURL!"
 
Echo.
Echo.
 
if not "!gitConfigUser!"=="" (
if "!currentGitConfigUser!"=="" (
echo Current local Git Username is not set -> new Name: "!gitConfigUser!"
git config user.name "!gitConfigUser!"
)else (
echo Current local Git Username is already set; if the overwriteGitConfigData flag is true the current Username: "!currentGitConfigUser!" will be set to "!gitConfigUser!"
if "!overwriteGitConfigData!"=="true" (
git config user.name "!gitConfigUser!"&Echo Overwriting successful; Username "!currentGitConfigUser!" changed to "!gitConfigUser!"
REM git config --global --replace-all "!gitConfigUser!"
)
)
)
 
Echo.
Echo.
 
if not "!gitConfigPassword!"=="" (
if "!currentGitConfigPassword!"=="" (
echo Current local Git Password is not set -> new Password: "!gitConfigPassword!"
git config user.password "!gitConfigPassword!"
)else (
 
echo Current local Git Password is already set; if the overwriteGitConfigData flag is true the current Password: "!currentGitConfigPassword!" will be set to "!gitConfigPassword!"
if "!overwriteGitConfigData!"=="true" (
git config user.password "!gitConfigPassword!"&Echo Overwriting successful; Password "!currentGitConfigPassword!" changed to "!gitConfigPassword!"
REM git config --replace-all --global user.password "!gitConfigPassword!"
)
)
)
 
:skipUserConfig
Echo.
Echo.
 
if not "!gitConfigURL!"=="" (
echo get displayed
echo !gitConfigURL!
echo "!currentGitConfigURL!"
 
if "!currentGitConfigURL!"=="" (
echo Current local Git fetch URL is not set -> new URL: "!gitConfigURL!"
git remote add  "!gitConfigURL!"
) else (
echo Current local Git fetch URL is already set; if the overwriteGitConfigData flag is true the current URL: "!currentGitConfigURL!" will be set to "!gitConfigURL!"
if "!overwriteGitConfigData!"=="true" (
git remote add !gitConfigRemoteName! "!gitConfigURL!" & Echo Overwriting successful; URL "!currentGitConfigURL!" changed to "!gitConfigURL!"
)
)
) else (
Echo Either Config.txt url was empty
)
:skipConfig
 
git pull %gitConfigRemoteName% %branchToPull%
 
 
if not %errorlevel% == 0(
Echo.
Echo Git ran into an Error when pulling.
Echo Have you committed your local changes?
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
Echo Resetting uncommited local changes ...
 
git reset --hard
git pull %gitConfigRemoteName% %branchToPull%
 
) else (
goto invalidNumberLength
)
) else (
:invalidNumberLength
Echo Aborting...
Echo.
Echo Press any key to exit.
Pause > nul
Exit
)
)
endlocal
@echo off
setlocal EnableDelayedExpansion
 
set "overwriteGitConfigData=true"
 
set "skipConfig=0"
REM 0==dont skip; 1==skip userConfig; >1==skip
 
 
where git >nul 2>nul && (
echo Git is installed.
) || (
start cmd.exe /k "color 4f & title Error & Echo. & Echo. & Echo Git is not properly installed! & Echo The installation will be canceled. If this is a mistake, remove the initial check from this batch file. & Echo Press any key to close this dialog & Pause > nul & Exit"
Echo Git environment variable wasnt found; Pulling will be canceled
Echo.
Echo Press any key to exit.
Pause > nul
Exit;
)
 
 
for /f i in ('git rev-parse --is-inside-work-tree 2^>^&1') do (
if /I "i"=="true" (
goto success
) else (
echo Current directory isn't a Git repository!
echo By continuing, Git will be set up here.
set /P "input=Press 'y' to continue and configure Git here; 'n' to abort this action: "
 
REM Check if the length of the input at 4th index is empty (3 chars or less) and if it starts with 'y'
set "choice=!input:~0,1!"
if /I "!choice!"=="y" (
if "!input:~3!"=="" (
echo Continuing...
echo Setting Git up in the current directory...
git init
) else (
goto wrongDirError
)
) else (
:wrongDirError
echo Aborting...
echo.
echo Press any key to exit.
pause > nul
exit
)
)
)
 
:success
Echo.
 
if ""=="" (
echo No branch name input provided. Pulling the 'main' branch.
set "branchToPull=main"
)
 
 
set "gitConfigRemoteName=%~2"
 
if "^"==^"" (
echo No input remote repo name provided. Setting to default 'origin'.
set "gitConfigRemoteName=origin"
)
rem Read configurations from the config.txt file
for /F "tokens=1,* delims== " G in (config.txt) do (
if "G"=="gitConfigUser" (
set "gitConfigUser=H"
if "!gitConfigUser!"=="" set "gitConfigUser="
)
if "G"=="gitConfigPassword" (
set "gitConfigPassword=H"
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
if "G"=="gitConfigURL" (
set "gitConfigURL=H"
if "!gitConfigURL!"=="" set "gitConfigURL="
)
)
rem Removing quotes from the config values
set "gitConfigUser=!gitConfigUser:"=!"
set "gitConfigPassword=!gitConfigPassword:"=!"
set "gitConfigURL=!gitConfigURL:"=!"
 
rem Check if the string is a space character and set it to an empty variable; space is always appended >:-( though git should deal with these strings correctly nevertheless
if "^"==^" " set "gitConfigUser="
if "^"==^" " set "gitConfigPassword="
if "^"==^" " set "gitConfigURL="
 
 
rem read current/already defined Git Config to see if theyre blank; not using --global flag!
for /F "delims=" i in ('git config user.name') do set currentGitConfigUser=i
for /F "delims=" i in ('git config user.password') do set currentGitConfigPassword=i
for /F "delims=" i in ('git config --get remote..url') do set currentGitConfigURL=i
 
if "!currentGitConfigUser!"==" " set "currentGitConfigUser="
if "!currentGitConfigPassword!"==" " set "currentGitConfigPassword="
if "!currentGitConfigURL!"==" " set "currentGitConfigURL="
 
if ==0 (
REM do nothing
goto dontSkip
) else if ==1 (
goto skipUserConfig
) else (
goto skipConfig
)
 
:dontSkip
 
REM set TAB="<TAB>"
set "TAB=   "
 
Echo Current User Name: "!currentGitConfigUser!"  Read User Name: "!gitConfigUser!"
Echo Current User PWD: "!currentGitConfigPassword!"  Read User PWD: "!gitConfigPassword!"
Echo.
Echo Pulling from Host with Name: "%gitConfigRemoteName%"
Echo Current URL under this Name: "!currentGitConfigURL!"  Read URL: "!gitConfigURL!"
 
Echo.
Echo.
 
if not "!gitConfigUser!"=="" (
if "!currentGitConfigUser!"=="" (
echo Current local Git Username is not set -> new Name: "!gitConfigUser!"
git config user.name "!gitConfigUser!"
)else (
echo Current local Git Username is already set; if the overwriteGitConfigData flag is true the current Username: "!currentGitConfigUser!" will be set to "!gitConfigUser!"
if "!overwriteGitConfigData!"=="true" (
git config user.name "!gitConfigUser!"&Echo Overwriting successful; Username "!currentGitConfigUser!" changed to "!gitConfigUser!"
REM git config --global --replace-all "!gitConfigUser!"
)
)
)
 
Echo.
Echo.
 
if not "!gitConfigPassword!"=="" (
if "!currentGitConfigPassword!"=="" (
echo Current local Git Password is not set -> new Password: "!gitConfigPassword!"
git config user.password "!gitConfigPassword!"
)else (
 
echo Current local Git Password is already set; if the overwriteGitConfigData flag is true the current Password: "!currentGitConfigPassword!" will be set to "!gitConfigPassword!"
if "!overwriteGitConfigData!"=="true" (
git config user.password "!gitConfigPassword!"&Echo Overwriting successful; Password "!currentGitConfigPassword!" changed to "!gitConfigPassword!"
REM git config --replace-all --global user.password "!gitConfigPassword!"
)
)
)
 
:skipUserConfig
Echo.
Echo.
 
if not "!gitConfigURL!"=="" (
echo get displayed
echo !gitConfigURL!
echo "!currentGitConfigURL!"
 
if "!currentGitConfigURL!"=="" (
echo Current local Git fetch URL is not set -> new URL: "!gitConfigURL!"
git remote add  "!gitConfigURL!"
) else (
echo Current local Git fetch URL is already set; if the overwriteGitConfigData flag is true the current URL: "!currentGitConfigURL!" will be set to "!gitConfigURL!"
if "!overwriteGitConfigData!"=="true" (
git remote add !gitConfigRemoteName! "!gitConfigURL!" & Echo Overwriting successful; URL "!currentGitConfigURL!" changed to "!gitConfigURL!"
)
)
) else (
Echo Either Config.txt url was empty
)
:skipConfig
 
git pull %gitConfigRemoteName% %branchToPull%
 
 
if not %errorlevel% == 0(
Echo.
Echo Git ran into an Error when pulling.
Echo Have you committed your local changes?
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
Echo Resetting uncommited local changes ...
 
git reset --hard
git pull %gitConfigRemoteName% %branchToPull%
 
) else (
goto invalidNumberLength
)
) else (
:invalidNumberLength
Echo Aborting...
Echo.
Echo Press any key to exit.
Pause > nul
Exit
)
)
endlocal
@echo off
setlocal EnableDelayedExpansion
 
set "overwriteGitConfigData=true"
 
set "skipConfig=0"
REM 0==dont skip; 1==skip userConfig; >1==skip
 
 
where git >nul 2>nul && (
echo Git is installed.
) || (
start cmd.exe /k "color 4f & title Error & Echo. & Echo. & Echo Git is not properly installed! & Echo The installation will be canceled. If this is a mistake, remove the initial check from this batch file. & Echo Press any key to close this dialog & Pause > nul & Exit"
Echo Git environment variable wasnt found; Pulling will be canceled
Echo.
Echo Press any key to exit.
Pause > nul
Exit;
)
 
 
for /f i in ('git rev-parse --is-inside-work-tree 2^>^&1') do (
if /I "i"=="true" (
goto success
) else (
echo Current directory isn't a Git repository!
echo By continuing, Git will be set up here.
set /P "input=Press 'y' to continue and configure Git here; 'n' to abort this action: "
 
REM Check if the length of the input at 4th index is empty (3 chars or less) and if it starts with 'y'
set "choice=!input:~0,1!"
if /I "!choice!"=="y" (
if "!input:~3!"=="" (
echo Continuing...
echo Setting Git up in the current directory...
git init
) else (
goto wrongDirError
)
) else (
:wrongDirError
echo Aborting...
echo.
echo Press any key to exit.
pause > nul
exit
)
)
)
 
:success
Echo.
 
if ""=="" (
echo No branch name input provided. Pulling the 'main' branch.
set "branchToPull=main"
)
 
 
set "gitConfigRemoteName=%~2"
 
if "^"==^"" (
echo No input remote repo name provided. Setting to default 'origin'.
set "gitConfigRemoteName=origin"
)
rem Read configurations from the config.txt file
for /F "tokens=1,* delims== " G in (config.txt) do (
if "G"=="gitConfigUser" (
set "gitConfigUser=H"
if "!gitConfigUser!"=="" set "gitConfigUser="
)
if "G"=="gitConfigPassword" (
set "gitConfigPassword=H"
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
if "G"=="gitConfigURL" (
set "gitConfigURL=H"
if "!gitConfigURL!"=="" set "gitConfigURL="
)
)
rem Removing quotes from the config values
set "gitConfigUser=!gitConfigUser:"=!"
set "gitConfigPassword=!gitConfigPassword:"=!"
set "gitConfigURL=!gitConfigURL:"=!"
 
rem Check if the string is a space character and set it to an empty variable; space is always appended >:-( though git should deal with these strings correctly nevertheless
if "^"==^" " set "gitConfigUser="
if "^"==^" " set "gitConfigPassword="
if "^"==^" " set "gitConfigURL="
 
 
rem read current/already defined Git Config to see if theyre blank; not using --global flag!
for /F "delims=" i in ('git config user.name') do set currentGitConfigUser=i
for /F "delims=" i in ('git config user.password') do set currentGitConfigPassword=i
for /F "delims=" i in ('git config --get remote..url') do set currentGitConfigURL=i
 
if "!currentGitConfigUser!"==" " set "currentGitConfigUser="
if "!currentGitConfigPassword!"==" " set "currentGitConfigPassword="
if "!currentGitConfigURL!"==" " set "currentGitConfigURL="
 
if ==0 (
REM do nothing
goto dontSkip
) else if ==1 (
goto skipUserConfig
) else (
goto skipConfig
)
 
:dontSkip
 
REM set TAB="<TAB>"
set "TAB=   "
 
Echo Current User Name: "!currentGitConfigUser!"  Read User Name: "!gitConfigUser!"
Echo Current User PWD: "!currentGitConfigPassword!"  Read User PWD: "!gitConfigPassword!"
Echo.
Echo Pulling from Host with Name: "%gitConfigRemoteName%"
Echo Current URL under this Name: "!currentGitConfigURL!"  Read URL: "!gitConfigURL!"
 
Echo.
Echo.
 
if not "!gitConfigUser!"=="" (
if "!currentGitConfigUser!"=="" (
echo Current local Git Username is not set -> new Name: "!gitConfigUser!"
git config user.name "!gitConfigUser!"
)else (
echo Current local Git Username is already set; if the overwriteGitConfigData flag is true the current Username: "!currentGitConfigUser!" will be set to "!gitConfigUser!"
if "!overwriteGitConfigData!"=="true" (
git config user.name "!gitConfigUser!"&Echo Overwriting successful; Username "!currentGitConfigUser!" changed to "!gitConfigUser!"
REM git config --global --replace-all "!gitConfigUser!"
)
)
)
 
Echo.
Echo.
 
if not "!gitConfigPassword!"=="" (
if "!currentGitConfigPassword!"=="" (
echo Current local Git Password is not set -> new Password: "!gitConfigPassword!"
git config user.password "!gitConfigPassword!"
)else (
 
echo Current local Git Password is already set; if the overwriteGitConfigData flag is true the current Password: "!currentGitConfigPassword!" will be set to "!gitConfigPassword!"
if "!overwriteGitConfigData!"=="true" (
git config user.password "!gitConfigPassword!"&Echo Overwriting successful; Password "!currentGitConfigPassword!" changed to "!gitConfigPassword!"
REM git config --replace-all --global user.password "!gitConfigPassword!"
)
)
)
 
:skipUserConfig
Echo.
Echo.
 
if not "!gitConfigURL!"=="" (
echo get displayed
echo !gitConfigURL!
echo "!currentGitConfigURL!"
 
if "!currentGitConfigURL!"=="" (
echo Current local Git fetch URL is not set -> new URL: "!gitConfigURL!"
git remote add  "!gitConfigURL!"
) else (
echo Current local Git fetch URL is already set; if the overwriteGitConfigData flag is true the current URL: "!currentGitConfigURL!" will be set to "!gitConfigURL!"
if "!overwriteGitConfigData!"=="true" (
git remote add !gitConfigRemoteName! "!gitConfigURL!" & Echo Overwriting successful; URL "!currentGitConfigURL!" changed to "!gitConfigURL!"
)
)
) else (
Echo Either Config.txt url was empty
)
:skipConfig
 
git pull %gitConfigRemoteName% %branchToPull%
 
 
if not %errorlevel% == 0(
Echo.
Echo Git ran into an Error when pulling.
Echo Have you committed your local changes?
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
Echo Resetting uncommited local changes ...
 
git reset --hard
git pull %gitConfigRemoteName% %branchToPull%
 
) else (
goto invalidNumberLength
)
) else (
:invalidNumberLength
Echo Aborting...
Echo.
Echo Press any key to exit.
Pause > nul
Exit
)
)
endlocal
@echo off
setlocal EnableDelayedExpansion
 
set "overwriteGitConfigData=true"
 
set "skipConfig=0"
REM 0==dont skip; 1==skip userConfig; >1==skip
 
 
where git >nul 2>nul && (
echo Git is installed.
) || (
start cmd.exe /k "color 4f & title Error & Echo. & Echo. & Echo Git is not properly installed! & Echo The installation will be canceled. If this is a mistake, remove the initial check from this batch file. & Echo Press any key to close this dialog & Pause > nul & Exit"
Echo Git environment variable wasnt found; Pulling will be canceled
Echo.
Echo Press any key to exit.
Pause > nul
Exit;
)
 
 
for /f i in ('git rev-parse --is-inside-work-tree 2^>^&1') do (
if /I "i"=="true" (
goto success
) else (
echo Current directory isn't a Git repository!
echo By continuing, Git will be set up here.
set /P "input=Press 'y' to continue and configure Git here; 'n' to abort this action: "
 
REM Check if the length of the input at 4th index is empty (3 chars or less) and if it starts with 'y'
set "choice=!input:~0,1!"
if /I "!choice!"=="y" (
if "!input:~3!"=="" (
echo Continuing...
echo Setting Git up in the current directory...
git init
) else (
goto wrongDirError
)
) else (
:wrongDirError
echo Aborting...
echo.
echo Press any key to exit.
pause > nul
exit
)
)
)
 
:success
Echo.
 
if ""=="" (
echo No branch name input provided. Pulling the 'main' branch.
set "branchToPull=main"
)
 
 
set "gitConfigRemoteName=%~2"
 
if "^"==^"" (
echo No input remote repo name provided. Setting to default 'origin'.
set "gitConfigRemoteName=origin"
)
rem Read configurations from the config.txt file
for /F "tokens=1,* delims== " G in (config.txt) do (
if "G"=="gitConfigUser" (
set "gitConfigUser=H"
if "!gitConfigUser!"=="" set "gitConfigUser="
)
if "G"=="gitConfigPassword" (
set "gitConfigPassword=H"
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
if "G"=="gitConfigURL" (
set "gitConfigURL=H"
if "!gitConfigURL!"=="" set "gitConfigURL="
)
)
rem Removing quotes from the config values
set "gitConfigUser=!gitConfigUser:"=!"
set "gitConfigPassword=!gitConfigPassword:"=!"
set "gitConfigURL=!gitConfigURL:"=!"
 
rem Check if the string is a space character and set it to an empty variable; space is always appended >:-( though git should deal with these strings correctly nevertheless
if "^"==^" " set "gitConfigUser="
if "^"==^" " set "gitConfigPassword="
if "^"==^" " set "gitConfigURL="
 
 
rem read current/already defined Git Config to see if theyre blank; not using --global flag!
for /F "delims=" i in ('git config user.name') do set currentGitConfigUser=i
for /F "delims=" i in ('git config user.password') do set currentGitConfigPassword=i
for /F "delims=" i in ('git config --get remote..url') do set currentGitConfigURL=i
 
if "!currentGitConfigUser!"==" " set "currentGitConfigUser="
if "!currentGitConfigPassword!"==" " set "currentGitConfigPassword="
if "!currentGitConfigURL!"==" " set "currentGitConfigURL="
 
if ==0 (
REM do nothing
goto dontSkip
) else if ==1 (
goto skipUserConfig
) else (
goto skipConfig
)
 
:dontSkip
 
REM set TAB="<TAB>"
set "TAB=   "
 
Echo Current User Name: "!currentGitConfigUser!"  Read User Name: "!gitConfigUser!"
Echo Current User PWD: "!currentGitConfigPassword!"  Read User PWD: "!gitConfigPassword!"
Echo.
Echo Pulling from Host with Name: "%gitConfigRemoteName%"
Echo Current URL under this Name: "!currentGitConfigURL!"  Read URL: "!gitConfigURL!"
 
Echo.
Echo.
 
if not "!gitConfigUser!"=="" (
if "!currentGitConfigUser!"=="" (
echo Current local Git Username is not set -> new Name: "!gitConfigUser!"
git config user.name "!gitConfigUser!"
)else (
echo Current local Git Username is already set; if the overwriteGitConfigData flag is true the current Username: "!currentGitConfigUser!" will be set to "!gitConfigUser!"
if "!overwriteGitConfigData!"=="true" (
git config user.name "!gitConfigUser!"&Echo Overwriting successful; Username "!currentGitConfigUser!" changed to "!gitConfigUser!"
REM git config --global --replace-all "!gitConfigUser!"
)
)
)
 
Echo.
Echo.
 
if not "!gitConfigPassword!"=="" (
if "!currentGitConfigPassword!"=="" (
echo Current local Git Password is not set -> new Password: "!gitConfigPassword!"
git config user.password "!gitConfigPassword!"
)else (
 
echo Current local Git Password is already set; if the overwriteGitConfigData flag is true the current Password: "!currentGitConfigPassword!" will be set to "!gitConfigPassword!"
if "!overwriteGitConfigData!"=="true" (
git config user.password "!gitConfigPassword!"&Echo Overwriting successful; Password "!currentGitConfigPassword!" changed to "!gitConfigPassword!"
REM git config --replace-all --global user.password "!gitConfigPassword!"
)
)
)
 
:skipUserConfig
Echo.
Echo.
 
if not "!gitConfigURL!"=="" (
echo get displayed
echo !gitConfigURL!
echo "!currentGitConfigURL!"
 
if "!currentGitConfigURL!"=="" (
echo Current local Git fetch URL is not set -> new URL: "!gitConfigURL!"
git remote add  "!gitConfigURL!"
) else (
echo Current local Git fetch URL is already set; if the overwriteGitConfigData flag is true the current URL: "!currentGitConfigURL!" will be set to "!gitConfigURL!"
if "!overwriteGitConfigData!"=="true" (
git remote add !gitConfigRemoteName! "!gitConfigURL!" & Echo Overwriting successful; URL "!currentGitConfigURL!" changed to "!gitConfigURL!"
)
)
) else (
Echo Either Config.txt url was empty
)
:skipConfig
 
git pull %gitConfigRemoteName% %branchToPull%
 
 
if not %errorlevel% == 0(
Echo.
Echo Git ran into an Error when pulling.
Echo Have you committed your local changes?
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
Echo Resetting uncommited local changes ...
 
git reset --hard
git pull %gitConfigRemoteName% %branchToPull%
 
) else (
goto invalidNumberLength
)
) else (
:invalidNumberLength
Echo Aborting...
Echo.
Echo Press any key to exit.
Pause > nul
Exit
)
)
endlocal
@echo off
setlocal EnableDelayedExpansion
 
set "overwriteGitConfigData=true"
 
set "skipConfig=0"
REM 0==dont skip; 1==skip userConfig; >1==skip
 
 
where git >nul 2>nul && (
echo Git is installed.
) || (
start cmd.exe /k "color 4f & title Error & Echo. & Echo. & Echo Git is not properly installed! & Echo The installation will be canceled. If this is a mistake, remove the initial check from this batch file. & Echo Press any key to close this dialog & Pause > nul & Exit"
Echo Git environment variable wasnt found; Pulling will be canceled
Echo.
Echo Press any key to exit.
Pause > nul
Exit;
)
 
 
for /f i in ('git rev-parse --is-inside-work-tree 2^>^&1') do (
if /I "i"=="true" (
goto success
) else (
echo Current directory isn't a Git repository!
echo By continuing, Git will be set up here.
set /P "input=Press 'y' to continue and configure Git here; 'n' to abort this action: "
 
REM Check if the length of the input at 4th index is empty (3 chars or less) and if it starts with 'y'
set "choice=!input:~0,1!"
if /I "!choice!"=="y" (
if "!input:~3!"=="" (
echo Continuing...
echo Setting Git up in the current directory...
git init
) else (
goto wrongDirError
)
) else (
:wrongDirError
echo Aborting...
echo.
echo Press any key to exit.
pause > nul
exit
)
)
)
 
:success
Echo.
 
if ""=="" (
echo No branch name input provided. Pulling the 'main' branch.
set "branchToPull=main"
)
 
 
set "gitConfigRemoteName=%~2"
 
if "^"==^"" (
echo No input remote repo name provided. Setting to default 'origin'.
set "gitConfigRemoteName=origin"
)
rem Read configurations from the config.txt file
for /F "tokens=1,* delims== " G in (config.txt) do (
if "G"=="gitConfigUser" (
set "gitConfigUser=H"
if "!gitConfigUser!"=="" set "gitConfigUser="
)
if "G"=="gitConfigPassword" (
set "gitConfigPassword=H"
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
if "G"=="gitConfigURL" (
set "gitConfigURL=H"
if "!gitConfigURL!"=="" set "gitConfigURL="
)
)
rem Removing quotes from the config values
set "gitConfigUser=!gitConfigUser:"=!"
set "gitConfigPassword=!gitConfigPassword:"=!"
set "gitConfigURL=!gitConfigURL:"=!"
 
rem Check if the string is a space character and set it to an empty variable; space is always appended >:-( though git should deal with these strings correctly nevertheless
if "^"==^" " set "gitConfigUser="
if "^"==^" " set "gitConfigPassword="
if "^"==^" " set "gitConfigURL="
 
 
rem read current/already defined Git Config to see if theyre blank; not using --global flag!
for /F "delims=" i in ('git config user.name') do set currentGitConfigUser=i
for /F "delims=" i in ('git config user.password') do set currentGitConfigPassword=i
for /F "delims=" i in ('git config --get remote..url') do set currentGitConfigURL=i
 
if "!currentGitConfigUser!"==" " set "currentGitConfigUser="
if "!currentGitConfigPassword!"==" " set "currentGitConfigPassword="
if "!currentGitConfigURL!"==" " set "currentGitConfigURL="
 
if ==0 (
REM do nothing
goto dontSkip
) else if ==1 (
goto skipUserConfig
) else (
goto skipConfig
)
 
:dontSkip
 
REM set TAB="<TAB>"
set "TAB=   "
 
Echo Current User Name: "!currentGitConfigUser!"  Read User Name: "!gitConfigUser!"
Echo Current User PWD: "!currentGitConfigPassword!"  Read User PWD: "!gitConfigPassword!"
Echo.
Echo Pulling from Host with Name: "%gitConfigRemoteName%"
Echo Current URL under this Name: "!currentGitConfigURL!"  Read URL: "!gitConfigURL!"
 
Echo.
Echo.
 
if not "!gitConfigUser!"=="" (
if "!currentGitConfigUser!"=="" (
echo Current local Git Username is not set -> new Name: "!gitConfigUser!"
git config user.name "!gitConfigUser!"
)else (
echo Current local Git Username is already set; if the overwriteGitConfigData flag is true the current Username: "!currentGitConfigUser!" will be set to "!gitConfigUser!"
if "!overwriteGitConfigData!"=="true" (
git config user.name "!gitConfigUser!"&Echo Overwriting successful; Username "!currentGitConfigUser!" changed to "!gitConfigUser!"
REM git config --global --replace-all "!gitConfigUser!"
)
)
)
 
Echo.
Echo.
 
if not "!gitConfigPassword!"=="" (
if "!currentGitConfigPassword!"=="" (
echo Current local Git Password is not set -> new Password: "!gitConfigPassword!"
git config user.password "!gitConfigPassword!"
)else (
 
echo Current local Git Password is already set; if the overwriteGitConfigData flag is true the current Password: "!currentGitConfigPassword!" will be set to "!gitConfigPassword!"
if "!overwriteGitConfigData!"=="true" (
git config user.password "!gitConfigPassword!"&Echo Overwriting successful; Password "!currentGitConfigPassword!" changed to "!gitConfigPassword!"
REM git config --replace-all --global user.password "!gitConfigPassword!"
)
)
)
 
:skipUserConfig
Echo.
Echo.
 
if not "!gitConfigURL!"=="" (
echo get displayed
echo !gitConfigURL!
echo "!currentGitConfigURL!"
 
if "!currentGitConfigURL!"=="" (
echo Current local Git fetch URL is not set -> new URL: "!gitConfigURL!"
git remote add  "!gitConfigURL!"
) else (
echo Current local Git fetch URL is already set; if the overwriteGitConfigData flag is true the current URL: "!currentGitConfigURL!" will be set to "!gitConfigURL!"
if "!overwriteGitConfigData!"=="true" (
git remote add !gitConfigRemoteName! "!gitConfigURL!" & Echo Overwriting successful; URL "!currentGitConfigURL!" changed to "!gitConfigURL!"
)
)
) else (
Echo Either Config.txt url was empty
)
:skipConfig
 
git pull %gitConfigRemoteName% %branchToPull%
 
 
if not %errorlevel% == 0(
Echo.
Echo Git ran into an Error when pulling.
Echo Have you committed your local changes?
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
Echo Resetting uncommited local changes ...
 
git reset --hard
git pull %gitConfigRemoteName% %branchToPull%
 
) else (
goto invalidNumberLength
)
) else (
:invalidNumberLength
Echo Aborting...
Echo.
Echo Press any key to exit.
Pause > nul
Exit
)
)
endlocal
@echo off
setlocal EnableDelayedExpansion
 
set "overwriteGitConfigData=true"
 
set "skipConfig=0"
REM 0==dont skip; 1==skip userConfig; >1==skip
 
 
where git >nul 2>nul && (
echo Git is installed.
) || (
start cmd.exe /k "color 4f & title Error & Echo. & Echo. & Echo Git is not properly installed! & Echo The installation will be canceled. If this is a mistake, remove the initial check from this batch file. & Echo Press any key to close this dialog & Pause > nul & Exit"
Echo Git environment variable wasnt found; Pulling will be canceled
Echo.
Echo Press any key to exit.
Pause > nul
Exit;
)
 
 
for /f i in ('git rev-parse --is-inside-work-tree 2^>^&1') do (
if /I "i"=="true" (
goto success
) else (
echo Current directory isn't a Git repository!
echo By continuing, Git will be set up here.
set /P "input=Press 'y' to continue and configure Git here; 'n' to abort this action: "
 
REM Check if the length of the input at 4th index is empty (3 chars or less) and if it starts with 'y'
set "choice=!input:~0,1!"
if /I "!choice!"=="y" (
if "!input:~3!"=="" (
echo Continuing...
echo Setting Git up in the current directory...
git init
) else (
goto wrongDirError
)
) else (
:wrongDirError
echo Aborting...
echo.
echo Press any key to exit.
pause > nul
exit
)
)
)
 
:success
Echo.
 
if ""=="" (
echo No branch name input provided. Pulling the 'main' branch.
set "branchToPull=main"
)
 
 
set "gitConfigRemoteName=%~2"
 
if "^"==^"" (
echo No input remote repo name provided. Setting to default 'origin'.
set "gitConfigRemoteName=origin"
)
rem Read configurations from the config.txt file
for /F "tokens=1,* delims== " G in (config.txt) do (
if "G"=="gitConfigUser" (
set "gitConfigUser=H"
if "!gitConfigUser!"=="" set "gitConfigUser="
)
if "G"=="gitConfigPassword" (
set "gitConfigPassword=H"
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
if "G"=="gitConfigURL" (
set "gitConfigURL=H"
if "!gitConfigURL!"=="" set "gitConfigURL="
)
)
rem Removing quotes from the config values
set "gitConfigUser=!gitConfigUser:"=!"
set "gitConfigPassword=!gitConfigPassword:"=!"
set "gitConfigURL=!gitConfigURL:"=!"
 
rem Check if the string is a space character and set it to an empty variable; space is always appended >:-( though git should deal with these strings correctly nevertheless
if "^"==^" " set "gitConfigUser="
if "^"==^" " set "gitConfigPassword="
if "^"==^" " set "gitConfigURL="
 
 
rem read current/already defined Git Config to see if theyre blank; not using --global flag!
for /F "delims=" i in ('git config user.name') do set currentGitConfigUser=i
for /F "delims=" i in ('git config user.password') do set currentGitConfigPassword=i
for /F "delims=" i in ('git config --get remote..url') do set currentGitConfigURL=i
 
if "!currentGitConfigUser!"==" " set "currentGitConfigUser="
if "!currentGitConfigPassword!"==" " set "currentGitConfigPassword="
if "!currentGitConfigURL!"==" " set "currentGitConfigURL="
 
if ==0 (
REM do nothing
goto dontSkip
) else if ==1 (
goto skipUserConfig
) else (
goto skipConfig
)
 
:dontSkip
 
REM set TAB="<TAB>"
set "TAB=   "
 
Echo Current User Name: "!currentGitConfigUser!"  Read User Name: "!gitConfigUser!"
Echo Current User PWD: "!currentGitConfigPassword!"  Read User PWD: "!gitConfigPassword!"
Echo.
Echo Pulling from Host with Name: "%gitConfigRemoteName%"
Echo Current URL under this Name: "!currentGitConfigURL!"  Read URL: "!gitConfigURL!"
 
Echo.
Echo.
 
if not "!gitConfigUser!"=="" (
if "!currentGitConfigUser!"=="" (
echo Current local Git Username is not set -> new Name: "!gitConfigUser!"
git config user.name "!gitConfigUser!"
)else (
echo Current local Git Username is already set; if the overwriteGitConfigData flag is true the current Username: "!currentGitConfigUser!" will be set to "!gitConfigUser!"
if "!overwriteGitConfigData!"=="true" (
git config user.name "!gitConfigUser!"&Echo Overwriting successful; Username "!currentGitConfigUser!" changed to "!gitConfigUser!"
REM git config --global --replace-all "!gitConfigUser!"
)
)
)
 
Echo.
Echo.
 
if not "!gitConfigPassword!"=="" (
if "!currentGitConfigPassword!"=="" (
echo Current local Git Password is not set -> new Password: "!gitConfigPassword!"
git config user.password "!gitConfigPassword!"
)else (
 
echo Current local Git Password is already set; if the overwriteGitConfigData flag is true the current Password: "!currentGitConfigPassword!" will be set to "!gitConfigPassword!"
if "!overwriteGitConfigData!"=="true" (
git config user.password "!gitConfigPassword!"&Echo Overwriting successful; Password "!currentGitConfigPassword!" changed to "!gitConfigPassword!"
REM git config --replace-all --global user.password "!gitConfigPassword!"
)
)
)
 
:skipUserConfig
Echo.
Echo.
 
if not "!gitConfigURL!"=="" (
echo get displayed
echo !gitConfigURL!
echo "!currentGitConfigURL!"
 
if "!currentGitConfigURL!"=="" (
echo Current local Git fetch URL is not set -> new URL: "!gitConfigURL!"
git remote add  "!gitConfigURL!"
) else (
echo Current local Git fetch URL is already set; if the overwriteGitConfigData flag is true the current URL: "!currentGitConfigURL!" will be set to "!gitConfigURL!"
if "!overwriteGitConfigData!"=="true" (
git remote add !gitConfigRemoteName! "!gitConfigURL!" & Echo Overwriting successful; URL "!currentGitConfigURL!" changed to "!gitConfigURL!"
)
)
) else (
Echo Either Config.txt url was empty
)
:skipConfig
 
git pull %gitConfigRemoteName% %branchToPull%
 
 
if not %errorlevel% == 0(
Echo.
Echo Git ran into an Error when pulling.
Echo Have you committed your local changes?
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
Echo Resetting uncommited local changes ...
 
git reset --hard
git pull %gitConfigRemoteName% %branchToPull%
 
) else (
goto invalidNumberLength
)
) else (
:invalidNumberLength
Echo Aborting...
Echo.
Echo Press any key to exit.
Pause > nul
Exit
)
)
endlocal
@echo off
setlocal EnableDelayedExpansion
 
set "overwriteGitConfigData=true"
 
set "skipConfig=0"
REM 0==dont skip; 1==skip userConfig; >1==skip
 
 
where git >nul 2>nul && (
echo Git is installed.
) || (
start cmd.exe /k "color 4f & title Error & Echo. & Echo. & Echo Git is not properly installed! & Echo The installation will be canceled. If this is a mistake, remove the initial check from this batch file. & Echo Press any key to close this dialog & Pause > nul & Exit"
Echo Git environment variable wasnt found; Pulling will be canceled
Echo.
Echo Press any key to exit.
Pause > nul
Exit;
)
 
 
for /f i in ('git rev-parse --is-inside-work-tree 2^>^&1') do (
if /I "i"=="true" (
goto success
) else (
echo Current directory isn't a Git repository!
echo By continuing, Git will be set up here.
set /P "input=Press 'y' to continue and configure Git here; 'n' to abort this action: "
 
REM Check if the length of the input at 4th index is empty (3 chars or less) and if it starts with 'y'
set "choice=!input:~0,1!"
if /I "!choice!"=="y" (
if "!input:~3!"=="" (
echo Continuing...
echo Setting Git up in the current directory...
git init
) else (
goto wrongDirError
)
) else (
:wrongDirError
echo Aborting...
echo.
echo Press any key to exit.
pause > nul
exit
)
)
)
 
:success
Echo.
 
if ""=="" (
echo No branch name input provided. Pulling the 'main' branch.
set "branchToPull=main"
)
 
 
set "gitConfigRemoteName=%~2"
 
if "^"==^"" (
echo No input remote repo name provided. Setting to default 'origin'.
set "gitConfigRemoteName=origin"
)
rem Read configurations from the config.txt file
for /F "tokens=1,* delims== " G in (config.txt) do (
if "G"=="gitConfigUser" (
set "gitConfigUser=H"
if "!gitConfigUser!"=="" set "gitConfigUser="
)
if "G"=="gitConfigPassword" (
set "gitConfigPassword=H"
if "!gitConfigPassword!"=="" set "gitConfigPassword="
)
if "G"=="gitConfigURL" (
set "gitConfigURL=H"
if "!gitConfigURL!"=="" set "gitConfigURL="
)
)
rem Removing quotes from the config values
set "gitConfigUser=!gitConfigUser:"=!"
set "gitConfigPassword=!gitConfigPassword:"=!"
set "gitConfigURL=!gitConfigURL:"=!"
 
rem Check if the string is a space character and set it to an empty variable; space is always appended >:-( though git should deal with these strings correctly nevertheless
if "^"==^" " set "gitConfigUser="
if "^"==^" " set "gitConfigPassword="
if "^"==^" " set "gitConfigURL="
 
 
rem read current/already defined Git Config to see if theyre blank; not using --global flag!
for /F "delims=" i in ('git config user.name') do set currentGitConfigUser=i
for /F "delims=" i in ('git config user.password') do set currentGitConfigPassword=i
for /F "delims=" i in ('git config --get remote..url') do set currentGitConfigURL=i
 
if "!currentGitConfigUser!"==" " set "currentGitConfigUser="
if "!currentGitConfigPassword!"==" " set "currentGitConfigPassword="
if "!currentGitConfigURL!"==" " set "currentGitConfigURL="
 
if ==0 (
REM do nothing
goto dontSkip
) else if ==1 (
goto skipUserConfig
) else (
goto skipConfig
)
 
:dontSkip
 
REM set TAB="<TAB>"
set "TAB=   "
 
Echo Current User Name: "!currentGitConfigUser!"  Read User Name: "!gitConfigUser!"
Echo Current User PWD: "!currentGitConfigPassword!"  Read User PWD: "!gitConfigPassword!"
Echo.
Echo Pulling from Host with Name: "%gitConfigRemoteName%"
Echo Current URL under this Name: "!currentGitConfigURL!"  Read URL: "!gitConfigURL!"
 
Echo.
Echo.
 
if not "!gitConfigUser!"=="" (
if "!currentGitConfigUser!"=="" (
echo Current local Git Username is not set -> new Name: "!gitConfigUser!"
git config user.name "!gitConfigUser!"
)else (
echo Current local Git Username is already set; if the overwriteGitConfigData flag is true the current Username: "!currentGitConfigUser!" will be set to "!gitConfigUser!"
if "!overwriteGitConfigData!"=="true" (
git config user.name "!gitConfigUser!"&Echo Overwriting successful; Username "!currentGitConfigUser!" changed to "!gitConfigUser!"
REM git config --global --replace-all "!gitConfigUser!"
)
)
)
 
Echo.
Echo.
 
if not "!gitConfigPassword!"=="" (
if "!currentGitConfigPassword!"=="" (
echo Current local Git Password is not set -> new Password: "!gitConfigPassword!"
git config user.password "!gitConfigPassword!"
)else (
 
echo Current local Git Password is already set; if the overwriteGitConfigData flag is true the current Password: "!currentGitConfigPassword!" will be set to "!gitConfigPassword!"
if "!overwriteGitConfigData!"=="true" (
git config user.password "!gitConfigPassword!"&Echo Overwriting successful; Password "!currentGitConfigPassword!" changed to "!gitConfigPassword!"
REM git config --replace-all --global user.password "!gitConfigPassword!"
)
)
)
 
:skipUserConfig
Echo.
Echo.
 
if not "!gitConfigURL!"=="" (
echo get displayed
echo !gitConfigURL!
echo "!currentGitConfigURL!"
 
if "!currentGitConfigURL!"=="" (
echo Current local Git fetch URL is not set -> new URL: "!gitConfigURL!"
git remote add  "!gitConfigURL!"
) else (
echo Current local Git fetch URL is already set; if the overwriteGitConfigData flag is true the current URL: "!currentGitConfigURL!" will be set to "!gitConfigURL!"
if "!overwriteGitConfigData!"=="true" (
git remote add !gitConfigRemoteName! "!gitConfigURL!" & Echo Overwriting successful; URL "!currentGitConfigURL!" changed to "!gitConfigURL!"
)
)
) else (
Echo Either Config.txt url was empty
)
:skipConfig
 
git pull %gitConfigRemoteName% %branchToPull%
 
 
if not %errorlevel% == 0(
Echo.
Echo Git ran into an Error when pulling.
Echo Have you committed your local changes?
set /P input="Press y to continue and overwrite uncommitted changes; n to abort this action: "
if /I "^"==^"y" (
if "~3^"==^"" (
Echo Continuing...
Echo Resetting uncommited local changes ...
 
git reset --hard
git pull %gitConfigRemoteName% %branchToPull%
 
) else (
goto invalidNumberLength
)
) else (
:invalidNumberLength
Echo Aborting...
Echo.
Echo Press any key to exit.
Pause > nul
Exit
)
)
endlocal
