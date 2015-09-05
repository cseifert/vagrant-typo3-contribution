# -*- mode: ruby -*-
# vi: set ft=ruby :

vagrantfile_api_version = "2"

# server settings
server_memory = "2048"
server_ip = "192.168.10.10"
server_name = "typo3cms"

# TYPO3 gerrit settings
gerrit_username = "YOUR_TYPO3_ACCOUNT_NAME"
gerrit_name = "YOUR FIRSTNAME AND LASTNAME"
gerrit_email = "YOUR EMAIL"

Vagrant.configure(vagrantfile_api_version) do |config|

  config.vm.box = "ubuntu/trusty64"
  config.vm.hostname = server_name
  config.vm.network :private_network, ip: server_ip

  config.vm.synced_folder "./www", "/var/www", {:mount_options => ['dmode=777','fmode=777'], :owner => 'vagrant', :group => 'vagrant'}

  config.vm.provider :virtualbox do |vb|
    vb.name = server_name
    vb.customize ["modifyvm", :id, "--memory", server_memory]
    vb.customize ["guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold", 10000]
	vb.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/v-root", "1"]
	vb.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/var/www", "1"]
  end

  if Vagrant.has_plugin?("vagrant-hostmanager")
    config.hostmanager.enabled = true
    config.hostmanager.manage_host = true
    config.hostmanager.ignore_private_ip = false
    config.hostmanager.include_offline = true
    config.hostmanager.aliases = server_name
  end

  config.ssh.username = "vagrant"
  config.ssh.password = "vagrant"
  config.ssh.insert_key = "true"

  config.vm.provision "file", source: "./setup/typo3.nginx.conf", destination: "/tmp/typo3.conf"
  config.vm.provision "file", source: "./setup/ssh_config.conf", destination: "/tmp/ssh_config.conf"
  config.vm.provision "file", source: "./setup/known_hosts", destination: "/home/vagrant/.ssh/known_hosts"

  # don't forget to add your own key files to "ssh-keys"
  config.vm.provision "file", source: "./ssh-keys/id_rsa", destination: "/home/vagrant/.ssh/id_rsa"
  config.vm.provision "file", source: "./ssh-keys/id_rsa.pub", destination: "/home/vagrant/.ssh/id_rsa.pub"

  # execute the provisioner script to set up the machine
  config.vm.provision "shell", path: "./setup/provision.sh", args: "#{server_ip} #{server_name} '#{gerrit_username}' '#{gerrit_name}' '#{gerrit_email}'"
end