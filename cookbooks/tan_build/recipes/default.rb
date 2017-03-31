apt_update 'all platforms' do
  frequency 259200 # 3 days.
  action :periodic
end

# Some general handy packages.
apt_package 'curl'
apt_package 'vim'
# This one used to parse json in shell scripts.
apt_package 'jq'
apt_package 'build-essential'
# We need git to have bower work fine.
apt_package 'git-all'

# Install nodejs.
include_recipe "nodejs"
include_recipe "nodejs::npm"
bash 'Update node' do
  code <<-EOH
    sudo npm cache clean -f
    sudo npm install -g n
    sudo n 4.4.5
  EOH
end
# Install GLOBALLY.
nodejs_npm "gulp"
nodejs_npm "gulp-cli"
nodejs_npm "bower"