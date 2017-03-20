#!/usr/bin/env bash

# script for gathering requirements for pip from all subdirectories to make local development easier

echo "#it should be sum of all other requirements.txt files from subfolders just to make easier manage images for docker" > base/requirements-sum.txt
echo "#it can be done by executing:" >> base/requirements-sum.txt
echo "#find . -name requirements.txt -exec cat {}  >> requirements-sum.txt \; " >> base/requirements-sum.txt
echo "#sort -u base/requirements-sum.txt -o base/requirements-sum.txt" >> base/requirements-sum.txt
find . -name requirements.txt -exec cat {} >> base/requirements-sum.txt \;
sort -u base/requirements-sum.txt -o base/requirements-sum.txt

