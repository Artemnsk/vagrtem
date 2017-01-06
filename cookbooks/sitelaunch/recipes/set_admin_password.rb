if (node['sitelaunch']['drush_alias'] != '')
  execute "Set admin password to 'admin'" do
    command "drush @#{node['sitelaunch']['drush_alias']} upwd admin --password=admin"
    ignore_failure true
  end
end