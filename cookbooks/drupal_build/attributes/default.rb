# Enable some mods by default. See https://supermarket.chef.io/cookbooks/apache2
default['apache']['default_modules'] = ['rewrite', 'php5']
default['apache']['mpm'] = 'prefork'
# TODO: node['php']['directives'] see https://supermarket.chef.io/cookbooks/php/versions/2.2.0
