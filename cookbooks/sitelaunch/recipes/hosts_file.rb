# TODO: THIS IS RISKY to extend hosts file of host machine using chef/vagrant.
log '/etc/hosts file reminder' do
  # Tricky way to retrieve host IP. See http://stackoverflow.com/questions/14518236/vagrant-how-to-get-hostonly-ip-adress-from-within-chef-recipe
  message "
    ************************************************\n
    ************************************************\n
    >>> Add this string to your /etc/hosts file: <<<\n
          #{node[:network][:interfaces][:eth1][:addresses].detect{|k,v| v[:family] == "inet" }.first}\t#{node['sitelaunch']['site_url']}\n
    ************************************************\n
    ************************************************\n
    Why that was not automated? That's very insecure to perform actions on host machine. Don't be lazy, mate."
  level :info
end