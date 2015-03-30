@ECHO OFF

:: This is only here for testing.
set SPIDEROAK_SSL_VERIFY=0
:: Comment out before using in production.

for /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set _thedate=%%c-%%a-%%b)
for /f "tokens=1-2 delims=/:" %%a in ("%TIME%") do (set _thetime=%%a%%b)

set _cloudsync="C:\Program Files\CloudSync\CloudSync.exe"
set _csfolder="%HOMEPATH%\Documents\CloudSync Folder"
set _csrename="CloudSync Folder_%_thedate%-%_thetime%"
set _log=%TEMP%\cs_reset.log

tasklist /FI "IMAGENAME eq CloudSync.exe" 2>NUL | find /I /N "CloudSync.exe" > NUL

if "%ERRORLEVEL%"=="0" (
	ECHO Closing CloudSync.
	taskkill /f /im "CloudSync.exe"
)

ECHO Renaming CloudSync Folder to %_csrename%
ren %_csfolder% %_csrename%

ECHO Clearing queue. This can take a while please wait.
%_cloudsync% --destroy-shelved-x >> %_log% 2>&1

ECHO Repairing.
%_cloudsync% --repair >> %_log% 2>&1

ECHO Resetting backup selection.
%_cloudsync% --reset-selection >> %_log% 2>&1

ECHO Complete.
pause