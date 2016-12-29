if (node['sitelaunch']['drush_alias'] != '')
  execute "Remove drush alias file." do
    command "rm /home/vagrant/.drush/#{node['sitelaunch']['id']}.aliases.drushrc.php"
    only_if {::File.exists?("/home/vagrant/.drush/#{node['sitelaunch']['id']}.aliases.drushrc.php")}
  end
  execute "Clear drush cache." do
    command "drush cc drush"
  end
end