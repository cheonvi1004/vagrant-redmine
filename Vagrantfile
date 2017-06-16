# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/xenial64"
  
  # Prevent "Inappropriate ioctl for device" message
  config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"

  config.vm.define :redmine do |redmine|
  end

  # We have to use port 3000 because it is whitelisted by Auth0
  config.vm.network :forwarded_port, host: 8009, guest: 80
  config.vm.network :forwarded_port, host: 33069, guest: 3306

  config.vm.provider "virtualbox" do |vb|
    vb.memory = 2048
    vb.cpus = 2
  end

  config.vm.synced_folder "./", "/home/ubuntu/redmine", owner: "www-data", group: "www-data", mount_options: ["dmode=777", "fmode=777"]

  # Provision Apache
  config.vm.provision "shell" do |s|
    s.path = "./.devl/etc/provision/provision_apache.sh"
    s.args = "redmine.local deac@sfp.net /var/www/redmine"
  end

  # Provision MySql
  config.vm.provision "shell" do |s|
    s.path = "./.devl/etc/provision/provision_mysql.sh"
    s.args = "redmine secret"
  end

  # Provision Redmine
  config.vm.provision "shell" do |s|
    s.path = "./.devl/etc/provision/provision_redmine.sh"
    s.args = ""
  end

end
