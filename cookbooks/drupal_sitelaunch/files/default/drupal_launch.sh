#!/bin/sh

# Used to pull data from JSON file by key.
getVariableFromJson() {
    # TODO: no file?
    echo "$(cat /home/vagrant/drupal_sites/${1}.json | jq --raw-output .${2})";
}

SITE=null
USE_OLD_BACKUP=''
for ((i=1; i<=$#+1; i++)); do
    key="$1"
    case $key in
        -s|--site)
            SITE="$2"
            shift
            ;;
        -uob|--use-old-backup)
            USE_OLD_BACKUP="--use-old-backup"
            # This option doesn't need any parameter so we just shift in the end.
            ;;
        *)
            # unknown option
            ;;
    esac
    shift
done

# 0. Check that json file exists.
if [ ! -f "/home/vagrant/drupal_sites/${SITE}.json" ]; then
    echo "File /home/vagrant/drupal_sites/${SITE}.json was not found"
    exit 1
fi

# 1. Create database for website if doesn't exist.
db_user="$(getVariableFromJson ${SITE} db_user)"
db_password="$(getVariableFromJson ${SITE} db_password)"
db_name="$(getVariableFromJson ${SITE} db_name)"
if [ ! -z "$db_name" ] && [ ! -z "$db_user" ] && [ ! -z "$db_password" ]; then
    mysql -h 127.0.0.1 --user=$db_user --password=$db_password --execute="CREATE DATABASE IF NOT EXISTS $db_name"
fi

# 2. Create directory for site. Set permissions.
sites_dir="$(getVariableFromJson ${SITE} sites_dir)"
project_dir="$(getVariableFromJson ${SITE} project_dir)"
if [ ! -z "$sites_dir" ] && [ ! -z "$project_dir" ]; then
    # Copy website files if possible. Create file folders then.
    if [ -d "/vagrant/$project_dir" ]; then
        # Copy project files (if empty) from shared folder (if not empty).
        if [ ! -z "$(ls -A /vagrant/$project_dir)" ] && [ -z "$(ls -A $sites_dir/$project_dir)" ]; then
            echo "Copying project files from /vagrant/$project_dir to $sites_dir/$project_dir. Please wait..."
            sudo cp -ra /vagrant/$project_dir $sites_dir/
        fi
        # Create files directory and it's subfolders.
        if [ -d "$sites_dir/$project_dir/$drupal_dir/$website_dir" ]; then
            sites_dir="$(getVariableFromJson ${SITE} sites_dir)"
            project_dir="$(getVariableFromJson ${SITE} project_dir)"
            drupal_dir="$(getVariableFromJson ${SITE} drupal_dir)"
            website_dir="$(getVariableFromJson ${SITE} website_dir)"
            directories=("$sites_dir/$project_dir/$drupal_dir/$website_dir/files" "$sites_dir/$project_dir/$drupal_dir/$website_dir/files/temp" "$sites_dir/$project_dir/$drupal_dir/$website_dir/files/private")
            for directory in "${directories[@]}"
            do
                if [ ! -d $directory ]; then
                    sudo mkdir $directory
                fi
            done
        fi
    fi
    # Finally set permissions for the entire project directory.
    # TODO: better permissions?
    sudo chmod 777 -R $sites_dir/$project_dir
fi

# 3. Enable site. Virtualhosts file should be created by chef on provision run.
site_url="$(getVariableFromJson ${SITE} site_url)"
if [ -f "/etc/apache2/sites-available/$site_url.conf" ] && [ ! -f "/etc/apache2/sites-enabled/$site_url.conf" ]; then
    sudo a2ensite ${site_url}.conf
    sudo service apache2 reload
fi

# 4. Get backup URL from Acquia.
acquia_enable="$(getVariableFromJson ${SITE} acquia_enable)"
if [ ! -z "$acquia_enable" ]; then
    bash /bin/drupal_sitelaunch/drupal_acquia.sh -s $SITE $USE_OLD_BACKUP
fi

# 5. Set admin password for site.
drush_alias="$(getVariableFromJson ${SITE} drush_alias)"
drush @$drush_alias upwd admin --password=admin

# 6. Clear all caches.
drush_alias="$(getVariableFromJson ${SITE} drush_alias)"
drush @$drush_alias cc all

# 7. Notification.
site_url="$(getVariableFromJson ${SITE} site_url)"
echo '========================='
echo "Don't forget to add $site_url into hosts file"
echo '========================='