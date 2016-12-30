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
    backup_filename_sql = "#{params['realm']}-#{params['site']}-#{params['env']}.sql"
    # Do not download new backup if file already exists and use_old_backup option used.
    execute "Download recent backup." do
      command "wget -O /tmp/#{backup_filename} '#{recent_backup['link']}'"
      not_if {::File.exists?("/tmp/#{backup_filename}") && node['sitelaunch']['use_old_backup']}
    end
    execute "Unzip downloaded backup." do
      cwd "/tmp"
      command "gunzip -f -k /tmp/#{backup_filename}"
    end
    execute "Import via drush." do #--root='#{node['sitelaunch']['sites_dir']}/#{node['sitelaunch']['project_dir']}/#{node['sitelaunch']['drupal_dir']}' --uri='#{node['sitelaunch']['site_url']}'
      command "drush @#{node['sitelaunch']['drush_alias']} sqlc < /tmp/#{backup_filename_sql}"
      user 'vagrant'
    end
    # Delete sql file but keep archive.
    file "/tmp/#{backup_filename_sql}" do
      action :delete
    end
    # TODO: warning/error when no backups available.
  end
end