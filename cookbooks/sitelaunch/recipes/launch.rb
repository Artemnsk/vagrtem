# 0. Load all variables.
include_recipe 'sitelaunch::get_site_vars'
# Now when all variables were loaded we can start our work.

# 1. Create DB (if not exists).
execute "Create #{node['sitelaunch']['database']['name']} DB." do
  command "mysql -u#{node['sitelaunch']['database']['user']} -p#{node['sitelaunch']['database']['password']} -e 'CREATE DATABASE IF NOT EXISTS #{node['sitelaunch']['database']['name']}'"
end

# 2. Create directory for site. Set permissions.
include_recipe 'sitelaunch::create_directory'

# 3. Set up virtualhosts.
include_recipe 'sitelaunch::site_enable'

# 4. Create subdirectories in "files" folder and set permissions.
include_recipe 'sitelaunch::set_files_directory'

# 5. Drush-related stuff.
include_recipe 'sitelaunch::set_drush'

# 6. Export database from Acquia and import into local website DB.
include_recipe 'sitelaunch::acquia_export_recent_backup'

# 7. Set admin password for website.
include_recipe 'sitelaunch::set_admin_password'

# 8. Notification to add new website URL into /etc/hosts.
include_recipe 'sitelaunch::hosts_file_add'