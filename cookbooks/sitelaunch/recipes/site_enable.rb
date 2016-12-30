# conf file with virtualhost(-s).
template "/etc/apache2/sites-available/#{node['sitelaunch']['site_url']}.conf" do
  source 'virtualhost.erb'
  owner 'vagrant'
  group 'vagrant'
  mode '0755'
  variables({
    "id" => node['sitelaunch']['id'],
    "server_name" => node['sitelaunch']['site_url'],
    "sites_dir" => node['sitelaunch']['sites_dir'],
    "project_dir_absolute" => "#{node['sitelaunch']['sites_dir']}/#{node['sitelaunch']['project_dir']}/#{node['sitelaunch']['drupal_dir']}",
  })
end

execute "Enable #{node['sitelaunch']['site_url']} site." do
  command "a2ensite #{node['sitelaunch']['site_url']}.conf"
end

service "apache2" do
  action :restart
end