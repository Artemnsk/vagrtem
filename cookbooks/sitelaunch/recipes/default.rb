if (node['sitelaunch']['id'] != '' && node['sitelaunch']['op'] != '')
  include_recipe "sitelaunch::#{node['sitelaunch']['op']}"
end