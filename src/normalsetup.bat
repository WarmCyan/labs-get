@echo off
::-------------------------------------------
::		Labs-Get setup script v0.1.0-w
::		Date Created: 12/19/2015
::		Date Edited: 6/30/2016
::		Copyright © 2016 Digital Warrior Labs
::		Author: Nathan Martindale (WildfireXIII)
::		Description: Setup script for the windows labs-get package manager.
::			Run this on first-time use, or if files/env variables are missing
::-------------------------------------------

:: PREREQ: MUST HAVE GIT INSTALLED in order to run this setup

:: check existence of environment variables
echo Setting up folder structure...
md "/dwl" 2>NUL
md "/dwl/bin" 2>NUL
md "/dwl/conf" 2>NUL
md "/dwl/data" 2>NUL
md "/dwl/lab" 2>NUL
md "/dwl/lib" 2>NUL
md "/dwl/pkg" 2>NUL

md "/dwl/lab/_env" 2>NUL
md "/dwl/tmp" 2>NUL
md "/dwl/tmp/bak" 2>NUL
md "/dwl/tmp/bin" 2>NUL
md "/dwl/tmp/swp" 2>NUL
echo Folder structure created!

echo Checking environment variables...
:ENVCHECKBIN
	if "%BIN_DIR%" == "" goto CREATEBIN
	goto ENVCHECKLIB

:ENVCHECKLIB	
	if "%LIB_DIR%" == "" goto CREATELIB
	goto ENVCHECKDATA
	
:ENVCHECKDATA
	if "%DATA_DIR%" == "" goto CREATEDATA
	goto ENVCHECKPKG
	
:ENVCHECKPKG
	if "%PKG_DIR%" == "" goto CREATEPKG
	goto ENVCHECKCONF
	
:ENVCHECKCONF
	if "%CONF_DIR%" == "" goto CREATECONF
	goto FINISHENV
	
:FINISHENV
	echo Environment variables ready
	goto PATHCHECK

:: make sure tht the BIN_DIR exists within the path variable
:PATHCHECK
	echo Checking PATH...
	:: insert clean runnable to bin folder and see if possible to run
	echo echo Bin directory is in path! > %BIN_DIR%\path_check.bat
	:: call the script and redirect error output to null so no error is displayed (but then check error level)
	call path_check.bat 2> NUL
	if errorlevel 1 goto ADDTOPATH
	del %BIN_DIR%\path_check.bat 
	goto COPYPRGM
	
:: move the powershell script into bin folder
:COPYPRGM
	echo Copying primary program files...
	copy labs-get.ps1 %BIN_DIR%
	echo Program files located appropriately
	echo Setting up data files...
	goto SETDATAFILES

:: create the data directory if not found, and create all necessary data files
:SETDATAFILES
	if not exist %DATA_DIR%\labs-get (md %DATA_DIR%\labs-get)
	if not exist %PKG_DIR%\labs-get-list goto GETGITLIST
	if not exist %DATA_DIR%\labs-get\installed.dat (echo name,packagename,url,tags,dependencies > %DATA_DIR%\labs-get\installed.dat)
	if not exist %DATA_DIR%\labs-get\default-tags.dat goto GETTAGS
	echo All data files properly installed
	goto END

:: set the powershell execution policy to remotesigned
:SETEXECUTIONPOLICY
	echo Labs-Get is a powershell script that requires remoteSigned execution policy in order to run
	set /p allow=Allow this script to change your powershell execution policy? (y/[n]):
	if /I "%allow%" neq "y" goto END
	>nul powershell.exe -executionpolicy unrestricted -command set-executionpolicy remotesigned
	goto END

:: ------functions------
:ADDTOPATH
	echo Bin directory wasn't found in the PATH variable

	:: thanks to http://superuser.com/questions/601015/how-to-update-the-path-user-environment-variable-from-command-line
	for /f "skip=2 tokens=3*" %%a in ('reg query HKCU\Environment /v PATH') do if [%%b]==[] ( setx PATH "%%~a;%BIN_DIR%" ) else ( setx PATH "%%~a %%~b;%BIN_DIR%" ) 
	
	:: also setting local path because setx doesn't affect current session
	set PATH=%PATH%;%BIN_DIR%
	echo Added %BIN_DIR% to envrionment PATH
	goto PATHCHECK

:GETTAGS
	set /p tags=Enter default package tags to filter (can be changed later in the default-tags.dat file in the data directory):
	echo %tags%>%DATA_DIR%\labs-get\default-tags.dat
	goto SETDATAFILES

:GETGITLIST
	echo Retrieving list git repo...
	set /p giturl=Enter git url for package list:
	git clone %giturl% %PKG_DIR%\labs-get-list
	echo List data git repo installed
	goto SETDATAFILES

:CREATEBIN
	echo No bin path defined!
	::set /p bin=Enter path to bin folder:
	setx BIN_DIR "C:\dwl\bin"
	set BIN_DIR=C:\dwl\bin
	goto ENVCHECKLIB

:CREATELIB
	echo No lib path defined!
	::set /p lib=Enter path to lib folder:
	setx LIB_DIR "C:\dwl\lib"
	set LIB_DIR=C:\dwl\lib
	goto ENVCHECKDATA

:CREATEDATA
	echo No data path defined!
	::set /p data=Enter path to data folder:
	setx DATA_DIR "C:\dwl\data"
	set DATA_DIR=C:\dwl\data
	goto ENVCHECKPKG
	
:CREATEPKG
	echo No pkg path defined!
	::set /p pkg=Enter path to pkg folder:
	setx PKG_DIR "C:\dwl\pkg"
	set PKG_DIR=C:\dwl\pkg
	goto ENVCHECKPKG
	
:CREATECONF
	echo No conf path defined!
	::set /p conf=Enter path to conf folder:
	setx CONF_DIR "C:\dwl\conf"
	set CONF_DIR=C:\dwl\conf
	goto FINISHENV
	
:END
	echo Setup complete!
