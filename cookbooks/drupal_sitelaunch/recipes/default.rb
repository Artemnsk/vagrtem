# Make directory for scripts.
directory '/bin/drupal_sitelaunch' do
  owner 'vagrant'
  mode '0755'
  action :create
end

# Add this directory to PATH.
# 1. Take /etc/environment contents, add directory to PATH and put into ~/environment file.
# 2. Copy ~/environment into /etc/environment and remove ~/environment file then.
# ~Notice 2-slashing in regexp.~
# bash 'Update PATH' do
#   code <<-EOH
#     cat /etc/environment | sed "s/\\(.*PATH=\\".*\\)\\(\\".*\\)/\\1:\\/bin\\/drupal_sitelaunch\\2/" > /home/vagrant/environment
#     cp /home/vagrant/environment /etc/
#     rm /home/vagrant/environment
#   EOH
#   # not_if 'grep -E PATH=\".*\/usr\/bin.*\" /etc/environment'
#   # user 'vagrant'
# end

# TODO: resource for that?
bash 'Put drlaunch into bash.bashrc' do
  code <<-EOH
    cp /etc/bash.bashrc /home/vagrant/bash.bashrc.tmp
    echo "alias drlaunch='bash /bin/drupal_sitelaunch/drupal_launch.sh'" >> /home/vagrant/bash.bashrc.tmp
    sudo cp /home/vagrant/bash.bashrc.tmp /etc/bash.bashrc
    rm /home/vagrant/bash.bashrc.tmp
  EOH
  not_if 'grep "alias drlaunch=\'bash /bin/drupal_sitelaunch/drupal_launch.sh\'" /etc/bash.bashrc'
end

# Copy scripts.
cookbook_file '/bin/drupal_sitelaunch/drupal_launch.sh' do
  source 'drupal_launch.sh'
  mode '0755'
  action :create
end

cookbook_file '/bin/drupal_sitelaunch/drupal_acquia.sh' do
  source 'drupal_acquia.sh'
  mode '0755'
  action :create
end

# Put databags with site info into ~/drupal_sites/.
sites = data_bag('drupal_sitelaunch_sites')
# Create directory where sites data will be stored.
directory '/home/vagrant/drupal_sites' do
  owner 'vagrant'
  mode '0755'
  action :create
end
# Load site data from data bags.
sites.each do |site|
  # Copy content into appropriate files in user directory on node.
  site_data = data_bag_item('drupal_sitelaunch_sites', site)
  file "/home/vagrant/drupal_sites/#{site}.json" do
    content site_data.raw_data.to_json()
    mode '0755'
    owner 'vagrant'
  end
  # conf file with virtualhost(-s).
  template "/etc/apache2/sites-available/#{site_data['site_url']}.conf" do
    source 'virtualhost.erb'
    owner 'vagrant'
    group 'vagrant'
    mode '0755'
    variables({
        "id" => site_data['id'],
        "server_name" => site_data['site_url'],
        "sites_dir" => site_data['sites_dir'],
        "project_dir_absolute" => "#{site_data['sites_dir']}/#{site_data['project_dir']}/#{site_data['drupal_dir']}",
    })
  end
  # Drush file.
  template "/etc/drush/#{site_data['id']}.aliases.drushrc.php" do
    source 'drush-alias.erb'
    owner 'vagrant'
    group 'vagrant'
    mode '0755'
    variables({
        "site_url" => site_data['site_url'],
        "drush_alias" => site_data['drush_alias'],
        "database_name" => site_data['db_name'],
        "database_user" => site_data['db_user'],
        "database_password" => site_data['db_password'],
        "website_dir_absolute" => "#{site_data['sites_dir']}/#{site_data['project_dir']}/#{site_data['drupal_dir']}/#{site_data['website_dir']}",
        "drupal_dir_absolute" => "#{site_data['sites_dir']}/#{site_data['project_dir']}/#{site_data['drupal_dir']}",
    })
  end
end