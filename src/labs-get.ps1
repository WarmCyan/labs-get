# ----------------------------------------------------
#	Labs-Get v0.1.0-ps
#	Date Created: 12/18/2015
#	Date Edited: 12/18/2015
#	Copyright © 2015 Digital Warrior Labs
#	Author: Nathan Martindale (WildfireXIII)
# ----------------------------------------------------

# command line arguments
param (
	[switch]$list = $false,
	[switch]$check = $false,
	[string]$update = "",
	[string]$install = "",
	[string]$remove = "",
	[switch]$forceDependencies = $false, # install dependencies without asking (for automation)
	[switch]$noSpace = $false,
	[switch]$force = $false, # force package removal (don't prompt to continue uninstallation)
	[switch]$override = $false, # ignore default filters
	[Parameter(Position=2)]
	[string]$otherInfo = "",
	[string]$filter = ""
)

# check that necessary environment variables exist
$dataDirExists = Test-Path Env:\DATA_DIR
$binDirExists = Test-Path Env:\BIN_DIR
$pkgDirExists = Test-Path Env:\PKG_DIR
$confDirExists = Test-Path Env:\CONF_DIR
$libDirExists = Test-Path Env:\LIB_DIR

if (!$dataDirExists) { Write-Host "ERROR - Environment variable DATA_DIR not found." -ForegroundColor Red } 
if (!$binDirExists) { Write-Host "ERROR - Environment variable BIN_DIR not found." -ForegroundColor Red } 
if (!$pkgDirExists) { Write-Host "ERROR - Environment variable PKG_DIR not found." -ForegroundColor Red } 
if (!$confDirExists) { Write-Host "ERROR - Environment variable CONF_DIR not found." -ForegroundColor Red } 
if (!$libDirExists) { Write-Host "ERROR - Environment variable LIB_DIR not found." -ForegroundColor Red } 

if (!$dataDirExists -or !$binDirExists -or !$pkgDirExists -or !$confDirExists -or !$libDirExists) { Write-Host "Necessary environment variables not set. Please re-run the setup script that came with the package."; exit }

# shortcuts for important folders
$DATA_DIR = $env:DATA_DIR
$BIN_DIR = $env:BIN_DIR
$PKG_DIR = $env:PKG_DIR
$CONF_DIR = $env:CONF_DIR
$LIB_DIR = $env:LIB_DIR

$LIST_DATA_FILE = "$PKG_DIR\labs-get-list\list.dat"
$INSTALLED_DATA_FILE = "$DATA_DIR\labs-get\installed.dat"
$DEFAULT_TAGS = "$DATA_DIR\labs-get\default-tags.dat"

# check that needed filepaths exist
$listDataExists = Test-Path $LIST_DATA_FILE
$installedDataExists = Test-Path $INSTALLED_DATA_FILE
$tagsDataExists = Test-Path $DEFAULT_TAGS

if (!$listDataExists) { Write-Host "ERROR - Couldn't find $LIST_DATA_FILE" -ForegroundColor Red }
if (!$installedDataExists) { Write-Host "ERROR - Couldn't find $INSTALLED_DATA_FILE" -ForegroundColor Red }
if (!$tagsDataExists) { Write-Host "ERROR - Couldn't find $DEFAULT_TAGS" -ForegroundColor Red }

if (!$listDataExists -or !$installedDataExists -or !$tagsDataExists) { Write-Host "Necessary data files could not be found. Please re-run the setup script that came with the package."; exit }

# -------------------------------- FUNCTIONS -----------------------------
