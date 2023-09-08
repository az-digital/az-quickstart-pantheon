<?php

// Ensure update mode is 'merge' and run config-distro-update.
echo "Running Config Distro update...\n";
passthru('drush -n -y config-distro-update --update-mode=1');
echo "Config Distro update complete.\n";

// Rebuild the cache.
echo "Clearing cache.\n";
passthru('drush cr');
echo "Cache rebuild complete.\n";
