# 0. Load all variables.
include_recipe 'sitelaunch::get_site_vars'
# Now when all variables were loaded we can start our work.

#1. Unset Drush.
include_recipe 'sitelaunch::unset_drush'

#2. Disable site.
include_recipe 'sitelaunch::site_disable'

# 3. Drop DB (if exists).
execute "Drop #{node['sitelaunch']['database']['name']} DB." do
  command "mysql -u#{node['sitelaunch']['database']['user']} -p#{node['sitelaunch']['database']['password']} -e 'DROP DATABASE IF EXISTS #{node['sitelaunch']['database']['name']}'"
end

# 4. Notification to remove website URL from /etc/hosts.
include_recipe 'sitelaunch::hosts_file_remove'