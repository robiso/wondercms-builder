#!/bin/bash
# Build a zip archive with wondercms files

# change this to master once the dev branch has been merged
BRANCH=dev
# change this to the proper location of the zip file
ZIP_PATH=/tmp/latest.zip

TMP_DIR=/tmp/wondercms-$RANDOM

# get the latest files
git clone --depth 1 -b "$BRANCH" https://github.com/robiso/wondercms "$TMP_DIR"

cd "$TMP_DIR"
# install javascript dependencies
yarn install
# minify JS and CSS
grunt
# install php dependencies
composer install

# make zip archive
# but first remove the previous one (or it will just append to it)
if [ -f "$ZIP_PATH" ]; then
    rm "$ZIP_PATH"
fi

zip -r "$ZIP_PATH" assets index.php plugins src/classes themes vendor version
