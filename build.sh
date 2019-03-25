#!/bin/bash
# Build a zip archive with wondercms files

# change this to master once the dev branch has been merged
BRANCH=dev
# change this to where the script should output the zip file
ZIP_PATH=$(pwd)/out

# attempt to make zip path if does not exist
if [ ! -d "$ZIP_PATH" ]; then
    mkdir -p "$ZIP_PATH"
fi

# name zip file based on branch and date
CDATE=$(date "+%Y-%m-%d")
ZIP_FILE=$ZIP_PATH/wondercms_$BRANCH-$CDATE.zip

# change this to set where WonderCMS should be downloaded and built
BUILD_DIR=src/wondercms_$BRANCH-$CDATE

# attempt to make directory for building if does not exist
if [ ! -d "$BUILD_DIR" ]; then
    mkdir -p "$BUILD_DIR"
fi

# get the latest files
git clone --depth 1 -b "$BRANCH" https://github.com/robiso/wondercms "$BUILD_DIR"

# change to git clone directory
cd "$BUILD_DIR" || exit
# install javascript dependencies
yarn install
# minify JS and CSS
./node_modules/.bin/grunt
# install php dependencies
composer install

# remove the previous zip (or it will just append to it)
if [ -f "$ZIP_FILE" ]; then
    rm "$ZIP_FILE"
fi

# check for apache command to include htaccess files
if [ "$1" == "--apache" ]; then
    ZIP_APPEND=$(echo .htaccess*)
else
    ZIP_APPEND=""
fi

# make zip archive
zip -r "$ZIP_FILE" assets index.php plugins src/classes themes vendor version $ZIP_APPEND

# list extra apache files included
# or notify that invalid command was ignored
echo ""
if [ -n "$ZIP_APPEND" ]; then
    echo "Option $1 was selected. Additional files included:"
    for arg in $ZIP_APPEND; do
        echo "    $arg"
    done
    echo ""
elif [ -n "$1" ]; then
    echo "Unknown option $1 was ignored!"
    echo "Use '.build.sh --apache' to build for an apache server."
    echo ""
fi

# check for successful zip creation
if [ -f "$ZIP_FILE" ]; then
    echo "Build in $BUILD_DIR successful!"
    echo "Output: $ZIP_FILE"
else
    echo "Build command failed!"
    exit 1
fi
