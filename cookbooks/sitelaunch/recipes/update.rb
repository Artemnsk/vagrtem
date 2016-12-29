# 0. Load all variables.
include_recipe 'sitelaunch::get_site_vars'
# Now when all variables were loaded we can start our work.

# 1. Export database from Acquia and import into local website DB.
include_recipe 'sitelaunch::acquia_export_recent_backup'

# 2. Clear all caches for website.
# TODO: some flexible recipe?
if (node['sitelaunch']['drush_alias'] != '')
  execute "Clear all caches for website." do
    # In some reason chef_solo provisions don't properly run as vagrant user (consequently drush alias not be found).
    command "su vagrant -l -c \"drush @#{node['sitelaunch']['drush_alias']} cc all\""
  end
end