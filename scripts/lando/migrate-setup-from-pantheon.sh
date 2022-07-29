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

echo "Waking $site ..."
terminus env:wake $site

echo "Enabling az_migration az_carousel az_paragraphs_html..."
/app/vendor/bin/drush --root=/app/web en -y az_migration az_carousel az_paragraphs_html

echo "Getting public file path ..."
publicpath=$(terminus drush $site -- vget file_directory_path --exact)
echo "Getting base path ..."
filebasepath=$(terminus domain:list $site --filter type=platform --field id)

# Setting config
echo "Setting basefilepath to $filebasepath ..."
/app/vendor/bin/drush --root=/app/web cset -y az_migration.settings migrate_d7_filebasepath $filebasepath
echo "Setting public_path to $publicpath ..."
/app/vendor/bin/drush --root=/app/web cset -y az_migration.settings migrate_d7_public_path $publicpath
echo "Creating backup of $site so we can download the latest changes..."
terminus backup:create $site --element=db
echo "Downloading database for $site and saving as database.taz.gz..."
terminus backup:get $site --element=db | xargs wget -O database.sql.gz
echo "Creating a new database called migrate in the database service..."
/usr/bin/mysql -h database -uroot -e "CREATE DATABASE IF NOT EXISTS migrate; GRANT ALL PRIVILEGES ON migrate.* TO 'pantheon'@'%' IDENTIFIED by 'pantheon';"
chmod 777 /app/web/sites/default/settings.php
printf "\$databases['migrate']['default'] = [\n  'driver' => 'mysql',\n  'namespace' => 'Drupal\Core\Database\Driver\mysql',\n  'database' => 'migrate',\n  'username' => 'pantheon',\n  'password' => 'pantheon',\n  'port' => '3306',\n  'host' => 'database',\n  'prefix' => '',\n];" >> /app/web/sites/default/settings.php
chmod 644 /app/web/sites/default/settings.php
echo "You are free to use lando migrate-db-import database.sql.gz"
