if (node['sitelaunch']['acquia'] != nil && node['sitelaunch']['drush_alias'] != '')
  require 'json'
  require 'uri'
  require 'net/http'
  params = node['sitelaunch']['acquia']

  # Get backups JSON.
  uri_str = "https://cloudapi.acquia.com/v1/sites/#{params['realm']}:#{params['site']}/envs/#{params['env']}/dbs/#{params['db_name']}/backups.json"
  uri = URI.parse(uri_str)
  http = Net::HTTP.new(uri.host, 443)
  http.use_ssl = true
  request = Net::HTTP::Get.new(uri)
  request.basic_auth(params['user'], params['password'])
  response = http.request(request)
  backups = JSON.parse(response.body())

  if (backups.length > 0)
    recent_backup = backups.first()
    backups.each do |backup|
      if (backup['completed'] > recent_backup['completed'])
        recent_backup = backup
      end
    end
    backup_filename = "#{params['realm']}-#{params['site']}-#{params['env']}.sql.gz"
    execute "Download recent backup." do
      command "wget -O /tmp/#{backup_filename} '#{recent_backup['link']}'"
    end
    execute "Unzip downloaded backup and import via drush." do
      # In some reason chef_solo provisions don't properly run as vagrant user (consequently drush alias not be found).
      command "su vagrant -l -c \"gunzip -c /tmp/#{backup_filename} | drush @#{node['sitelaunch']['drush_alias']} sqlc\""
    end
    execute "Remove backup." do
      command "rm /tmp/#{backup_filename}"
    end
    # TODO: warning/error when no backups available.
  end
end