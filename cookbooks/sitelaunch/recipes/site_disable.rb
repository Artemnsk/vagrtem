execute "Disable #{node['sitelaunch']['site_url']} site." do
  command "a2dissite #{node['sitelaunch']['site_url']}.conf"
  only_if {::File.exists?("/etc/apache2/sites-enabled/#{node['sitelaunch']['site_url']}.conf")}
end

service "apache2" do
  action :restart
end

file "/etc/apache2/sites-available/#{node['sitelaunch']['site_url']}.conf" do
  action :delete
end