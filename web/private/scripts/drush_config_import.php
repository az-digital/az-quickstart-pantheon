<?php

// Import all config changes.
echo "Importing configuration from config sync directory...\n";
passthru('drush config-import -y');
echo "Import of configuration complete.\n";

//Clear all cache
echo "Rebuilding cache.\n";
passthru('drush cr');
echo "Rebuilding cache complete.\n";
