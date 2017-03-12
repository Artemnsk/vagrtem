apt_update 'all platforms' do
  frequency 259200 # 3 days.
  action :periodic
end

# Some general handy packages.
apt_package 'curl'
apt_package 'vim'
# This one used to parse json in shell scripts.
apt_package 'jq'

# Install Apache2.
include_recipe "apache2::default"

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