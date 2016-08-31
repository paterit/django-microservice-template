#!/usr/bin/env bash

# script for gathering requirements for pip from all subdirectories to make local development easier

echo "#it should be sum of all other requirements.txt files from subfolders just to make easier to create virtualenv for development" > requirements-dev.txt
echo "#it can be done by executing:" >> requirements-dev.txt
echo "#find . -name requirements.txt -exec cat {}  >> requirements-dev.txt \; " >> requirements-dev.txt
find . -name requirements.txt -exec cat {}  >> requirements-dev.txt \;

