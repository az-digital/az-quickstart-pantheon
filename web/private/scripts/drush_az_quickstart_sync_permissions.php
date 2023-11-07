<?php

// Ensure new permissions are synced.
echo "Syncing permissions...\n";
passthru('drush -n -y az-core-config-add-permissions');
echo "Permissions sync complete.\n";
