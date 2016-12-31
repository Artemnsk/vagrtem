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

execute "a2enmod rewrite" do
  command "a2enmod rewrite"
  not_if {::File.exists?("/etc/apache2/mods-enabled/rewrite.load")}
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

# Move default php.ini into php.ini.orig. It will be used then.
file "/etc/php5/apache2/php.ini.orig" do
  owner 'root'
  group 'root'
  mode 0755
  content ::File.open("/etc/php5/apache2/php.ini").read()
  action :create
  only_if {::File.exists?("/etc/php5/apache2/php.ini") && !::File.exists?("/etc/php5/apache2/php.ini.orig")}
end
# Create php.ini file from original + overrides and custom settings.
template "/etc/php5/apache2/php.ini" do
  source 'phpini.erb'
  owner 'vagrant'
  group 'vagrant'
  mode '0755'
  variables({
    'phpini_orig_path' => "/etc/php5/apache2/php.ini.orig"
  })
  # Restart apache if changed only.
  notifies :restart, 'service[apache2]', :immediately
  only_if {::File.exists?("/etc/php5/apache2/php.ini.orig")}
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

# Move default apache2.conf into apache2.conf.orig. It will be used then.
file "/etc/apache2/apache2.conf.orig" do
  owner 'root'
  group 'root'
  mode 0755
  content ::File.open("/etc/apache2/apache2.conf").read()
  action :create
  only_if {::File.exists?("/etc/apache2/apache2.conf") && !::File.exists?("/etc/apache2/apache2.conf.orig")}
end
# Include phpmyadmin.
template "/etc/apache2/apache2.conf" do
  source 'apache2conf.erb'
  owner 'vagrant'
  group 'vagrant'
  mode '0755'
  variables({
    "default_apache2conf" => "/etc/apache2/apache2.conf.orig",
  })
  # Restart apache if changed only.
  notifies :restart, 'service[apache2]', :immediately
  only_if {::File.exists?("/etc/apache2/apache2.conf.orig")}
end