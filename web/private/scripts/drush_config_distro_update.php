<?php

// Ensure update mode is 'merge' and run config-distro-update.
echo "Running Config Distro update...\n";
passthru('drush -n -y state:set config_sync.update_mode 1 --input-format=integer');
passthru('drush -n -y config-distro-update');
echo "Config Distro update complete.\n";

// Rebuild the cache.
echo "Clearing cache.\n";
passthru('drush cr');
echo "Cache rebuild complete.\n";
