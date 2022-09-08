#!/bin/bash

BRANCH="${GITHUB_REF#refs/heads/}" >> $GITHUB_ENV
# BRANCH="release-teste"
BRANCH_PREFIX="${BRANCH%%[/-]*}" >> $GITHUB_ENV

if [[ $BRANCH_PREFIX == 'release' ]]
then
    SEMANTIC="major" >> $GITHUB_ENV
elif [[ $BRANCH_PREFIX == 'feature' ]]
then 
    SEMANTIC="minor" >> $GITHUB_ENV
elif [[ $BRANCH_PREFIX == 'hotfix' ]]
then 
    SEMANTIC="patch" >> $GITHUB_ENV
else
    echo "Any branch compatible with semantic version"
    exit 1
fi

echo $SEMANTIC
echo ::set-output name=semantic-version::$SEMANTIC