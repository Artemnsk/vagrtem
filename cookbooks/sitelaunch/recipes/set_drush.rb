if (node['sitelaunch']['drush_alias'] != '')
  # Create drush file.
  template "/etc/drush/#{node['sitelaunch']['id']}.aliases.drushrc.php" do
    source 'drush-alias.erb'
    owner 'vagrant'
    group 'vagrant'
    mode '0755'
    variables({
      "site_url" => node['sitelaunch']['site_url'],
      "drush_alias" => node['sitelaunch']['drush_alias'],
      "database_name" => node['sitelaunch']['database']['name'],
      "database_user" => node['sitelaunch']['database']['user'],
      "database_password" => node['sitelaunch']['database']['password'],
      "website_dir_absolute" => "#{node['sitelaunch']['sites_dir']}/#{node['sitelaunch']['project_dir']}/#{node['sitelaunch']['drupal_dir']}/#{node['sitelaunch']['website_dir']}",
      "drupal_dir_absolute" => "#{node['sitelaunch']['sites_dir']}/#{node['sitelaunch']['project_dir']}/#{node['sitelaunch']['drupal_dir']}",
    })
  end
  execute "Clear drush cache." do
    command "drush cc drush"
  end
end