@echo off
setlocal enabledelayedexpansion
:: Source directory
set "SOURCE=E:\Cataloguing\Final Cataloguing"
:: Destination directories
set "DEST1=D:\Destination Path"
set "DEST2=C:\Destination Path"
set "DEST3=\\10.144.148.xx\d\Destination Path"
set "DEST4=\\10.144.148.28\d\Destination Path"
:: Logging directory
set "LOGDIR=C:\Logs\RobocopyLogs"
set "LOGKEEP=5"
:: Create log directory if it doesn't exist
if not exist "%LOGDIR%" mkdir "%LOGDIR%"
:: Get current date for log file naming
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set datetime=%%I
set "LOGBASE=%LOGDIR%\Ravana_master_%datetime:~0,8%_%datetime:~8,6%"
:: Log cleanup - keep only 5 most recent logs
echo Cleaning up old log files...
powershell -Command "& {Get-ChildItem '%LOGDIR%' -Filter 'sajin_master_*.log*' | Sort-Object CreationTime -Descending | Select-Object -Skip %LOGKEEP% | Remove-Item -Force}"
:: Verify source directory exists
if not exist "%SOURCE%" (
    echo Error: Source directory does not exist.
    pause
    exit /b 1
)
:: Create local destination directories if they don't exist
if not exist "%DEST1%" mkdir "%DEST1%"
if not exist "%DEST2%" mkdir "%DEST2%"
:: Create master log file with header
echo Robocopy Mirror Script Execution Log > "%LOGBASE%.log"
echo Started: %date% %time% >> "%LOGBASE%.log"
echo Source: %SOURCE% >> "%LOGBASE%.log"
echo Destinations: %DEST1%, %DEST2%, %DEST3%, %DEST4% >> "%LOGBASE%.log"
echo ---------------------------------------- >> "%LOGBASE%.log"
:: Mirror to first destination
echo Mirroring to %DEST1%
robocopy "%SOURCE%" "%DEST1%" /E /XO /R:3 /W:10 /LOG+:"%LOGBASE%.log" /TEE
:: Mirror to second destination
echo Mirroring to %DEST2%
robocopy "%SOURCE%" "%DEST2%" /E /XO /R:3 /W:10 /LOG+:"%LOGBASE%.log" /TEE
:: Mirror to first network destination
echo Mirroring to %DEST3%
robocopy "%SOURCE%" "%DEST3%" /E /XO /R:3 /W:10 /LOG+:"%LOGBASE%.log" /TEE
:: Mirror to second network destination
echo Mirroring to %DEST4%
robocopy "%SOURCE%" "%DEST4%" /E /XO /R:3 /W:10 /LOG+:"%LOGBASE%.log" /TEE
:: Final log entry
echo. >> "%LOGBASE%.log"
echo Mirroring completed: %date% %time% >> "%LOGBASE%.log"
echo Mirroring completed. Master log created at %LOGBASE%.log
pause
