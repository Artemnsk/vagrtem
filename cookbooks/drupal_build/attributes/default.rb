# Enable some mods by default. See https://supermarket.chef.io/cookbooks/apache2
default['apache']['default_modules'] = ['rewrite', 'php5']
default['apache']['mpm'] = 'prefork'
default['apache']['listen'] = ["*:80", "*:443"]

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
    "xdebug.max_nesting_level" => 200,
    "extension" => "memcache.so",
}

default['nodejs']['install_method'] = 'binary'

default['custom']['mysql_root_password'] = 'root'

default['java']['jdk_version'] = '8'

default['solr']['version'] = '4.10.4'
# default['solr']['url'] =
# default['solr']['data_dir'] = "/opt/solr/example/solr"
# default['solr']['dir'] =
default['solr']['port'] = 8983
# default['solr']['pid_file'] =
# default['solr']['log_file'] =
# default['solr']['user'] =
# default['solr']['group'] =
# Checksum was invalid in cookbook out of a box. See https://github.com/dwradcliffe/chef-solr/issues/36
default['solr']['checksum'] = "ac3543880f1b591bcaa962d7508b528d7b42e2b5548386197940b704629ae851"
default['solr']['install_java'] = true
default['solr']['java_options'] = "-Xms128M -Xmx512M"