#!/bin/bash
#----------------------------------------------
#	labs-get setup script v1.0.0-lx
#	Date Created: 12/22/2015
#	Date Edited: 12/22/2015
#	Copyright ©2015 Digital Warrior Labs
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


# ------------------- MAIN PROGRAM FLOW -------------------

# check existence of environment variables
echo "Checking environment variables..."
if [ -z ${BIN_DIR+x} ]; then setBinDir(); fi
if [ -z ${LIB_DIR+x} ]; then setLibDir(); fi
if [ -z ${CONF_DIR+x} ]; then setConfDir(); fi
if [ -z ${DATA_DIR+x} ]; then setDataDir(); fi
if [ -z ${PKG_DIR+x} ]; then setPkgDir(); fi
source /etc/environment # update environment variables

