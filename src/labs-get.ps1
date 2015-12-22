# ----------------------------------------------------
#	Labs-Get v0.1.0-w
#	Date Created: 12/18/2015
#	Date Edited: 12/21/2015
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
$DEFAULT_TAGS_FILE = "$DATA_DIR\labs-get\default-tags.dat"

# check that needed filepaths exist
$listDataExists = Test-Path $LIST_DATA_FILE
$installedDataExists = Test-Path $INSTALLED_DATA_FILE
$tagsDataExists = Test-Path $DEFAULT_TAGS_FILE

$DEFAULT_TAGS = Get-Content $DEFAULT_TAGS_FILE

if (!$listDataExists) { Write-Host "ERROR - Couldn't find $LIST_DATA_FILE" -ForegroundColor Red }
if (!$installedDataExists) { Write-Host "ERROR - Couldn't find $INSTALLED_DATA_FILE" -ForegroundColor Red }
if (!$tagsDataExists) { Write-Host "ERROR - Couldn't find $DEFAULT_TAGS" -ForegroundColor Red }

if (!$listDataExists -or !$installedDataExists -or !$tagsDataExists) { Write-Host "Necessary data files could not be found. Please re-run the setup script that came with the package."; exit }

# -------------------------------- FUNCTIONS -----------------------------
function readListFile()
{
	$packages = Get-Content -Path $LIST_DATA_FILE | select -Skip 1
	return $packages
}

function readInstalledfile()
{
	$packages = Get-Content -Path $INSTALLED_DATA_FILE | select -Skip 1
	return $packages
}

function readTotalInstalledFile() # reads in header as well
{
	$packages = Get-Content -Path $INSTALLED_DATA_FILE
	return $packages
}

function getCSVCol([string]$rowData, [int]$colNum)
{
	$currentString = $rowData
	$currentLength = 0
	$currentCol = 0

	while($currentString.IndexOf(",") -ne -1 -and $currentCol -lt $colNum)
	{
		$index = $currentString.IndexOf(",")
		$currentCol++
		if ($currentCol -eq $colNum) # everything after current comma til next comma is desired val
		{
			# another comma is found
			$index2 = $currentString.Substring($index + 1).IndexOf(",")
			if ($index2 -eq -1) { return $currentString.Substring($index + 1) }
			else { return $currentString.Substring($index + 1, $index2) }
		}
		$currentString = $currentString.Substring($index + 1)
	}

	# if break out to here, means that it's the first value ($colNum of 0)
	$index = $currentString.IndexOf(",")

	if ($index -eq -1) { return "NULL" }

	return $currentString.Substring(0, $index)
}

function getTagList([string]$tagString)
{
	$tags = @()

	$currentString = $tagString

	while ($currentString.IndexOf("|") -ne -1)
	{
		$index = $currentString.IndexOf("|")
		$tag = $currentString.Substring(0, $index)
		$tags += $tag
		$currentString = $currentString.Substring($index + 1)
	}

	$tags += $currentString

	return $tags
}

function filterPackageListByTags([string[]]$list, [array]$filterTags, [bool]$installed)
{
	$returnList = @()
	foreach ($entry in $list)
	{
		$entryTagString = ""
		if (!$installed) { $entryTagString = getCSVCol $entry 4 }
		else { $entryTagString = getCSVCol $entry 3 }

		$entryTags = getTagList $entryTagString

		$filter = shouldFilter $filterTags $entryTags
		if (!$filter) { $returnList += $entry }
	}
	return $returnList
}

# based on the passed filter tags and passed tag list, decide whether it gets filtered or not
# returns true if do NOT include, false if you should include
function shouldFilter([array]$filterTags, [array]$packageTags)
{
	# make sure that the list has EVERY tag
	$tagsFound = 0;
	$tagsNeeded = $filterTags.Length

	if ($tagsNeeded -lt 1) { return $false } # if no filters provided, don't filter!
	
	foreach ($filterTag in $filterTags)
	{
		# check for if the first letter is '!' (means specifically check that something does NOT have that tag)
		$negativeFilter = $false
		if ($filterTag.Substring(0,1) -eq "!")
		{
			# write-host "SEARCHING FOR NEGATIVE" #DEBUG
			$filterTag = $filterTag.Substring(1)
			$negativeFilter = $true
			$tagsNeeded--
		}
		
		foreach ($tag in $packageTags)
		{
			#write-host "comparing (filter, tag): $filterTag $tag" # DEBUG
			if ($tag -eq $filterTag) 
			{ 
				#write-host "FOUND IT!" # DEBUG
				if (!$negativeFilter) { $tagsFound = $tagsFound + 1; break }
				else { $tagsFound = -1; break }
			}
		}
	}

	#write-host "found: $tagsFound needed: $tagsNeeded" # DEBUG
	if ($tagsFound -ge $tagsNeeded) { return $false }
	return $true
}

function checkIfPackageInstalled([string]$packageName)
{
	$installed = readInstalledFile
	foreach ($instPkg in $installed)
	{
		$instPkgName = getCSVCol $instPkg 0
		if ($instPkgName -eq $packageName) { return $true }
	}
	return $false
}

function installPackageList([string[]]$packages, [string]$force)
{
	foreach ($package in $packages)
	{
		$isInstalled = checkIfPackageInstalled $package
		if ($isInstalled -ne $true)
		{
			if ($force -eq "force") { labs-get -install $package -forceDependencies -noSpace }
			else { labs-get -install $package -noSpace }
		}
		else
		{
			echo "Package '$package' was already installed, skipping..."
		}
	}
}

# searches the tag list for passed in tag. Returns true if found, false if not
function tagListContains([string[]]$tagList, [string]$searchTag)
{
	foreach ($tag in $tagList)
	{
		if ($tag -eq $searchTag) { return $true }
	}
	return $false
}

function removePackageFromInstalled([string]$packageName)
{
	$installed = readTotalInstalledFile
	del $INSTALLED_DATA_FILE
	foreach ($instPkg in $installed)
	{
		$instPkgName = getCSVCol $instPkg 0
		if ($instPkgName -ne $packageName) 
		{ 
			Add-Content -Path $INSTALLED_DATA_FILE -value $instPkg
		}
	}
}

# check _PKG info to see if a package needs data folder(s) created
function handlePackageDataFolder([string]$packageRealName)
{
	pushd $PKG_DIR\$packageRealName
	$lines = Get-Content _PKG
	popd
	$instructions = ""
	foreach ($line in $lines)
	{
		if ($line.StartsWith("data="))
		{
			$instructions = $line.Substring($line.IndexOf("=") + 1)
			break
		}
	}
	if ($instructions -eq "") { Write-Host "WARNING: No data folder instructions found in the package info" -ForegroundColor red }

	$dataFolders = $instructions.split(",")
	foreach ($folderName in $dataFolders)
	{
		if ($folderName -eq "NONE") { break }
		# first see if it already exists
		$alreadyExists = Test-Path $DATA_DIR\$folderName
		if (!$alreadyExists) 
		{ 
			Write-Host "Data folder requested, creating $DATA_DIR\$folderName"
			md $DATA_DIR\$folderName | Out-Null
		}
	}
}

function getPackageInstallInstructions([string]$packageRealName)
{
	pushd $PKG_DIR\$packageRealName
	$lines = Get-Content _PKG
	popd
	$instructions = ""
	foreach ($line in $lines)
	{
		if ($line.StartsWith("install="))
		{
			$instructions = $line.Substring($line.IndexOf("=") + 1)
			break
		}
	}
	if ($instructions -eq "") { Write-Host "WARNING: No installation instructions found in the package info" -ForegroundColor red }
	return $instructions
}

function getPackageRemoveInstructions([string]$packageRealName)
{
	pushd $PKG_DIR\$packageRealName
	$lines = Get-Content _PKG
	popd
	$instructions = ""
	foreach ($line in $lines)
	{
		if ($line.StartsWith("remove="))
		{
			$instructions = $line.Substring($line.IndexOf("=") + 1)
			break
		}
	}
	if ($instructions -eq "") { Write-Host "WARNING: No remove instructions found in the package info" -ForegroundColor red }
	return $instructions
}

function carryOutInstruction([string]$instruction, [string]$packagePath)
{
	#substitute any path variable strings
	$instruction = $instruction.replace('$BIN_DIR',$BIN_DIR)
	$instruction = $instruction.replace('$PKG_DIR',$PKG_DIR)
	$instruction = $instruction.replace('$CONF_DIR',$CONF_DIR)
	$instruction = $instruction.replace('$LIB_DIR',$LIB_DIR)
	$instruction = $instruction.replace('$DATA_DIR',$DATA_DIR)
	
	if ($instruction.IndexOf(">") -ne -1) # simple file transfer instruction
	{
		$delimiterIndex = $instruction.IndexOf(">")
		$file = $instruction.Substring(0, $delimiterIndex)
		$dest = $instruction.Substring($delimiterIndex + 1)

		#Write-Host "Copying from $packagePath\$file to $dest\$file" # DEBUG
		copy "$packagePath\$file" "$dest\"
	}
	elseif ($instruction.IndexOf("~") -ne -1) # create simple script runnable for external
	{
		$index = $instruction.IndexOf("~")
		$runnableName = $instruction.Substring(0, $index)
		
		$instruction = $instruction.Substring($index + 1)
		$index = $instruction.IndexOf("~")
		$runnableThing = $instruction.Substring(0, $index)

		$runnablePath = $instruction.Substring($index + 1)
		
		$runnableContent = "@echo off`n$runnableThing %*"

		#Write-Host "Creating $runnablePath\$runnableName.bat" # DEBUG

		Set-Content -Path "$runnablePath\$runnableName.bat" -value $runnableContent
	}
	elseif ($instruction.IndexOf("+") -ne -1) # create folder
	{
		$index = $instruction.IndexOf("+")
		$folderName = $instruction.Substring(0, $index)
		$folderPath = $instruction.Substring($index + 1)

		#Write-Host "Creating folder $folderPath\$folderName" # DEBUG
		md "$folderPath\$folderName" | Out-Null
	}
	elseif ($instruction.IndexOf("<") -ne -1)
	{
		$index = $instruction.IndexOf("<")
		$fileName = $instruction.Substring(0, $index)
		$filePath = $instruction.Substring($index + 1)

		# check for script removal
		if ($filePath.Substring(0, 1) -eq "<")
		{
			#Write-Host "Deleting $filePath\$fileName" # DEBUG
			$filePath = $filePath.Substring(1)
			del "$filePath\$fileName.bat" -force
		}
		else
		{
			#Write-Host "Deleting $filePath/$fileName" # DEBUG
			del "$filePath\$fileName" -Force -Recurse
		}
	}
}

function interpretInstructions([string]$instructionString, [string]$packagePath)
{
	if ($instructionString -eq "NOINSTRUCTIONS") { break }
	$instructions = $instructionString.split(",")
	foreach ($instruction in $instructions)
	{
		carryOutInstruction $instruction $packagePath
	}
}

# ------------------------ MAIN PROGRAM FLOW ---------------------------

if (!$noSpace) { echo "" }

# ---- LIST ----
if ($list -and $otherInfo -eq "update")
{
	pushd $PKG_DIR\labs-get-list
	echo "Fetching package list..."
	git pull origin -q
	popd
}

if ($list -and $otherInfo -eq "")
{
	# read in list file
	$packages = readListFile
	$filteredPackages = $packages

	if ($filter -ne "")
	{
		$filters = $filter.split(",")
		$filteredPackages = filterPackageListByTags $packages $filters $false
	}

	foreach ($package in $filteredPackages)
	{
		$packageName = getCSVCol $package 0
		$packageDescription = getCSVCol $package 3
		$packageTagString = getCSVCol $package 4
		$packageTags = getTagList $packageTagString

		# check if should filter based on default filters
		$defaultUnfit = $false
		if ($DEFAULT_TAGS -ne "") { $defaultUnfit = shouldFilter $DEFAULT_TAGS.split(",") $packageTags }

		# list only windows packages
		if (!$defaultUnfit -or $override)
		{
			Write-Host $packageName -ForegroundColor Green -NoNewLine
			Write-Host " - $packageDescription"
		}
	}
}

if ($list -and $otherInfo -eq "installed")
{
	$packages = readInstalledFile
	$filteredPackages = $packages

	if ($filter -ne "")
	{
		$filters = $filter.split(",")
		$filteredPackages = filterPackageListByTags $packages $filters $true
	}
	
	foreach ($package in $filteredPackages)
	{
		$name = getCSVCol $package 0
		write-host $name -ForegroundColor Green
	}
}

if ($list -and $otherInfo -eq "tags")
{
	$packages = readListFile
	$filteredPackages = $packages

	if ($filter -ne "")
	{
		$filters = $filter.split(",")
		$filteredPackages = filterPackageListByTags $packages $filters $false
	}
	
	foreach ($package in $filteredPackages)
	{
		$name = getCSVCol $package 0
		$tagString = getCSVCol $package 4

		$tagsArray = getTagList $tagString

		$defaultUnfit = $false
		if ($DEFAULT_TAGS -ne "") { $defaultUnfit = shouldFilter $DEFAULT_TAGS.split(",") $tagsArray }

		if ($defaultUnfit -and !$override) { continue; }
		
		write-host $name -ForegroundColor Green -NoNewLine

		foreach ($tag in $tagsArray) { write-host " | $tag" -NoNewLine }
		Write-Host ""
	}
}

# ---- CHECK DEPENDENCIES ----
if ($check)
{
	$packages = readInstalledFile
	$notInstalledList = @()
	foreach ($package in $packages)
	{
		$packageName = getCSVCol $package 0

		$packageDependencies = getCSVCol $package 4
			
		if ($packageDependencies -ne "NONE")
		{
			$dependencies = getTagList $packageDependencies
			foreach ($dependency in $dependencies)
			{
				$isInstalled = checkIfPackageInstalled $dependency
				if ($isInstalled -ne $true) { $notInstalledList += $dependency }
			}
		}
	}
	
	if ($notInstalledList.Length -eq 0)
	{
		echo "All required dependencies are installed."
		echo ""
		return
	}

	echo "The following dependencies are missing: "
	foreach ($required in $notInstalledList)
	{
		write-host $required -ForegroundColor Green
	}
}

# ---- UPDATE ----
if ($update -ne "")
{
	# make sure package exists
	$isInstalled = checkIfPackageInstalled $update
	if ($isInstalled -ne $true) { echo "Package '$update' wasn't found.`n"; exit }

	$packages = readInstalledFile

	$packageRealName = ""
	$packageUninstall = ""
	
	# get uninstall stuff
	foreach ($package in $packages)
	{
		$packageName = getCSVCol $package 0
		if ($packageName -eq $update) 
		{ 
			$packageRealName = getCSVCol $package 1
			$packageUninstall = getPackageRemoveInstructions $packageRealName
			break
		}
	}

	# run uninstall code
	interpretInstructions $packageUninstall "$PKG_DIR\$packageRealName"
	removePackageFromInstalled $update

	# update local package
	pushd "$PKG_DIR\$packageRealName"
	git pull origin
	popd

	# get install stuff
	$packages = readListFile
	foreach ($package in $packages)
	{
		$packageName = getCSVCol $package 0

		if ($packageName -eq $update)
		{
			$packageRealName = getCSVCol $package 1
			$packageLink = getCSVCol $package 2
			$packageDependencies = getCSVCol $package 5
			$packageTags = getCSVCol $package 4
			$packageInstallation = getPackageInstallInstructions $packageRealName
			
			# check dependencies
			$notInstalledList = @()
			if ($packageDependencies -ne "NONE")
			{
				$dependencies = getTagList $packageDependencies
				foreach ($dependency in $dependencies)
				{
					$isInstalled = checkIfPackageInstalled $dependency
					if ($isInstalled -ne $true) { $notInstalledList += $dependency }
				}
			}
			
			add-content -Path $INSTALLED_DATA_FILE -value "$packageName,$packageRealName,$packageLink,$packageTags,$packageDependencies"

			# run installation instructions
			interpretInstructions $packageInstallation "$PKG_DIR/$packageRealName"
			handlePackageDataFolder $packageRealName

			# install any required dependencies if user requested
			if ($notInstalledList.length -gt 0 -and $forceDependencies -ne $true) 
			{
				echo ""
				echo "Package '$packageName' requires (but did not find) the following packages: "
				foreach ($notInst in $notInstalledList) { write-host "$notInst" -ForegroundColor Yellow }
				echo ""
				
				$userOption = Read-Host -Prompt "Install packages? `n(Y - Yes [Will prompt for any of these dependencies' dependencies], N - No, A - All [Installs all dependencies and their dependencies without prompting again])`n"
				if ($userOption -eq "Y" -or $userOption -eq "y") { installPackageList $notInstalledList "noforce" }
				elseif ($userOption -eq "A" -or $userOption -eq "a") { installPackageList $notInstalledList "force" }
			}
			elseif ($notInstalledList.length -gt 0 -and $forceDependencies -eq $true) { installPackageList $notInstalledList "force" }
			
			break
		}
	}
}

# ---- REMOVE ----
if ($remove -ne "")
{
	# Validate that actually installed
	$isInstalled = checkIfPackageInstalled $remove
	if ($isInstalled -ne $true) { echo "Package '$remove' wasn't found.`n"; exit }

	$packageRealNameExt = "" # NOTE: assigned later
	
	# find all packages that require this as a dependency and warn
	$packages = readInstalledFile
	$required = @()
	$uninstallInstructions = ""
	foreach($package in $packages)
	{
		# if package is current one, store the removal instructions
		$packageName = getCSVCol $package 0
		if ($packageName -eq $remove) 
		{ 
			$packageRealName = getCSVCol $package 1 # NOTE: assigned here
			$packageRealNameExt = $packageRealName
			$uninstallInstructions = getPackageRemoveInstructions $packageRealName
		}
		
		# get depends (Add any packages to the array if it lists this package as dependency)
		$depend = getCSVCol $package 4
		$dependTags = getTagList $depend
		$containsRemove = tagListContains $dependTags $remove
		if ($containsRemove) { $required += $package }
	}
	
	if ($required.length -gt 0)
	{
		Write-Host "WARNING - Following packages required this package as a dependency:" -ForegroundColor Red
		foreach ($req in $required) 
		{ 
			$packageName = getCSVCol $req 0
			Write-Host "$packageName" -ForegroundColor Red 
		}

		if (!$force)
		{
			$input = Read-Host -Prompt "Confirm package removal: (y/n)"
			if ($input -eq "N" -or $input -eq "n") { echo "Package uninstallation canceled.`n"; exit }
		}
	}

	echo "Removing package '$remove'"

	# find all removal instructions
	interpretInstructions $uninstallInstructions "$PKG_DIR/$packageRealNameExt"
	
	# delete git file
	pushd $PKG_DIR
	del $packageRealNameExt -Force -Recurse
	popd

	removePackageFromInstalled $remove

	echo "Package removed successfully."
}

# ---- INSTALL ----
if ($install -ne "")
{
	# first read in file
	$packages = readListFile
	$packageLink = ""

	$found = $false # represents if found the package specified or not

	# search for desired package
	foreach ($package in $packages)
	{
		$packageName = getCSVCol $package 0
		
		if ($packageName -eq $install)
		{
			$found = $true

			$alreadyInstalled = checkIfPackageInstalled $packageName
			if ($alreadyInstalled)
			{
					echo "Package '$packageName' has already been installed. If attempting to update, run the command 'labs-get -update $packageName'`n"
					exit 
			}
			
			$packageLink = getCSVCol $package 2
			$packageRealName = getCSVCol $package 1
			$packageDependencies = getCSVCol $package 5
			$packageTags = getCSVCol $package 4
			
			# check dependencies
			$notInstalledList = @()
			if ($packageDependencies -ne "NONE")
			{
				$dependencies = getTagList $packageDependencies
				foreach ($dependency in $dependencies)
				{
					$isInstalled = checkIfPackageInstalled $dependency
					if ($isInstalled -ne $true) { $notInstalledList += $dependency }
				}
			}
			
			echo "Retrieving package '$packageLink'..."

			# clone the git repository into the packages folder
			pushd $PKG_DIR
			git clone $packageLink
			popd

			# add to installed list
			echo "Adding package info to installed data..."
			# echo "$packageName,$packageDependencies" >> pkg\installed.dat
			Add-Content -Path $INSTALLED_DATA_FILE -value "$packageName,$packageRealName,$packageLink,$packageTags,$packageDependencies"

			# run installation instructions
			$packageInstallation = getPackageInstallInstructions $packageRealName
			interpretInstructions $packageInstallation "$PKG_DIR/$packageRealName"
			handlePackageDataFolder $packageRealName

			echo "Package '$packageName' installed"

			# install any required dependencies if user requested
			if ($notInstalledList.length -gt 0 -and $forceDependencies -ne $true) 
			{
				echo ""
				echo "Package '$packageName' requires (but did not find) the following packages: "
				foreach ($notInst in $notInstalledList) { write-host "$notInst" -ForegroundColor Yellow }
				echo ""
				
				$userOption = Read-Host -Prompt "Install packages? `n(Y - Yes [Will prompt for any of these dependencies' dependencies], N - No, A - All [Installs all dependencies and their dependencies without prompting again])`n"
				if ($userOption -eq "Y" -or $userOption -eq "y") { installPackageList $notInstalledList "noforce" }
				elseif ($userOption -eq "A" -or $userOption -eq "a") { installPackageList $notInstalledList "force" }
			}
			elseif ($notInstalledList.length -gt 0 -and $forceDependencies -eq $true) { installPackageList $notInstalledList "force" }
			
			break
		}
	}

	if (!$found) { echo "Package '$install' wasn't found. Try running `"labs-get -list -update`" to update the package list, and then try again."; }
}

if (!$noSpace) { echo "" }
