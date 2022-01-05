# Arizona Quickstart Composer-enabled Pantheon Upstream 
This upstream is adapted from Pantheon's standard Drupal 9 upstream and works with the Platform's Integrated Composer build process.

Unlike with earlier Pantheon upstreams (e.g. the UA Quickstart Drupal 7 upstream), files such as Drupal Core that you are unlikely to adjust while building sites are not in the main branch of the repository. Instead, they are referenced as dependencies that are installed by Composer.

For more information and detailed installation guides, please visit the Integrated Composer Pantheon documentation: https://pantheon.io/docs/integrated-composer

This upstream is maintained by [Campus Web Services](https://web.arizona.edu) in collaboration with the [Arizona Digital](https://digitial.arizona.edu) team and it tracks the latest stable release of Arizona Quickstart.

## Note about installing Drupal
Because Quickstart is a relatively large install profile, we recommend performing the site install (Drupal installation) via drush (and terminus) to avoid installation problems that can be encountered when performing an interactive/web install (via `install.php`) due to [Pantheon's strict web request timeout configuration](https://pantheon.io/docs/timeouts).

Below is an example drush command that can be executed with terminus to install Quickstart on a Pantheon site.  Note that these commands put the site in SFTP mode before performing the installation.

```
terminus -y -n connection:set my-site.dev sftp
terminus -y -n drush my-site.dev -- \
  site:install az_quickstart \
  --account-name="azadmin" \
  --account-mail="noreply@email.arizona.edu" \
  --site-mail="noreply@email.arizona.edu" \
  --site-name="My Site Name" \
  --yes \
  --verbose
```
_(Replace `my-site` with actual Pantheon site name and modify account name, emails, and site name as desired)_

## Upstream Settings (settings.upstream.php)
This file (`settings.upstream.php`) is included to add upstream-wide configuration to all sites using the upstream. It is strongly suggested that you not delete or modify this file as it may cause reliability issues with your site. If site-specific configuration is needed, please use `settings.php`.