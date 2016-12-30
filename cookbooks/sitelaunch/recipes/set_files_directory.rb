directory "#{node['sitelaunch']['sites_dir']}/#{node['sitelaunch']['project_dir']}/#{node['sitelaunch']['drupal_dir']}/#{node['sitelaunch']['website_dir']}/files" do
  mode '0777'
  action :create
end

directory "#{node['sitelaunch']['sites_dir']}/#{node['sitelaunch']['project_dir']}/#{node['sitelaunch']['drupal_dir']}/#{node['sitelaunch']['website_dir']}/files/temp" do
  mode '0777'
  action :create
end

directory "#{node['sitelaunch']['sites_dir']}/#{node['sitelaunch']['project_dir']}/#{node['sitelaunch']['drupal_dir']}/#{node['sitelaunch']['website_dir']}/files/private" do
  mode '0777'
  action :create
end