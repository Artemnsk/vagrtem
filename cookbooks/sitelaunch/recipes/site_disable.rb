execute "Disable #{node['sitelaunch']['site_url']} site." do
  command "a2dissite #{node['sitelaunch']['site_url']}.conf"
  only_if {::File.exists?("/etc/apache2/sites-enabled/#{node['sitelaunch']['site_url']}.conf")}
end

execute "Restart apache2." do
  command "service apache2 restart"
end

execute "Remove virtualhost(-s) file." do
  command "rm /etc/apache2/sites-available/#{node['sitelaunch']['site_url']}.conf"
  only_if {::File.exists?("/etc/apache2/sites-available/#{node['sitelaunch']['site_url']}.conf")}
end