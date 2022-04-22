<?php

/**
 * @file
 * Upstream configuration file for AZ QuickStart sites.
 *
 * IMPORTANT:
 * Do not modify this file.  This file is maintained by the AZ QuickStart
 * upstream maintainers.
 *
 * Site-specific modifications belong in settings.php, not this file. This file
 * may change in future releases and modifications would cause conflicts when
 * attempting to apply upstream updates.
 */

/**
 * Allow loading config for the 'migrate' database from
 * sites/default/files/private/migration_config.json
 */
const MIGRATION_DB_CONFIG_FILE_PATH = 'sites/default/files/private/migration_config.json';
if (file_exists(MIGRATION_DB_CONFIG_FILE_PATH)) {
  $migration_config = json_decode(file_get_contents(MIGRATION_DB_CONFIG_FILE_PATH), TRUE);
  if (isset($migration_config)) {
    $databases['migrate']['default'] = [
      'database' => $migration_config['mysql_database'],
      'password' => $migration_config['mysql_password'],
      'host' => $migration_config['mysql_host'],
      'port' => $migration_config['mysql_port'],
      'username' => $migration_config['mysql_username'],
      'driver' => 'mysql',
      'prefix' => '',
      'collation' => 'utf8mb4_general_ci',
    ];
  }
}

/**
 * Default configuration for all Pantheon Environment requests.
 *
 * Settings in this block will be loaded for ALL requests (web and CLI) to
 * Pantheon environments.
 */
if (defined('PANTHEON_ENVIRONMENT')) {
  /**
   * Redirect all http requests to a pantheonsite.io domain to https
   */
  if (php_sapi_name() !== 'cli') {
    if (
      preg_match('/.*\.pantheonsite\.io$/', $_SERVER['HTTP_HOST']) &&
      (!isset($_SERVER['HTTP_USER_AGENT_HTTPS'])
        || $_SERVER['HTTP_USER_AGENT_HTTPS'] !== 'ON')
    ) {
      header('HTTP/1.0 301 Moved Permanently');
      header('Location: https://' . $_SERVER['HTTP_HOST'] . $_SERVER['REQUEST_URI']);
      exit();
    }
  }

  /**
   * Environment-specific performance and caching configuration overrides.
   *
   * @see https://pantheon.io/docs/drupal-cache/
   */
  // Performance settings for test and live environments.
  if (in_array($_ENV['PANTHEON_ENVIRONMENT'], ['test', 'live'])) {
    // Browser and proxy cache maximum age - 6 hours.
    $config['system.performance']['cache']['page']['max_age'] = 21600;

    // Aggregate CSS files - on.
    $config['system.performance']['css']['preprocess'] = 1;

    // Aggregate CSS files - on.
    $config['system.performance']['js']['preprocess'] = 1;
  }

  // Performance settings for development environments, including multidev.
  else {
    // Browser and proxy cache maximum age - No caching.
    $config['system.performance']['cache']['page']['max_age'] = 0;

    // Aggregate CSS files - off.
    $config['system.performance']['css']['preprocess'] = 0;

    // Aggregate CSS files - off.
    $config['system.performance']['js']['preprocess'] = 0;
  }

  /**
   * Environment Indicator module settings.
   * see: https://pantheon.io/docs/environment-indicator
   */
  // Pantheon Env Specific Config
  if (isset($_ENV['PANTHEON_ENVIRONMENT'])) {
    switch ($_ENV['PANTHEON_ENVIRONMENT']) {
      case 'lando':
        // Localdev or Lando environments.
        $config['environment_indicator.indicator']['name'] = 'Local Dev (Lando)';
        $config['environment_indicator.indicator']['bg_color'] = '#990055';
        $config['environment_indicator.indicator']['fg_color'] = '#ffffff';
        break;
      case 'dev':
        $config['environment_indicator.indicator']['name'] = 'Dev (Pantheon)';
        $config['environment_indicator.indicator']['bg_color'] = '#4a634e';
        $config['environment_indicator.indicator']['fg_color'] = '#ffffff';
        break;
      case 'test':
        $config['environment_indicator.indicator']['name'] = 'Test (Pantheon)';
        $config['environment_indicator.indicator']['bg_color'] = '#a95c42';
        $config['environment_indicator.indicator']['fg_color'] = '#ffffff';
        break;
      case 'live':
        $config['environment_indicator.indicator']['name'] = 'LIVE (Pantheon)';
        $config['environment_indicator.indicator']['bg_color'] = '#0f0f0f';
        $config['environment_indicator.indicator']['fg_color'] = '#dddddd';
        break;
      default:
        // Multidev catchall.
        $config['environment_indicator.indicator']['name'] = $_ENV['PANTHEON_ENVIRONMENT'] . ' (Pantheon)';
        $config['environment_indicator.indicator']['bg_color'] = '#1e5288';
        $config['environment_indicator.indicator']['fg_color'] = '#ffffff';
        break;
    }
  }
}
else {
  $config['environment_indicator.indicator']['name'] = 'Local';
  $config['environment_indicator.indicator']['bg_color'] = '#707070';
  $config['environment_indicator.indicator']['fg_color'] = '#ffffff';
}
