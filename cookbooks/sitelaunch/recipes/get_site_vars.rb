site_data = search(:sitelaunch_sites, "id:#{node['sitelaunch']['id']}").first
# Override all variables with data from data bags.
site_data.each do |key, value|
  node.override['sitelaunch'][key] = value
end