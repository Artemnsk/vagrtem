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
apache_module "rewrite"
apache_module "ssl"
apache_module "socache_shmcb"

# Install PHP.
include_recipe "php::default"
# Reload apache2 to apply new php.ini settings.
service 'apache2' do
  action :reload
end

package "php5-curl" do
  action :install
end
package "php5-gd" do
  action :install
end
package "php5-mysql" do
  action :install
end
package "php5-mcrypt" do
  action :install
end
package "php5-common" do
  action :install
end
package "php5-cgi" do
  action :install
end
package "php5-cli" do
  action :install
end
package "php5-dev" do
  action :install
end
package "php5-gmp" do
  action :install
end
package "memcached" do
  action :install
end
package "php5-memcached" do
  action :install
end

package "libapache2-mod-php5" do
  action :install
end

# Start mysql service for drupal sites.
# 8GB. TODO:
opts = {"max_allowed_packet" => "8388608"}
mysql_service 'drupal' do
  port '3306'
  version '5.5'
  mysqld_options opts
  initial_root_password node['custom']['mysql_root_password']
  action [:create, :start]
end

# Install drush. See http://docs.drush.org/en/master/install/
bash 'install drush' do
  cwd '/tmp'
  code <<-EOH
    php -r \"readfile('https://s3.amazonaws.com/files.drush.org/drush.phar');\" > drush
    php drush core-status
    chmod +x drush
    mv -f drush /usr/local/bin
    mkdir /home/vagrant/.drush
    mkdir /home/vagrant/.drush/cache
    chmod 777 -R /home/vagrant/.drush/cache
    drush cc drush
    EOH
  not_if {::File.exists?("/usr/local/bin/drush")}
end
# Create directory where all drush alias live. They could be used by any user in such way.
directory "/etc/drush" do
  mode '0777'
end

# Simply give all permissions to the entire /var/www folder. TODO: fix that.
directory "/var/www" do
  mode '0777'
end

# Install nodejs.
include_recipe "nodejs"
include_recipe "nodejs::npm"
# Install gulp GLOBALLY. TODO:
#nodejs_npm "gulp"

# Install xdebug
apt_package "php5-xdebug"

# Install phpmyadmin. TODO:
# apt_package "phpmyadmin" do
#   options '-y'
# end
#
# # Include PMA conf into apache.conf. TODO:
# bash 'Put drlaunch into bash.bashrc' do
#   code <<-EOH
#     echo "Include /etc/phpmyadmin/apache.conf" >> /etc/apache2/apache2.conf
#   EOH
#   not_if 'grep "Include /etc/phpmyadmin/apache.conf" /etc/apache2/apache2.conf'
# end