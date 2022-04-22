#!/bin/bash
set -e
# Set generic config
SITE=none

# PARSE THE ARGZZ
while getopts s:site: flag
do
    case "${flag}" in
        s) site=${OPTARG};;
        site) site=${OPTARG};;

    esac
done

echo "Enabling az_migration az_carousel az_paragraphs_html..."
/app/vendor/bin/drush --root=/app/web en -y az_migration az_carousel az_paragraphs_html

echo "Waking $site ..."
terminus env:wake $site
echo "Getting public file path ..."
publicpath=$(terminus drush $site -- vget file_directory_path --exact)
echo "Getting base path ..."
filebasepath=$(terminus domain:list $site --filter type=platform --field id)

# Setting config
echo "Setting basefilepath to $filebasepath ..."
/app/vendor/bin/drush --root=/app/web cset -y az_migration.settings migrate_d7_filebasepath $filebasepath
echo "Setting public_path to $publicpath ..."
/app/vendor/bin/drush --root=/app/web cset -y az_migration.settings migrate_d7_public_path $publicpath

echo "Settings set successfully"
echo "If you have not already done so, you can download a copy of the source site with these commands"
echo "terminus backup:create $site --element=db"
echo "terminus backup:get $site --element=db | xargs wget -O database.sql.gz"
echo "Then you can run"
echo "lando migrate-db-import database.sql.gz"