copy src\labs-get.ps1 env\bin\labs-get.ps1

# Add to the path variable
$env:Path += ";C:\dwl\lab\LabPkgMngr\env\bin"
$env:DATA_DIR = "C:\dwl\lab\LabPkg\Mngr\env\data"
$env:BIN_DIR = "C:\dwl\lab\LabPkg\Mngr\env\bin"
$env:PKG_DIR = "C:\dwl\lab\LabPkg\Mngr\env\pkg"
$env:CONF_DIR = "UNIMPORTANT"
$env:LIB_DIR = "UNIMPORTANT"

cd env
