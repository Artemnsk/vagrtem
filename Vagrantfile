Vagrant.require_version ">= 1.7.0"
require 'getoptlong'

Vagrant.configure("2") do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  config.vm.box = "bento/ubuntu-14.04"

  # Forward MySql port on 33066, used for connecting admin-clients to localhost:33066
  config.vm.network :forwarded_port, guest: 3306, host: 33066
  # Forward http port on 8080, used for connecting web browsers to localhost:8080
  config.vm.network :forwarded_port, guest: 80, host: 8080
  config.vm.network :forwarded_port, guest: 8983, host: 8983
  
  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  config.vm.network :private_network, ip: "33.33.33.10"

  # Set share folder permissions to 777 so that apache can write files
  config.vm.synced_folder "./public", "/vagrant", mount_options: ['dmode=777','fmode=666']

  # Provider-specific configuration so you can fine-tune VirtualBox for Vagrant.
  # These expose provider-specific options.
  config.vm.provider :virtualbox do |vb|
    # For example to change memory or number of CPUs:
    vb.customize ["modifyvm", :id, "--memory", "2048"]
    vb.customize ["modifyvm", :id, "--cpus", "1"]
  end

  # Load sitename.
  opts = GetoptLong.new(
    ["--id", GetoptLong::REQUIRED_ARGUMENT],
    ["--provision-with", GetoptLong::REQUIRED_ARGUMENT],
    ["--op", GetoptLong::REQUIRED_ARGUMENT],
    ["--use-old-backup", GetoptLong::NO_ARGUMENT]
  )
  id = ''
  op = ''
  use_old_backup = false
  opts.each do |opt, arg|
    case opt
      when "--id"
        id = arg
      when "--op"
        op = arg
      when "--use-old-backup"
        use_old_backup = true
    end
  end
  config.vm.provision "chef_solo" do |chef|
    # Build VM.
    chef.add_recipe "vm_build::default"
    # Sitelaunch.
    chef.log_level = :warn
    chef.data_bags_path = 'data_bags'
    chef.json = {
      "sitelaunch" => {
        "id" => id,
        "op" => op,
        "use_old_backup" => use_old_backup
      }
    }
    if (id != '' && op != '')
      chef.add_recipe "sitelaunch::default"
    end
  end
end