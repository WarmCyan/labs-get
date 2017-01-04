@echo off
copy src\labs-get pkg\lx\labs-get
copy src\setup.sh pkg\lx\setup.sh
pushd pkg\lx
git add *
git commit -m %1
git push origin
popd
