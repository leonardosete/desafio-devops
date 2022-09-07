#!/bin/bash

BRANCH="${GITHUB_REF#refs/heads/}" >> $GITHUB_ENV
BRANCH_PREFIX="${BRANCH%%[/-]*}" >> $GITHUB_ENV
         
if [[ $BRANCH_PREFIX == 'release' ]]
then 
  echo "SEMANTIC=major" >> $GITHUB_ENV
elif [[ $BRANCH_PREFIX == 'feature' ]]
then 
  echo "SEMANTIC=minor" >> $GITHUB_ENV
elif [[ $BRANCH_PREFIX == 'hotfix' ]]
then 
  echo "SEMANTIC=patch" >> $GITHUB_ENV
else
  echo "Any branch compatible with semantic version"
  exit 1
fi
      