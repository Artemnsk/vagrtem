if (node['sitelaunch']['acquia'] != nil && node['sitelaunch']['drush_alias'] != '')
  require 'json'
  require 'uri'
  require 'net/http'
  params = node['sitelaunch']['acquia']

  # todo: rename.
  backup_filename = "#{params['realm']}-#{params['site']}-#{params['env']}.sql.gz"
  backup_filename_sql = "#{params['realm']}-#{params['site']}-#{params['env']}.sql"
  can_proceed = false
  # If we don't want to use old backup or backup file doesn't exist we need to download it from Acquia first.
  if (!node['sitelaunch']['use_old_backup'] || !::File.exists?("/tmp/#{backup_filename}"))
    # Get backups JSON.
    uri_str = "https://cloudapi.acquia.com/v1/sites/#{params['realm']}:#{params['site']}/envs/#{params['env']}/dbs/#{params['db_name']}/backups.json"
    uri = URI.parse(uri_str)
    http = Net::HTTP.new(uri.host, 443)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri)
    request.basic_auth(params['user'], params['password'])
    # Send request.
    begin
      response = http.request(request)
    rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, Errno::ECONNREFUSED, EOFError, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => e
      log 'Acquia connection errors' do
        message "Cannot retrieve backups list from Acquia. Some connection error (maybe you use invalid credentials?)."
        level :error
      end
      response = nil
    end
    if (response != nil)
      # Parse response.
      backups = JSON.parse(response.body())
      if (backups.length > 0)
        # Find recent backup by date timestamp.
        recent_backup = backups.first()
        backups.each do |backup|
          if (backup['completed'] > recent_backup['completed'])
            recent_backup = backup
          end
        end
        # Download recent backup using download link from JSON.
        execute "Download recent backup." do
          command "wget -O /tmp/#{backup_filename} '#{recent_backup['link']}'"
        end
        if (::File.exists?("/tmp/#{backup_filename}"))
          can_proceed = true
        else
          log 'wget failed' do
            message "Can not download recent backup. Download link is invalid or something happen during wget."
            level :error
          end
        end
      else
        # Todo: empty backups response err?
        log 'No backups available.' do
          message "No backups of '#{params['db_name']}' DB available for #{params['realm']}:#{params['site']} on #{params['env']} environment on Acquia."
          level :error
        end
      end
    end
  else
    # We can proceed otherwise.
    can_proceed = true;
  end

  # After code above we are sure that we have backup archive in /tmp directory so we can safely proceed.
  if (can_proceed)
    execute "Unzip backup archive." do
      cwd "/tmp"
      command "gunzip -f -k /tmp/#{backup_filename}"
    end
    execute "Import via drush." do
      command "drush @#{node['sitelaunch']['drush_alias']} sqlc < /tmp/#{backup_filename_sql}"
      user 'vagrant'
    end
    # Delete sql file but keep archive.
    file "/tmp/#{backup_filename_sql}" do
      action :delete
    end
  end
end