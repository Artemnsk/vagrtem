# TODO: better permissions?
directory "#{node['sitelaunch']['sites_dir']}/#{node['sitelaunch']['project_dir']}" do
  mode '0777'
end