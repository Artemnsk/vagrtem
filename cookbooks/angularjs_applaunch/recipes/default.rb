app_name = ''
apps_dir = "/var/www/"
default_branch_dir = "trunk/"
sites = {
    'shared' => {
      'project_dir' => "#{app_name}_shared/",
    },
    'app' => {
      'app_url' => "#{app_name}_app.loc",
      'project_dir' => "#{app_name}_app/",
    },
    'portal' => {
      'app_url' => "#{app_name}_portal.loc",
      'project_dir' => "#{app_name}_portal/",
    }
}

# 1. SHAREDSERVICES. #############################################
# a. Create directory.
directory "#{apps_dir}/#{sites['shared']['project_dir']}" do
  owner 'vagrant'
  mode '0777'
  action :create
end
# b. Copy project if empty.
bash 'Copy project if empty' do
  code <<-EOH
      cp -R /vagrant/#{sites['shared']['project_dir']}/* #{apps_dir}/#{sites['shared']['project_dir']}/
  EOH
  only_if { Dir.entries("#{apps_dir}/#{sites['shared']['project_dir']}").size <= 2 }
end
##########################################################################################



# 2. APP. #############################################
# a. Create directory.
directory "#{apps_dir}/#{sites['app']['project_dir']}" do
  owner 'vagrant'
  mode '0777'
  action :create
end
# b. Copy project if empty.
bash 'Copy project if empty' do
  code <<-EOH
      cp -R /vagrant/#{sites['app']['project_dir']}/* #{apps_dir}/#{sites['app']['project_dir']}/
  EOH
  only_if { Dir.entries("#{apps_dir}/#{sites['app']['project_dir']}").size <= 2 }
end
# c. Set permissions for public directories. CSS.
directory "#{apps_dir}/#{sites['app']['project_dir']}/#{default_branch_dir}/css/public" do
  owner 'vagrant'
  mode '0777'
  action :create
end
# d. Set permissions for public directories. JS.
directory "#{apps_dir}/#{sites['app']['project_dir']}/#{default_branch_dir}/js/public" do
  owner 'vagrant'
  mode '0777'
  action :create
end
# e. Symbolic link to sharedservices project.
link "#{apps_dir}/#{sites['app']['project_dir']}/#{default_branch_dir}/sharedservices" do
  to "#{apps_dir}/#{sites['shared']['project_dir']}/#{default_branch_dir}"
end
# f. npm install.
bash 'NPM install for project' do
  code <<-EOH
      npm install
  EOH
  cwd "#{apps_dir}/#{sites['app']['project_dir']}/#{default_branch_dir}"
end
# g. conf file with virtualhost(-s).
template "/etc/apache2/sites-available/#{sites['app']['app_url']}.conf" do
  source 'virtualhost.erb'
  owner 'vagrant'
  group 'vagrant'
  mode '0755'
  variables({
      "id" => "#{app_name}_app",
      "server_name" => sites['app']['app_url'],
      "apps_dir" => apps_dir,
      "project_dir_absolute" => "#{apps_dir}/#{sites['app']['project_dir']}/#{default_branch_dir}",
      "ssl_key" => node['certificate']['cert_key_path'],
      "ssl_cert" => node['certificate']['cert_cert_path'],
      "ssl_chain" => node['certificate']['cert_chain_path'],
  })
end
# h. Enable site.
apache_site "#{sites['app']['app_url']}"
service 'apache2' do
  action :reload
end
# i. run grunt.
bash 'Grunt' do
  code <<-EOH
      sudo grunt
  EOH
  cwd "#{apps_dir}/#{sites['app']['project_dir']}/#{default_branch_dir}"
end
##########################################################################################