@echo off
copy src\labs-get.ps1 pkg\win\labs-get.ps1
copy src\normalsetup.bat pkg\win\normalsetup.bat
copy src\setup.bat pkg\win\setup.bat
pushd pkg\win
git add *
git commit -m %1
git push origin
popd
