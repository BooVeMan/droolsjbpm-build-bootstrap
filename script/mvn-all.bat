@echo off
setlocal

rem Runs a mvn command on all droolsjbpm repositories.

call :initializeWorkingDirAndScriptDir

if  "%*" == "" (
    echo.
    echo Usage:
    echo   %~n0%~x0 [arguments of mvn]
    echo For example:
    echo   %~n0%~x0 --version
    echo   %~n0%~x0 -DskipTests clean install
    echo   %~n0%~x0 -Dfull clean install
    echo.
    goto:eof
)

rem set startDateTime='date +%s'

set droolsjbpmOrganizationDir="%scriptDir%\..\.."
cd %droolsjbpmOrganizationDir%

for /F %%r in ('type %scriptDir%\repository-list.txt') do (
    echo.
    if exist %droolsjbpmOrganizationDir%\%%r ( 
        echo ===============================================================================
        echo Repository: %%r
        echo ===============================================================================
        cd %%r
        if exist "%M3_HOME%\bin\mvn.bat" (
            call "%M3_HOME%\bin\mvn.bat" %* 
            if ERRORLEVEL 1 GOTO error
        ) else (
            call mvn %*
            if ERRORLEVEL 1 GOTO error
        )
        cd ..
    ) else (
        echo ===============================================================================
        echo Missing Repository: %%r. Skipping
        echo ===============================================================================
    )
)

GOTO end

:error
cd ..
echo maven failed: %ERRORCODE%

:end

cd %workingDir%

rem set endDateTime='date +%s'
rem set spentSeconds='expr %endDateTime% - %startDateTime%'

echo.
echo Total time: %spentSeconds%s
goto:eof

:initializeWorkingDirAndScriptDir 
    rem Set working directory and remove all symbolic links
    FOR /F %%x IN ('cd') DO set workingDir=%%x

    rem Go the script directory
    for %%F in (%~f0) do set scriptDir=%%~dpF
    rem strip trailing \
    set scriptDir=%scriptDir:~0,-1%
goto:eof

endlocal