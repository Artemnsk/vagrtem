# Enable some mods by default. See https://supermarket.chef.io/cookbooks/apache2
default['apache']['default_modules'] = ['rewrite', 'php5']
default['apache']['mpm'] = 'prefork'

# PHP https://supermarket.chef.io/cookbooks/php/versions/2.2.0
# Dirty trick to force php change apache2 php.ini, not cli.
override['php']['conf_dir'] ='/etc/php5/apache2'
default['php']['directives'] = {
    "max_execution_time" => 300,
    "post_max_size" => "1024M",
    "upload_max_filesize" => "1024M",
    "zend_extension" => "/usr/lib/php5/20121212/xdebug.so",
    "xdebug.remote_enable" => 1,
    "xdebug.remote_autostart" => 1,
    "xdebug.remote_host" => "33.33.33.1",
}

default['nodejs']['install_method'] = 'binary'

default['custom']['mysql_root_password'] = 'root'