# Arizona Quickstart Composer-enabled Pantheon Upstream

This upstream is adapted from Pantheon's standard Drupal 9 upstream and works with the Platform's Integrated Composer build process.

Unlike with earlier Pantheon upstreams (e.g. the UA Quickstart Drupal 7 upstream), files such as Drupal Core that you are unlikely to adjust while building sites are not in the main branch of the repository. Instead, they are referenced as dependencies that are installed by Composer.

For more information and detailed installation guides, please visit the Integrated Composer Pantheon documentation: https://pantheon.io/docs/integrated-composer

This upstream is maintained by [Campus Web Services](https://web.arizona.edu) in collaboration with the [Arizona Digital](https://digitial.arizona.edu) team and it tracks the latest stable release of Arizona Quickstart.

## Useful links to Pantheon Documentation.
- [Apply Upstream Updates Manually from the Command Line to Resolve Merge Conflicts](https://docs.pantheon.io/core-updates#apply-upstream-updates-manually-from-the-command-line-to-resolve-merge-conflicts).
- [The recommended workflow](https://docs.pantheon.io/pantheon-workflow)
- [The out of normal operation Pantheon Hotfix workflow](https://docs.pantheon.io/hotfixes)

## Note about installing Drupal

Because Quickstart is a relatively large install profile, we recommend performing the site install (Drupal installation) via drush (and terminus) to avoid installation problems that can be encountered when performing an interactive/web install (via `install.php`) due to [Pantheon's strict web request timeout configuration](https://pantheon.io/docs/timeouts).

Below is an example drush command that can be executed with terminus to install Quickstart on a Pantheon site. Note that these commands put the site in SFTP mode before performing the installation.

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

This file (`settings.upstream.php`) is included to add upstream-wide
configuration to all sites using the upstream. It is strongly suggested that you
not delete or modify this file as it may cause reliability issues with your
site. If site-specific configuration is needed, please use `settings.php`.

### What is in settings.upstream.php

The `settings.upstream.php` file in the Arizona Quickstart Composer-enabled
Pantheon Upstream includes a variety of important configurations designed to
optimize the performance, security, and reliability of Drupal sites on the
Pantheon platform. This file is maintained by the upstream maintainers (Arizona
Digital) and should not be modified by individual site administrators.
Site-specific changes should be made in the `settings.php` file.

Key features and configurations included in `settings.upstream.php`:

- **Migration Database Configuration:** Supports loading database configuration
  for migrations from a JSON file located in
  `sites/default/files/private/migration_config.json`. This allows for seamless
  migration database connections without hardcoding sensitive information.

- **Fast 404 Pages:** Implements efficient handling of 404 errors by serving
  simple, fast-loading 404 pages for paths matching specific patterns. This
  reduces the overhead of fully themed 404 pages for missing resources, saving
  bandwidth and reducing server load.

- **Pantheon Environment-Specific Configurations:**
  - **HTTPS Redirection:** For all Pantheon environments, HTTP requests to
    `.pantheonsite.io` domains are redirected to HTTPS to enforce secure
    connections.
  - **Performance and Caching Settings:** Adjusts cache lifetimes and
    aggregation settings based on the environment (development vs. test/live),
    optimizing performance across different stages of the site lifecycle.
  - **Environment Indicator:** Provides visual indicators in the Drupal admin
    interface to show which Pantheon environment (e.g., `dev`, `test`, `live`,
    or development branch) you're currently working in, aiding in environment
    awareness.

## Updating Quickstart 2 on Pantheon via the command line.

### Requirements
- [Terminus installed on your computer](https://docs.pantheon.io/terminus/install)
- A Quickstart 2 site installed on Pantheon, in at least one environment.
- The machine name of the site you want to update: this will be referred to as `<sitename>` for the rest of this tutorial.
- The machine name of the environment you want to update: this will be referred to as `<environment>` for the rest of this tutorial. Some examples are `dev`, `test`,  and `live`. (Upstream updates can only be applied to multi-dev or dev environments.)
- Access to the site and environment you would like to update.

Each of the following steps has a counterpart within either the Pantheon Dashboard or the Quickstart administration user interface.

### Step 1: Apply upstream updates to the `dev` environment.

When new upstream updates are released, `dev` or multi-dev environments should be eligible to accept them.

**Important:** Always create a backup before running database updates or importing distribution updates.

```
terminus backup:create <sitename>.<environment>
```

Check if there are upstream updates available.

```
 terminus upstream:updates:status <sitename>.<environment>
```

If outdated, list the available updates.

```
 terminus upstream:updates:list <sitename>.<environment>
```

Apply the upstream updates to the environment.

```
 terminus upstream:updates:apply <sitename>.<environment>
```

### Step 2: Update the database.

Once your site's codebase is up to date, it is important to run database updates and distribution updates.


Updating the database can be done via the command line:
```
terminus drush <sitename>.<environment> -- updatedb
```
**Important:** Always ensure your site is set on the correct strategy for importing distribution updates.
For Quickstart, it is recommended to use the merge strategy when importing distribution updates, which can be set via drush, or within the Admin UI.

It is advisable that you familiarize yourself with the functionality of the [Config Distro](https://www.drupal.org/project/config_distro) module to get the most out of Quickstart.

```
terminus drush <sitename>.<environment> -- -y state:set config_sync.update_mode 1 --input-format=integer
```

Importing distribution updates can be done via the command line:

```
terminus drush <sitename>.<environment> -- config-distro-update
```

### Step 3: Test and apply updates to test and live.

Now that you've successfully updated your site, you can also deploy to test and live from the command line.

**Important:** Always create a backup before running database updates or importing distribution updates.

For `test`:

```
terminus backup:create <sitename>.test
terminus env:deploy <sitename>.test --updatedb --sync-content
terminus drush <sitename>.test -- -y state:set config_sync.update_mode 1 --input-format=integer
terminus drush <sitename>.test -- config-distro-update
```

Optionally add new permissions from the upstream onto the az_quickstart managed roles:

```
terminus drush <sitename>.test -- az-core-config-add-permissions -y
```


For `live`:

```
terminus backup:create <sitename>.live
terminus env:deploy <sitename>.live --updatedb
terminus drush <sitename>.live -- -y state:set config_sync.update_mode 1 --input-format=integer
terminus drush <sitename>.live -- config-distro-update
```

Optionally add new permissions from the upstream onto the az_quickstart managed roles:

```
terminus drush <sitename>.live -- az-core-config-add-permissions -y
```

## Determining whether the Quickstart 1 to Quickstart 2 migration path is viable for your site.

When tasked with migrating a Quickstart 1 site to a Quickstart 2 site these are the steps:

Find the source site machine name.
Find the destination site machine name.

Double check that the source site and destination sites exist in Pantheon and have a live site environment associated with them.

```
terminus env:view <sourcesitename.live>
terminus env:view <destinationsitename.live>
```

Once you've determined that a site is truly eligible to be migrated, follow these steps.

## Running migrations from Drupal 7 or UA Quickstart site downloaded from Pantheon, to Drupal 9 Arizona Quickstart site downloaded from Pantheon

NOTE: The `lando migrate-setup-from-pantheon` command requires that a site exists on Pantheon, since it uses terminus to find site variables on the source site. Getting started with local Lando developement can be found [here.](https://github.com/az-digital/az_quickstart/blob/main/CONTRIBUTING.md#local-development)

Create your local copy of the Pantheon **destination** site by initializing Lando inside and *empty* folder.
```
mkdir <destinationsitename>
cd <destinationsitename>
lando init --source pantheon
```
Or execute the bash commands

```
mkdir <destinationsitename> && cd "$_"
lando init --source pantheon
```

This starts the interactive site creation tool that allows you to choose
your destination site from a list of sites created on Pantheon. Select the branch you are working on from the dropdown. 

The next step is to start lando. After which you can go to one of the listed URLs upon
success

```
lando start
```

Now if you run `lando` You should have more than just the defaults from the
pantheon config. Particularly, these two:

```
  // lando migrate-db-import <file>     YOU MUST RUN LANDO PULL FIRST Imports a migration site dump file into a database service
  // lando migrate-setup-from-pantheon  Runs migrate-setup-from-pantheon commands
```

The next step is to use Lando to pull the destination site locally from the site that you created on Pantheon.
(Typically you'll want to get the live db and files, and dev codebase.) If they do not yet exist on Pantheon,
Feel free to enable those environments for your destination site now.

```
lando pull -d live -f live -c none
```

Then install composer dependencies

```
lando composer update
```

Now we can use the Lando tooling to set up our site to migrate locally instead
of over http, which is much faster.

NOTE: This step overrides the migrate database config that exists in
https://github.com/az-digital/az-quickstart-pantheon/blob/master/web/sites/default/settings.upstream.php#L20-L35

```
lando migrate-setup-from-pantheon -s <sourcesitename.env>
```

**NOTE:** The `migrate-setup-from-pantheon` command executes a [script](https://github.com/az-digital/az-quickstart-pantheon/blob/master/scripts/lando/migrate-setup-from-pantheon.sh) included with this repository.

Then import the resulting database dump file into the newly created (by the script) `migrate` database

```
lando migrate-db-import database.sql.gz
```

OK, we finally have all of the files we need now, so it is time to start
migration

First thing I will do is check the migration status of either the
az_migration_group, or the group I would like to import

```
lando drush ms --group=az_migration
lando drush mim --group=az_migration
```

Once the migrations are completed, you can push the files and database, but not
the code back to dev, but first check the **migration status**.

Check the migration status.

```
lando drush ms --group=az_migration > AZSITEMIGRATION.md
cat AZSITEMIGRATION.md
```

Note: we are not pushing code up at this time, because we don't want to add our settings.php changes back to Pantheon.

```
lando push -c none -d dev -f dev
```

Open the dev site when the push is complete, and do a spot check

```
terminus env:view <destinationsitename.env>
```

**Always make a backup if overwriting live**

```
terminus backup:create <destinationsitename.live>
```

If all looks good, go ahead and deploy your migration to another environment,
overwriting that environment’s database and files.

```
terminus env:clone-content <destinationsitename.dev> <target_env> --cc -y
```

Check the destination site.

```
terminus env:view <destinationsitename.live>
```

### Clean up

Once your migration is complete, you can delete the source migrate database config from your sites web/sites/default/settings.php file.

This can be done with `git checkout` as seen below.

```
git checkout master web/sites/default/settings.php
```
