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
  # SSL-related stuff.
  cert_key_path = ''
  cert_cert_path = ''
  cert_chain_path = ''
  if site_data['ssl'] == "1"
    # Create self-signed SSL sertificate.
    node.default[site_data['id']]['common_name'] = site_data['site_url']
    node.default[site_data['id']]['ssl_cert']['source'] = 'self-signed'
    node.default[site_data['id']]['ssl_key']['source'] = 'self-signed'
    node.default[site_data['id']]['country'] = 'Russia'
    node.default[site_data['id']]['city'] = 'Nsk'
    node.default[site_data['id']]['state'] = 'Nsk'
    node.default[site_data['id']]['organization'] = '.wrk'
    node.default[site_data['id']]['department'] = 'Artem'
    node.default[site_data['id']]['email'] = 'shelkov1991@gmail.com'

    # Create certificate. TODO
    cert = ssl_certificate site_data['id'] do
      namespace node[site_data['id']]
    end
    cert_key_path = cert.key_path
    cert_cert_path = cert.cert_path
    cert_chain_path = cert.chain_path
  end
  # conf file with virtualhost(-s).
  template "/etc/apache2/sites-available/#{site_data['site_url']}.conf" do
    source 'virtualhost.erb'
    owner 'vagrant'
    group 'vagrant'
    mode '0755'
    variables({
        "id" => site_data['id'],
        "ssl" => site_data['ssl'],
        "server_name" => site_data['site_url'],
        "server_aliases" => site_data['server_aliases'].kind_of?(Array) ? site_data['server_aliases'] : {},
        "sites_dir" => site_data['sites_dir'],
        "project_dir_absolute" => "#{site_data['sites_dir']}/#{site_data['project_dir']}/#{site_data['drupal_dir']}",
        "ssl_key" => cert_key_path,
        "ssl_cert" => cert_cert_path,
        "ssl_chain" => cert_chain_path,
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

  # Create Apache Solr core if needed.
  if site_data['solr_enable'] == "1"
    # If core doesn't exist which should mean that it is first run.
    if !File.directory?("/etc/solr/#{site_data['solr_core']}")
      # Create default core files.
      FileUtils.cp_r '/opt/solr/example/solr/collection1', "/etc/solr/#{site_data['solr_core']}"
      # Copy proper Drupal-related Apache Solr configs into newly created core directory.
      remote_directory "Copy proper Drupal-related Apache Solr configs into newly created core directory" do
        path "/etc/solr/#{site_data['solr_core']}/conf"
        source "solr-conf-4"
        overwrite true
      end
      # Create Apache Solr core by sending HTTP POST message.
      bash "Create Apache Solr core" do
        code <<-EOH
            curl --data "action=CREATE&name=#{site_data['solr_core']}&instanceDir=/etc/solr/#{site_data['solr_core']}&config=solrconfig.xml&schema=schema.xml&dataDir=/etc/solr/#{site_data['solr_core']}/data/" http://localhost:8983/solr/admin/cores
        EOH
      end
    end
  end
end