if (node['sitelaunch']['drush_alias'] != '')
  file "/etc/drush/#{node['sitelaunch']['id']}.aliases.drushrc.php" do
    action :delete
  end

  execute "Clear drush cache." do
    command "drush cc drush"
  end
end