default['apache']['mpm'] = 'prefork'
default['apache']['listen'] = ["*:80", "*:443"]

default['ruby_install']['version'] = '2.4.0'

default['certificate']['common_name'] = 'angularjs build'
default['certificate']['ssl_cert']['source'] = 'self-signed'
default['certificate']['ssl_key']['source'] = 'self-signed'
default['certificate']['country'] = 'Russia'
default['certificate']['city'] = 'Nsk'
default['certificate']['state'] = 'Nsk'
default['certificate']['organization'] = '.wrk'
default['certificate']['department'] = 'Artem'
default['certificate']['email'] = 'shelkov1991@gmail.com'
# Custom data to store created certificate info.
default['certificate']['cert_key_path'] = ''
default['certificate']['cert_cert_path'] = ''
default['certificate']['cert_chain_path'] = ''