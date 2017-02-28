apt_update 'all platforms' do
  frequency 259200 # 3 days.
  action :periodic
end

# Some general handy packages.
apt_package 'curl'
apt_package 'vim'
# This one used to parse json in shell scripts.
apt_package 'jq'
# Install ssl-cert.
apt_package 'ssl-cert'

# Install Apache2.
include_recipe "apache2::default"

# Enable mods.
apache_module "ssl"
apache_module "socache_shmcb"

# Create self-signed SSL sertificate.
cert = ssl_certificate 'certificate' do
  namespace node['certificate']
end
node.default['certificate']['cert_key_path'] = cert.key_path
node.default['certificate']['cert_cert_path'] = cert.cert_path
node.default['certificate']['cert_chain_path'] = cert.chain_path

# Simply give all permissions to the entire /var/www folder. TODO: fix that.
directory "/var/www" do
  mode '0777'
end

# Install nodejs.
include_recipe "nodejs"
include_recipe "nodejs::npm"
# Install GLOBALLY.
# nodejs_npm "gulp"
nodejs_npm "grunt"

# Install ruby.
apt_package 'ruby'

# Install rvm. See https://rvm.io/rvm/install
bash 'Install rvm' do
  code <<-EOH
      curl -sSL https://get.rvm.io | bash -s stable --ruby
  EOH
  not_if { File.exists?("/usr/local/rvm/bin/rvm") }
end

# Install gem.
bash 'Install sass gem' do
  code <<-EOH
      gem install sass
  EOH
end