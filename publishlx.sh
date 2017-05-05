#!/bin/bash
echo "Copying..."
cp src/labs-get pkg/lx/labs-get
cp src/setup.sh pkg/lx/setup.sh
echo "Commiting and pushing..."
pushd pkg/lx
git add *
git commit -m "$1"
git push origin
popd
echo "Published!"
