# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  config.vm.box = "debian-73-x64"
  config.ssh.forward_agent = true
  config.vm.synced_folder "manifests/templates", "/tmp/vagrant-puppet-1/templates"

  config.vm.provision :shell do |shell|
    shell.path = "manifests/bootstrap.sh"
  end

  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = "manifests"
    puppet.manifest_file = "gossip.pp"
    puppet.options = ["--verbose", "--debug", "--templatedir", "/tmp/vagrant-puppet-1/templates"]
    puppet.facter = {}
  end

  config.vm.define "g1" do |g1|
    g1.vm.provider :virtualbox do |v|
      v.customize ["modifyvm", :id, "--memory", "512"]
      v.customize ["modifyvm", :id, "--cpus", 1]
    end

    g1.vm.network :private_network, ip: "192.168.33.10"
  end

  config.vm.define "g2" do |g2|
    g2.vm.provider :virtualbox do |v|
      v.customize ["modifyvm", :id, "--memory", "512"]
      v.customize ["modifyvm", :id, "--cpus", 1]
    end

    g2.vm.network :private_network, ip: "192.168.33.11"
  end

  config.vm.define "g3" do |g3|
    g3.vm.provider :virtualbox do |v|
      v.customize ["modifyvm", :id, "--memory", "512"]
      v.customize ["modifyvm", :id, "--cpus", 1]
    end

    g3.vm.network :private_network, ip: "192.168.33.12"
  end

end
