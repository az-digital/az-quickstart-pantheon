# Arizona Quickstart Composer-enabled Pantheon Upstream

This upstream is adapted from Pantheon's standard Drupal 9 upstream and works with the Platform's Integrated Composer build process.

Unlike with earlier Pantheon upstreams (e.g. the UA Quickstart Drupal 7 upstream), files such as Drupal Core that you are unlikely to adjust while building sites are not in the main branch of the repository. Instead, they are referenced as dependencies that are installed by Composer.

For more information and detailed installation guides, please visit the Integrated Composer Pantheon documentation: https://pantheon.io/docs/integrated-composer

This upstream is maintained by [Campus Web Services](https://web.arizona.edu) in collaboration with the [Arizona Digital](https://digitial.arizona.edu) team and it tracks the latest stable release of Arizona Quickstart.

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

This file (`settings.upstream.php`) is included to add upstream-wide configuration to all sites using the upstream. It is strongly suggested that you not delete or modify this file as it may cause reliability issues with your site. If site-specific configuration is needed, please use `settings.php`.

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

NOTE: The `lando migrate-setup-from-pantheon` command requires that a site exists on Pantheon, since it uses terminus to find site variables on the source site.

From the parent directory where you want to create your local copy of a site on
Pantheon.

```
mkdir <sitename> && cd "$_"
lando init --source pantheon
```

This starts the interactive site creation tool when you should be able to choose
your destination site.

The next step is to start lando…. Then you can go to one of the listed URLs upon
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

Then you will want to use lando to pull the site locally (Typically you'll want
to get the live db and files, and dev codebase.)

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

Then import the resulting database into the new migrate database

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
