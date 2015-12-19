copy src\labs-get.ps1 env\bin\labs-get.ps1 #comment for setup testing, uncomment for pkgmngr testing
copy src\setup.bat env\pkg\labs-get\setup.bat
#copy src\labs-get.ps1 env\pkg\labs-get\labs-get.ps1 #UNcomment for setup testing, comment for pkgmngr testing

# Add to the path variable
$env:Path += ";C:\dwl\lab\LabPkgMngr\env\bin"
$env:DATA_DIR = "C:\dwl\lab\LabPkgMngr\env\data"
$env:BIN_DIR = "C:\dwl\lab\LabPkgMngr\env\bin"
$env:PKG_DIR = "C:\dwl\lab\LabPkgMngr\env\pkg"
$env:CONF_DIR = "UNIMPORTANT"
$env:LIB_DIR = "UNIMPORTANT"

cd env
