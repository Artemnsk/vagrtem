# 0. Load all variables.
include_recipe 'sitelaunch::get_site_vars'
# Now when all variables were loaded we can start our work.

# 1. Export database from Acquia and import into local website DB.
include_recipe 'sitelaunch::acquia_export_recent_backup'

# 2. Set admin password for website.
include_recipe 'sitelaunch::set_admin_password'

# 3. Clear all caches for website.
if (node['sitelaunch']['drush_alias'] != '')
  execute "Clear all caches for website." do
    command "drush @#{node['sitelaunch']['drush_alias']} cc all"
    ignore_failure true
    user 'vagrant'
  end
end