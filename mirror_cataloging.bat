@echo off
setlocal enabledelayedexpansion

:: Source directory
set "SOURCE=E:\destination path"

:: Destination directories
set "DEST1=D:\destination path"
set "DEST2=C:\destination path"
set "DEST3=\\10.144.xxx.xx\d\destination path"

:: Logging directory
set "LOGDIR=C:\Logs\RobocopyLogs"
set "LOGKEEP=5"

:: Create log directory if it doesn't exist
if not exist "%LOGDIR%" mkdir "%LOGDIR%"

:: Get current date for log file naming
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set datetime=%%I
set "LOGFILE=%LOGDIR%\Mirror_%datetime:~0,8%_%datetime:~8,6%"

:: Log cleanup - keep only 5 most recent logs
echo Cleaning up old log files...
powershell -Command "& {Get-ChildItem '%LOGDIR%' -Filter 'Mirror_*.log*' | Sort-Object CreationTime -Descending | Select-Object -Skip %LOGKEEP% | Remove-Item -Force}"

:: Verify source directory exists
if not exist "%SOURCE%" (
    echo Error: Source directory does not exist.
    pause
    exit /b 1
)

:: Create local destination directories if they don't exist
if not exist "%DEST1%" mkdir "%DEST1%"
if not exist "%DEST2%" mkdir "%DEST2%"

:: Mirror to first destination
echo Mirroring to %DEST1%
robocopy "%SOURCE%" "%DEST1%" /E /XO /R:3 /W:10 /LOG:"%LOGFILE%_1.log" /TEE

:: Mirror to second destination
echo Mirroring to %DEST2%
robocopy "%SOURCE%" "%DEST2%" /E /XO /R:3 /W:10 /LOG:"%LOGFILE%_2.log" /TEE

:: Mirror to network destination
echo Mirroring to %DEST3%
robocopy "%SOURCE%" "%DEST3%" /E /XO /R:3 /W:10 /LOG:"%LOGFILE%_3.log" /TEE

echo Mirroring completed.
pause
