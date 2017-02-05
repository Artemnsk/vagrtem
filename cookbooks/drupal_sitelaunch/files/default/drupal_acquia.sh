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

acquia_realm="$(getVariableFromJson ${SITE} acquia_realm)"
acquia_site="$(getVariableFromJson ${SITE} acquia_site)"
acquia_env="$(getVariableFromJson ${SITE} acquia_env)"
acquia_db_name="$(getVariableFromJson ${SITE} acquia_db_name)"
acquia_user="$(getVariableFromJson ${SITE} acquia_user)"
acquia_password="$(getVariableFromJson ${SITE} acquia_password)"
drush_alias="$(getVariableFromJson ${SITE} drush_alias)"
id="$(getVariableFromJson ${SITE} id)"
if [ ! -z "$acquia_realm" ] && [ ! -z "$acquia_site" ] && [ ! -z "$acquia_env" ] && [ ! -z "$acquia_db_name" ]; then
    JSON="$(curl https://cloudapi.acquia.com/v1/sites/$acquia_realm:$acquia_site/envs/$acquia_env/dbs/$acquia_db_name/backups.json --user $acquia_user:$acquia_password)"
    # Find the most recent backup, then get object's link key value.
    download_link="$(echo $JSON | jq 'max_by(.completed)' | jq --raw-output '.link')"
    if [ ! -z "$download_link" ]; then
        backup_filename="$id-$acquia_realm-$acquia_site-$acquia_env.sql.gz"
        backup_filename_sql="$id-$acquia_realm-$acquia_site-$acquia_env.sql"
        # Download backup if USE_OLD_BACKUP flag is FALSE or local backup doesn't exist.
        if [ -z "$USE_OLD_BACKUP" ] || [ ! -f "/tmp/$backup_filename" ]; then
            sudo wget -O /tmp/$backup_filename $download_link
        fi
        # Unzip file.
        gunzip -f -k /tmp/$backup_filename
        # Drop via drush.
        drush @$drush_alias --yes sql-drop
        # Import via drush.
        echo "Now wait for DB to be migrated..."
        drush @$drush_alias sqlc < /tmp/$backup_filename_sql
        # Delete sql file but keep archive.
        sudo rm /tmp/$backup_filename_sql
    fi
fi