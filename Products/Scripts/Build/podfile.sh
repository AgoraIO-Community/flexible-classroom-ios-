#!/bin/sh
# cd this file path
cd $(dirname $0)
echo pwd: `pwd`

export LANG=en_US.UTF-8

# parameters 0: source, 1: binary
Dependency_Type=$1

python ./cloud_pod.py ${Dependency_Type} 1 