# TODO: add almost everywhere because sitename attribute is required.
if (node['sitelaunch']['sitename'] == '')
  raise ArgumentError, "You must specify --sitename option for sitelaunch provision.", caller
end

# Launch some website.


sitename = node['sitelaunch']['sitename']

template "/home/vagrant/.drush/#{sitename}.aliases.drushrc.php" do
  source 'drush-alias.erb'
  owner 'vagrant'
  group 'vagrant'
  mode '0755'
  variables({
    'site_url' => 'asd',
    'site_alias' => 'qwe',
    'site_directory' => 'qwe'
  })
end

execute "my execute command 2" do
  command "echo #{node['sitelaunch']['sitename']}"
end

# TODO: clear drush cache.