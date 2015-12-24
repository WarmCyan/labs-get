#!/bin/bash

#uncomment for lab testing, comment for setup testing:
# cp src/labs-get env/bin
if [ ! -e "env/pkg/labs-get" ]; then mkdir env/pkg/labs-get; fi

cp src/setup.sh env/pkg/labs-get

#comment for lab testing, uncomment for setup testing:
cp src/labs-get env/pkg/labs-get

cd env
