# vagrtem
This is the vagrant build used as maintainer's work environment.
It contains of 3rd party cookbooks (no berks used) which were copied right into this project.

Own cookbooks are:

1. drupal_build
2. drupal_sitelaunch

## OS.
Ubuntu 14.04. Actually nothing prevents you from using any other box however this build wasn't tested anywhere except Ubuntu 14.04.

## "Drupal Build" cookbook
This cookbook is used to prepare the entire environment for running Drupal 7 websites. It contains of:

1. curl, vim, jq - my scripts depend on these packages also they are very useful
2. apache2 (with mod_rewrite)
3. php (with *php-* curl, gd, mysql, mcrypt, common, cgi, cli, dev, gmp, libapache2-mod-php5)
4. mysql-service to run websites
5. drush
6. nodejs
7. xdebug
8. *TODO: phpmyadmin*

## "Drupal Sitelaunch" cookbook
This cookbook is used to launch Drupal websites. You should provide cookbook with appropriate json config file (see /data_bags/drupal_sitelaunch_sites/example.json): one <sitename>.json file per website. Then website could be easily built or updated using `drlaunch` command. Cookbook contains of:

1. Adds `drlaunch` command - alias of appropriate shell script.
2. Parses all json files in data_bags/drupal_sitelaunch_sites and creates virtualhost file for apache2 and creates drush alias for that site.

#### drlaunch
This command is used to launch or update existing website.
Usage:

`drlaunch -s [sitename] [flags]`

Where `sitename` is name of json file (without extension). E.g. for _my_project.json_ file `sitename = my_project`.

Available flags:

`-uob, --use-old-backup:` Use old backup if exists.

1. Creates DB for website if doesn't exist.
2. Creates website directory in /var/www. **The entire build intends that you better keep project directory inside /public directory.** In this case if website directory was not exist it will be copied from appropriate directory in /public. E.g. if you clone website from repository and call it "my_project" put it into /public directory of **vagrtem** project and set up your IDE to synchronize with /var/www/my_project on vagrant machine.
3. Creates "files" directory in website_dir (see data_bags/drupal_sitelaunch_sites/example.json for details). Creates temp/private subdirectories inside that folder usually used on Drupal websites. Sets 777 permissions to the entire project.
4. Enables site (a2ensite). Reloads apache2 if website wasn't enabled before this command.
5. If Acquia support has been enabled this script will connect to Acquia, download the most recent backup, extract archive and migrate it into Drupal website. Notice that it doesn't export Acquia DB - it loops over DB backups using Acquia API. Furthermore this script doesn't remove downloaded backup archive. You can use `-uob` flag to not download backup from Acquia again and use local version. That's handy if you are working with project during the day and don't want to download backup few times a day (maybe your internet connection is poor as well or/and DB backup is too heavy?).
6. Updates Drupal admin user password and sets it to "admin".
7. Clears all caches.
8. Notifies you to not forget to put website URL into _hosts_ file of your machine. Why not?