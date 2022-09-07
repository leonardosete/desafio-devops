#!/bin/bash

BRANCH="${GITHUB_REF#refs/heads/}"
# BRANCH="release-teste"
BRANCH_PREFIX="${BRANCH%%[/-]*}"
         
if [[ $BRANCH_PREFIX == 'release' ]]
then 
    SEMANTIC="major"
elif [[ $BRANCH_PREFIX == 'feature' ]]
then 
    SEMANTIC="minor"
elif [[ $BRANCH_PREFIX == 'hotfix' ]]
then 
    SEMANTIC="patch"
else
  echo "Any branch compatible with semantic version"
  exit 1
fi

# echo ::set-output name=semantic-version::$SEMANTIC