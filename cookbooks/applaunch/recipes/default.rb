# 1. Create directory.
directory "/var/www/dirtchamber" do
  owner 'vagrant'
  mode '0777'
  action :create
end
# 2. Copy project if empty.
bash 'Copy project if empty' do
  code <<-EOH
      cp -R /vagrant/dirtchamber/* /var/www/dirtchamber/
  EOH
  only_if { Dir.entries("/var/www/dirtchamber").size <= 2 }
end
# 3. Run npm.
bash 'NPM install for project' do
  code <<-EOH
      npm install
  EOH
  cwd "/var/www/dirtchamber/battleground1"
end
# 4. conf file with virtualhost(-s).
template "/etc/apache2/sites-available/dirtchamber.conf" do
  source 'virtualhost.erb'
  owner 'vagrant'
  group 'vagrant'
  mode '0755'
  variables({
      "server_name" => 'dirtchamber',
      "apps_dir" => '/var/www/',
      "project_dir_absolute" => "/var/www/dirtchamber",
  })
end
# 5. Enable site.
apache_site "dirtchamber"
service 'apache2' do
  action :reload
end
# 6. Run grunt.
bash 'Grunt' do
  code <<-EOH
      sudo grunt
  EOH
  cwd "/var/www/dirtchamber/battleground1"
end