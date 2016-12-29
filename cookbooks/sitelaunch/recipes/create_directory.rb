execute "Create site directory." do
  command "mkdir #{node['sitelaunch']['sites_dir']}/#{node['sitelaunch']['project_dir']}"
  # Check if directory already exists.
  not_if {::File.exists?("#{node['sitelaunch']['sites_dir']}/#{node['sitelaunch']['project_dir']}")}
end
execute "Set site directory permissions." do
  # TODO: better permissions.
  command "chmod 777 -R #{node['sitelaunch']['sites_dir']}/#{node['sitelaunch']['project_dir']}"
end