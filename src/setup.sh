#!/bin/bash
#----------------------------------------------
#	labs-get setup script v1.0.0-lx
#	Date Created: 12/22/2015
#	Date Edited: 12/24/2015
#	Copyright Â ©2015 Digital Warrior Labs
#	Author: Nathan Martindale (WildfireXIII)
#	Description: Setup script for the linux labs-get package manager
#		Run this on first-time use, or if files/env variables are missing
#----------------------------------------------

# PREREQ: MUST HAVE GIT INSTALLED in order to run this setup

# ------------------- FUNCTIONS ---------------------
function setBinDir()
{
	echo "No bin path defined!"
	echo -n "Enter path to bin folder: "
	read binPath
	echo "BIN_DIR=\"$binPath\""
}

function setLibDir()
{
	echo "No lib path defined!"
	echo -n "Enter path to lib folder: "
	read libPath
	echo "LIB_DIR=\"$libPath\""
}

function setConfDir()
{
	echo "No conf path defined!"
	echo -n "Enter path to conf folder: "
	read confPath
	echo "CONF_DIR=\"$confPath\""
}

function setDataDir()
{
	echo "No data path defined!"
	echo -n "Enter path to data folder: "
	read dataDir
	echo "DATA_DIR=\"$dataPath\""
}

function setPkgDir()
{
	echo "No pkg path defined!"
	echo -n "Enter path to pkg folder: "
	read pkgPath
	echo "PKG_DIR=\"$pkgPath\""
}

function addToPath()
{
	PATH=$PATH:$BIN_DIR
	echo "PATH=$PATH:$BIN_DIR" >> ~/.bashrc
}

function getGitList()
{
	echo "Retrieving list git repo..."
	echo -n "Enter git url for package list: "
	read url
	git clone $url $PKG_DIR/labs-get-list
	echo "List data git repo installed"
}

function getTags()
{
	echo -n "Enter default package tags to filter (can be changed later in the default-tags.dat file in the data directory): "
	read tags
	echo "$tags" > $DATA_DIR/labs-get/default-tags.dat
}

# ------------------- MAIN PROGRAM FLOW -------------------

# check existence of environment variables
echo "Checking environment variables..."
if [ -z ${BIN_DIR+x} ]; then setBinDir(); fi
if [ -z ${LIB_DIR+x} ]; then setLibDir(); fi
if [ -z ${CONF_DIR+x} ]; then setConfDir(); fi
if [ -z ${DATA_DIR+x} ]; then setDataDir(); fi
if [ -z ${PKG_DIR+x} ]; then setPkgDir(); fi
source /etc/environment # update environment variables

# make sure that the BIN_DIR exists within the path variable
echo "Checking PATH..."

# insert clean runnable to bin folder and see if possible to run
echo "echo 'Bin directory is in path!'" > $BIN_DIR/path_check.sh
chmod +x $BIN_DIR/path_check.sh
if ! [[ path_check ]]; then
	addToPath()
fi
del $BIN_DIR/path_check.sh

# move primary script into the bin folder so it can be run
echo "Copying primary program files..."
cp labs-get.sh $BIN_DIR
echo "Program files located appropriately"

# create the data directory if not found, and create all necessary data files
echo "Setting up data files..."
if [ ! -e "$DATA_DIR/labs-get" ]; then md $DATA_DIR/labs-get; fi
if [ ! -e "$PKG_DIR/labs-get-list" ]; then getGitList(); fi
if [ ! -e "$DATA_DIR/labs-get/installed.dat" ]; then echo "name,packagename,url,tags,dependencies" > $DATA_DIR/labs-get/installed.dat; fi
if [ ! -e "$DATA_DIR/labs-get/default-tags.dat" ]; then getTags(); fi
