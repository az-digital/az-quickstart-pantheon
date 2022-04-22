#!/bin/bash
set -e
# Set generic config
FILE=""
WIPE=true
HOST=localhost
SERVICE=database
DATABASE=migrate
PORT=3306
USER=root
# PARSE THE ARGZZ
while (( "$#" )); do
  case "$1" in
    # This option is now handled with landos built in dynamic options
    # we just keep it around for option validation
    -h|--host|--host=*)
      if [ "${1##--host=}" != "$1" ]; then
        shift
      else
        shift 2
      fi
      ;;
    --no-wipe)
        WIPE=false
        shift
      ;;
    --)
      shift
      break
      ;;

    -*|--*=)
      shift
      ;;
    *)
      if [[ "$1" = /* ]]; then
        FILE="${1//\\//}"
      else
        FILE="$(pwd)/${1//\\//}"
      fi
      shift
      ;;
  esac
done

# Set positional arguments in their proper place
eval set -- "$FILE"
PV=""
CMD=""
# Ensure file perms on linux
if [ "$LANDO_HOST_OS" = "linux" ] && [ $(id -u) = 0 ]; then
  chown $LANDO_HOST_UID:$LANDO_HOST_GID "${FILE}"
fi
# Use file or stdin
if [ ! -z "$FILE" ]; then
  # Validate we have a file
  if [ ! -f "$FILE" ]; then
    echo "File $FILE not found!"
    exit 1;
  fi
  CMD="$FILE"
else
  CMD="mysql -h $HOST -P $PORT -u $USER ${LANDO_EXTRA_DB_IMPORT_ARGS}"
  # Read stdin into DB
  $CMD #>/dev/null
  exit 0;
fi
# Inform the user of things
echo "Preparing to import $FILE into database '$DATABASE' on service '$SERVICE' as user $USER..."
# Wipe the database if set
if [ "$WIPE" == "true" ]; then
  echo ""
  echo "Emptying $DATABASE... "
  echo "NOTE: See the --no-wipe flag to avoid this step!"
  # Build the SQL prefix
  SQLSTART="mysql -h $HOST -P $PORT -u $USER ${LANDO_EXTRA_DB_IMPORT_ARGS} $DATABASE"
  # Gather and destroy tables
  TABLES=$($SQLSTART -e 'SHOW TABLES' | awk '{ print $1}' | grep -v '^Tables' || true)
  # PURGE IT ALL! Drop views and tables as needed
  for t in $TABLES; do
    echo "Dropping $t from $DATABASE database..."
    $SQLSTART <<-EOF
      SET FOREIGN_KEY_CHECKS=0;
      DROP VIEW IF EXISTS \`$t\`;
      DROP TABLE IF EXISTS \`$t\`;
EOF
  done
fi
# Check to see if we have any unzipping options or GUI needs
if command -v gunzip >/dev/null 2>&1 && gunzip -t $FILE >/dev/null 2>&1; then
  echo "Gzipped file detected!"
  if command -v pv >/dev/null 2>&1; then
    CMD="pv $CMD"
  else
    CMD="cat $CMD"
  fi
  CMD="$CMD | gunzip"
elif command -v unzip >/dev/null 2>&1 && unzip -t $FILE >/dev/null 2>&1; then
  echo "Zipped file detected!"
  CMD="unzip -p $CMD"
  if command -v pv >/dev/null 2>&1; then
    CMD="$CMD | pv"
  fi
else
  if command -v pv >/dev/null 2>&1; then
    CMD="pv $CMD"
  else
    CMD="cat $CMD"
  fi
fi
CMD="$CMD | mysql -h $HOST -P $PORT -u $USER ${LANDO_EXTRA_DB_IMPORT_ARGS} $DATABASE"
# Import
echo "Importing $FILE..."
eval "$CMD" && echo "Import complete!" || echo "Import failed."