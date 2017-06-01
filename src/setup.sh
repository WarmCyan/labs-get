#!/bin/bash
#----------------------------------------------
#	labs-get setup script v1.0.0-lx
#	Date Created: 12/22/2015
#	Date Edited: 5/16/2017
#	Copyright © 2017 Digital Warrior Labs
#	Author: Nathan Martindale (WildfireXIII)
#	Description: Setup script for the linux labs-get package manager
#		Run this on first-time use, or if files/env variables are missing
#----------------------------------------------

# PREREQ: MUST HAVE GIT INSTALLED in order to run this setup

# ------------------- FUNCTIONS ---------------------

function createEnvironment()
{
	if [ ! -f ~/.env ]; then
		echo "No environment file found"
		touch ~/.env
		echo "Environment file created!"
	#else
		#echo "Clearing existing environment file"
		#echo "" > ~/.env
	fi
}

# NOTE: this should always be run at the END of the environment script, in case
# the local has to override something
function addLocalEnvironment()
{
	#echo '
	#if [ -f $DIR_CONF/.env_l ]; then
		#source $DIR_CONF/.env_l
	#fi
	#' >> ~/.env
	echo '
# load local environment if it exists
[[ -f $CONF_DIR/.env_l ]] && . $CONF_DIR/.env_l
	' >> ~/.env
}

function setBinDir()
{
	echo "No bin path defined!"
	echo -n "Enter path to bin folder: "
	read binPath
	#echo "BIN_DIR=\"$binPath\"" >> /etc/environment
	#echo "BIN_DIR=\"$binPath\"" >> ~/.bash_profile
	
	echo "export BIN_DIR=\"$binPath\"" >> ~/.env
}

function setLibDir()
{
	echo "No lib path defined!"
	echo -n "Enter path to lib folder: "
	read libPath
	#echo "LIB_DIR=\"$libPath\"" >> /etc/environment
	echo "export LIB_DIR=\"$libPath\"" >> ~/.env
}

function setConfDir()
{
	echo "No conf path defined!"
	echo -n "Enter path to conf folder: "
	read confPath
	#echo "CONF_DIR=\"$confPath\"" >> /etc/environment
	echo "export CONF_DIR=\"$confPath\"" >> ~/.env
}

function setDataDir()
{
	echo "No data path defined!"
	echo -n "Enter path to data folder: "
	read dataPath
	#echo "DATA_DIR=\"$dataPath\"" >> /etc/environment
	echo "export DATA_DIR=\"$dataPath\"" >> ~/.env
}

function setPkgDir()
{
	echo "No pkg path defined!"
	echo -n "Enter path to pkg folder: "
	read pkgPath
	#echo "PKG_DIR=\"$pkgPath\"" >> /etc/environment
	echo "export PKG_DIR=\"$pkgPath\"" >> ~/.env
}

function setTmpDir()
{
	echo "No tmp path defined!"
	echo -n "Enter path to tmp folder: "
	read tmpPath
	#echo "TMP_DIR=\"$tmpPath\"" >> /etc/environment
	echo "export TMP_DIR=\"$tmpPath\"" >> ~/.env
}

function addToPath()
{
	echo "Bin folder not found in path, adding now..."
	#PATH=$PATH:$BIN_DIR
	#echo 'PATH=$PATH:$BIN_DIR' >> ~/.bashrc
	echo 'export PATH=${PATH}:$BIN_DIR' >> ~/.env
	echo '
# get environment variables
[[ -f ~/.env ]] && . ~/.env
	' >> ~/.bashrc
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
echo -n "Set environment variables? (y/n): "
read choice
echo "Checking environment variables..."
createEnvironment
if [ -z ${BIN_DIR+x} || "$choice" == "y" ]; then 
	setBinDir
fi
if [ -z ${LIB_DIR+x} || "$choice" == "y" ]; then 
	setLibDir
fi
if [ -z ${CONF_DIR+x} || "$choice" == "y" ]; then 
	setConfDir
fi
if [ -z ${DATA_DIR+x} || "$choice" == "y" ]; then 
	setDataDir
fi
if [ -z ${PKG_DIR+x} || "$choice" == "y" ]; then 
	setPkgDir
fi
if [ -z ${TMP_DIR+x} || "$choice" == "y" ]; then 
	setTmpDir
fi
#source /etc/environment # update environment variables
addLocalEnvironment
source ~/.env

# make sure that the BIN_DIR exists within the path variable
echo "Checking PATH..."

# insert clean runnable to bin folder and see if possible to run
echo "echo 'Bin directory is in path!'" > $BIN_DIR/path_check.sh
chmod +x $BIN_DIR/path_check.sh
#if [ ! $(command -v path_check.sh > /dev/null 2>&1) ]; then
	#addToPath
#fi
command -v path_check.sh > /dev/null 2>&1 || addToPath
rm $BIN_DIR/path_check.sh

source ~/.env

# move primary script into the bin folder so it can be run
echo "Copying primary program files..."
cp labs-get $BIN_DIR
chmod +x $BIN_DIR/labs-get
echo "Program files located appropriately"

# create the data directory if not found, and create all necessary data files
echo "Setting up data files..."
if [ ! -e "$DATA_DIR/labs-get" ]; then 
	mkdir $DATA_DIR/labs-get 
fi
if [ ! -e "$PKG_DIR/labs-get-list" ]; then 
	getGitList
fi
if [ ! -e "$DATA_DIR/labs-get/installed.dat" ]; then 
	echo "name,packagename,url,tags,dependencies" > $DATA_DIR/labs-get/installed.dat 
fi
if [ ! -e "$DATA_DIR/labs-get/default-tags.dat" ]; then 
	getTags
fi
echo "All data files properly installed"

echo "Setup complete!"
