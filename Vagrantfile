# -*- coding: utf-8; mode: ruby -*-
# vi: set ft=ruby :

unless Vagrant.has_plugin?('vagrant-properties', '~> 0.6')
  action = Vagrant.has_plugin?('vagrant-properties') ? 'update' : 'install'
  puts "Please this command: vagrant plugin #{action} vagrant-properties"
  exit
end

Vagrant.configure('2') do |config|
  Dir.chdir(File.expand_path '../', __FILE__)
  config.vm.box = 'linyows/centos-7.1_chef-12.2_puppet-3.7'

  def _configure(chef)
    chef.cookbooks_path = %w(cookbooks vendor/cookbooks)
    chef.roles_path = 'roles'
    chef.data_bags_path = 'data_bags'
    #chef.log_level = :debug
  end

  def define_machine_spec(config, properties)
    memory = properties.memory || 512
    cpus   = properties.core   || 2
    config.vm.provider :virtualbox do |vbox|
      vbox.customize ["modifyvm", :id, "--memory", memory.to_i]
      vbox.customize ["modifyvm", :id, "--cpus", cpus.to_i]
    end
  end

  config.vm.define :ldap do |c|
    p = c.properties.named(:ldap)
    c.vm.network :private_network, ip: p.ext_ip
    c.vm.hostname = p.hostname
    c.vm.provision :chef_zero do |chef|
      _configure chef
      chef.add_role 'ldap'
    end
  end
  config.vm.define :client do |c|
    p = c.properties.named(:client)
    c.vm.network :private_network, ip: p.ext_ip
    c.vm.hostname = p.hostname
    c.vm.provision :chef_zero do |chef|
      _configure chef
      chef.add_role 'client'
    end
  end
end
