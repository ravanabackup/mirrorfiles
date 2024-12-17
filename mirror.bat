@echo off
setlocal enabledelayedexpansion

:: Prompt for mode selection
:MODE_SELECT
echo Select Robocopy Mode:
echo 1. Queue Mode (Sequential)
echo 2. All at Once Mode (Parallel)
set "MODE="
set /p MODE="Enter your choice (1 or 2, default is 1): "

:: Default to 1 if no input is provided
if "%MODE%"=="" set "MODE=1"

if "%MODE%"=="1" goto QUEUE_MODE
if "%MODE%"=="2" goto PARALLEL_MODE
echo Invalid choice. Please enter 1 or 2.
goto MODE_SELECT

:QUEUE_MODE
:: Source directory
set "SOURCE=E:\Cataloguing\Final Cataloguing"
:: Destination directories
set "DEST1=D:\Cataloguing\Final Cataloguing"
set "DEST2=C:\Cataloguing\Final Cataloguing"
set "DEST3=\\10.144.148.49\d\Sajin Data\Cataloguing\Final Cataloguing"
set "DEST4=\\10.144.148.28\d\Sajin Data\Cataloguing\Final Cataloguing"
:: Logging directory
set "LOGDIR=C:\Logs\RobocopyLogs"
set "LOGKEEP=5"

:: Create log directory if it doesn't exist
if not exist "%LOGDIR%" mkdir "%LOGDIR%"

:: Get current date for log file naming
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set datetime=%%I
set "LOGBASE=%LOGDIR%\mirror_master_%datetime:~0,8%_%datetime:~8,6%"

:: Log cleanup - keep only 5 most recent logs
echo Cleaning up old log files...
powershell -Command "& {Get-ChildItem '%LOGDIR%' -Filter 'mirror_master_*.log*' | Sort-Object CreationTime -Descending | Select-Object -Skip %LOGKEEP% | Remove-Item -Force}"

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
echo Mode: Queue (Sequential) >> "%LOGBASE%.log"
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

goto OPEN_FOLDERS_PROMPT

:PARALLEL_MODE
:: Source directory
set "SOURCE=E:\Cataloguing\Final Cataloguing"
:: Destination directories
set "DEST1=D:\Cataloguing\Final Cataloguing"
set "DEST2=C:\Cataloguing\Final Cataloguing"
set "DEST3=\\10.144.148.49\d\Sajin Data\Cataloguing\Final Cataloguing"
set "DEST4=\\10.144.148.28\d\Sajin Data\Cataloguing\Final Cataloguing"
:: Logging directory
set "LOGDIR=C:\Logs\RobocopyLogs"
set "LOGKEEP=5"

:: Create log directory if it doesn't exist
if not exist "%LOGDIR%" mkdir "%LOGDIR%"

:: Get current date for log file naming
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set datetime=%%I
set "LOGBASE=%LOGDIR%\mirror_master_%datetime:~0,8%_%datetime:~8,6%"

:: Log cleanup - keep only 5 most recent logs
echo Cleaning up old log files...
powershell -Command "& {Get-ChildItem '%LOGDIR%' -Filter 'mirror_master_*.log*' | Sort-Object CreationTime -Descending | Select-Object -Skip %LOGKEEP% | Remove-Item -Force}"

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
echo Mode: Parallel (All at Once) >> "%LOGBASE%.log"
echo Source: %SOURCE% >> "%LOGBASE%.log"
echo Destinations: %DEST1%, %DEST2%, %DEST3%, %DEST4% >> "%LOGBASE%.log"
echo ---------------------------------------- >> "%LOGBASE%.log"

:: Start robocopy to all destinations in parallel
start "Mirror to Local Disk D" robocopy "%SOURCE%" "%DEST1%" /E /XO /R:3 /W:10 /LOG+:"%LOGBASE%_dest1.log" /TEE
start "Mirror to Local Disk C" robocopy "%SOURCE%" "%DEST2%" /E /XO /R:3 /W:10 /LOG+:"%LOGBASE%_dest2.log" /TEE
start "Mirror to Network 49" robocopy "%SOURCE%" "%DEST3%" /E /XO /R:3 /W:10 /LOG+:"%LOGBASE%_dest3.log" /TEE
start "Mirror to Network 28" robocopy "%SOURCE%" "%DEST4%" /E /XO /R:3 /W:10 /LOG+:"%LOGBASE%_dest4.log" /TEE

:: Wait for all robocopy processes to complete
:WaitForCopy
timeout /t 5 /nobreak > NUL
tasklist /FI "IMAGENAME eq robocopy.exe" 2>NUL | find /I /N "robocopy.exe">NUL
if "%ERRORLEVEL%"=="0" goto WaitForCopy

:: Combine individual logs into master log
echo. >> "%LOGBASE%.log"
echo Merging individual logs... >> "%LOGBASE%.log"
type "%LOGBASE%_dest1.log" >> "%LOGBASE%.log"
type "%LOGBASE%_dest2.log" >> "%LOGBASE%.log"
type "%LOGBASE%_dest3.log" >> "%LOGBASE%.log"
type "%LOGBASE%_dest4.log" >> "%LOGBASE%.log"

:: Final log entry
echo. >> "%LOGBASE%.log"
echo Mirroring completed: %date% %time% >> "%LOGBASE%.log"
echo Mirroring completed. Master log created at %LOGBASE%.log

:: Clean up individual log files
del "%LOGBASE%_dest1.log" 2>NUL
del "%LOGBASE%_dest2.log" 2>NUL
del "%LOGBASE%_dest3.log" 2>NUL
del "%LOGBASE%_dest4.log" 2>NUL

:OPEN_FOLDERS_PROMPT
set "OPEN_FOLDERS="
set /p OPEN_FOLDERS="Do you want to open all destination folders? (Y/N): "

if /i "%OPEN_FOLDERS%"=="Y" goto OPEN_FOLDERS
if /i "%OPEN_FOLDERS%"=="N" goto END
if "%OPEN_FOLDERS%"=="" goto OPEN_FOLDERS

:OPEN_FOLDERS
start "" "%DEST1%"
start "" "%DEST2%"
start "" "%DEST3%"
start "" "%DEST4%"
echo Destination folders opened.

:END
pause