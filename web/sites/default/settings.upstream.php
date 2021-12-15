<?php

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
