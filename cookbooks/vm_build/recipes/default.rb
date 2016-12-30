# Restart apache. Used by other resources.
service "apache2" do
  action :nothing
end



####################################################

apt_update 'all platforms' do
  frequency 259200 # 3 days.
  action :periodic
end

# execute "apt-get update" do
#   command "apt-get update"
# end

# Install Apache.
apt_package "apache2"

a2mods = 'rewrite'
execute "a2enmods" do
  command "a2enmod #{a2mods}"
end

# Check if mysql was already installed.
mysql_was_installed = ::File.exist?('/usr/bin/mysql')
# Install MySQL.
apt_package "mysql-server"
# Set password for root user. # todo: notify?
execute "Set mysql password" do
  command "mysqladmin -u root password 'root'"
  not_if {mysql_was_installed}
end

phps = ['php5', 'libapache2-mod-php5', 'php5-mcrypt', 'php5-mysql', 'php5-gmp', 'php5-gd', 'php5-dev', 'php5-curl', 'php5-common', 'php5-cli', 'php5-cgi']
phps.each() do |php_item|
  apt_package php_item
end

# Installing some helpful packages.
helpful_packages = ['curl', 'vim']
helpful_packages.each() do |pckg|
  apt_package pckg
end

# Install xdebug
apt_package "php5-xdebug"

# TODO: including doesn't work.
# Create custom php.ini file in /var/www with overrides and custom variables.
template "/var/www/php_custom.ini" do
  source 'php_custom.erb'
  owner 'vagrant'
  group 'vagrant'
  mode '0755'
  # Restart apache if changed only.
  notifies :restart, 'service[apache2]', :immediately
end
# Include this custom file.
template "/etc/php5/apache2/php.ini" do
  source 'php_default.erb'
  owner 'vagrant'
  group 'vagrant'
  mode '0755'
  # Restart apache if changed only.
  notifies :restart, 'service[apache2]', :immediately
  not_if {File.readlines("/etc/php5/apache2/php.ini").grep(/Include \/var\/www\/php_custom\.ini/).size > 0}
end

# Install drush. See http://docs.drush.org/en/master/install/
bash 'drush_install' do
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

# phpmyadmin.
apt_package "phpmyadmin"

# Include phpmyadmin.
template "/etc/apache2/apache2.conf" do
  source 'apache2conf.erb'
  owner 'vagrant'
  group 'vagrant'
  mode '0755'
  variables({
    "default_apache2conf" => "/etc/apache2/apache2.conf",
  })
  # Restart apache if changed only.
  notifies :restart, 'service[apache2]', :immediately
  not_if {File.readlines("/etc/apache2/apache2.conf").grep(/Include \/etc\/phpmyadmin\/apache\.conf/).size > 0}
end