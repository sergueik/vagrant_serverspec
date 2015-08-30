# -*- mode: ruby -*-
# vi: set ft=ruby :

basedir = ENV.fetch('USERPROFILE', '')  
basedir = ENV.fetch('HOME', '') if basedir == ''
basedir = basedir.gsub('\\', '/')

vagrant_use_proxy = ENV.fetch('VAGRANT_USE_PROXY', nil)
http_proxy        = ENV.fetch('HTTP_PROXY', nil) 
box_name          = ENV.fetch('BOX_NAME', '') 
debug             = ENV.fetch('DEBUG', 'false') 
box_memory        = ENV.fetch('BOX_MEMORY', '') 
box_cpus          = ENV.fetch('BOX_CPUS', '') 
box_gui           = ENV.fetch('BOX_GUI', '') 
debug             = (debug =~ (/^(true|t|yes|y|1)$/i))
vagrantfile_local = 'Vagrantfile.local'

unless box_name =~ /\S/
  if File.exist?(vagrantfile_local)
    if debug
      puts "Loading '#{vagrantfile_local}'"
    end
    # config = Hash[File.read(File.expand_path(vagrantfile_local)).scan(/(.+?) *= *(.+)/)]
    config = {}
    File.read(File.expand_path(vagrantfile_local)).split(/\n/).each do |line| 
      if line !~ /^#/
        key_val = line.scan(/^ *(.+?) *= *(.+) */)
        config.merge!(Hash[key_val])
      end
    end
    box_name = config['box_name']
    box_gui = config['box_gui'] != nil && config['box_gui'].match(/(true|t|yes|y|1)$/i) != nil
    box_cpus = config['box_cpus'].to_i
    box_memory = config['box_memory'].to_i
  else
    # TODO: throw an error
  end
end 

if debug
  puts "box_name=#{box_name}"
  puts "box_gui=#{box_gui}"
  puts "box_cpus=#{box_cpus}"
  puts "box_memory=#{box_memory}"
end

VAGRANTFILE_API_VERSION = '2'
 
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  if vagrant_use_proxy
    if http_proxy
      if Vagrant.has_plugin?('vagrant-proxyconf')
        config.proxy.http     = http_proxy.gsub('%%','%')
        config.proxy.https    = http_proxy.gsub('%%','%')
        config.proxy.no_proxy = 'localhost,127.0.0.1'
      end
    end 
  end

  # Localy cached images from http://www.vagrantbox.es/ and  http://dev.modern.ie/tools/vms/linux/
  case box_name
    when /centos6/ 
     config_vm_box      = 'centos/65'
     config_vm_box_url  = "file://#{basedir}/Downloads/centos-6.5-x86_64.box"
    when /centos7/
     config_vm_box      = 'centos/7'
     config_vm_box_url  = "file://#{basedir}/Downloads/centos-7.0-x86_64.box"
    when /trusty32/
      config_vm_box     = 'ubuntu/trusty32'
      config_vm_box_url = "file://#{basedir}/Downloads/trusty-server-cloudimg-i386-vagrant-disk1.box"
    when /trusty64/
      config_vm_box     = 'ubuntu/trusty64'   
      config_vm_box_url = "file://#{basedir}/Downloads/trusty-server-cloudimg-amd64-vagrant-disk1.box"
    when /precise64/
      config_vm_box     = 'ubuntu/precise64'
      config_vm_box_url = "file://#{basedir}/Downloads/precise-server-cloudimg-amd64-vagrant-disk1.box"
    else
      # tweak modern.ie image into a vagrant manageable box
      # https://gist.github.com/uchagani/48d25871e7f306f1f8af
      # https://groups.google.com/forum/#!topic/vagrant-up/PpRelVs95tM 
      config_vm_box     = 'windows7'
      config_vm_box_url = "file://#{basedir}/Downloads/vagrant-win7-ie10-updated.box"
  end
  # Configure guest-specific port forwarding
  if config_vm_box =~ /windows/
    ENV.delete('HTTP_PROXY')
    config.vm.communicator      = 'winrm'
    config.winrm.username       = 'vagrant'
    config.winrm.password       = 'vagrant'
    config.vm.guest             = :windows
    config.windows.halt_timeout = 15
    # Port forward WinRM and RDP
    config.vm.network :forwarded_port, guest: 3389, host: 3389, id: 'rdp', auto_correct: true
    config.vm.network :forwarded_port, guest: 5985, host: 5985, id: 'winrm', auto_correct:true
    config.vm.boot_timeout      = 120
    # Ensure that all networks are set to 'private'
    config.windows.set_work_network = true
    # on Windows, use default data_bags share
  end
  # Configure common synced folder
  config.vm.synced_folder './', '/vagrant'
  
  config.vm.provider 'virtualbox' do |vb|
    vb.gui = box_gui 
    vb.customize ['modifyvm', :id, '--cpus', box_cpus ]
    vb.customize ['modifyvm', :id, '--memory', box_memory ]
    vb.customize ['modifyvm', :id, '--clipboard', 'bidirectional']
    vb.customize ['modifyvm', :id, '--accelerate3d', 'off']
    vb.customize ['modifyvm', :id, '--audio', 'none']
    vb.customize ['modifyvm', :id, '--usb', 'off']
  end
  config.vm.define 'coney' do |config|
    config.vm.box = config_vm_box
    config.vm.box_url  = config_vm_box_url
    config.vm.hostname = 'coney.example.com'
    config.vm.network 'private_network', ip: '192.168.50.101'
  # Provision software
      # Use shell provisioner to install puppet 3.8.1
      config.vm.provision :shell, :path=> 'bootstrap.sh'
      # Use puppet provisioner to install puppetlabs-rabitmq v. 4.0.0
    config.vm.provision :puppet do |puppet| 
      puppet.manifest_file = 'step3.pp'
      puppet.module_path = 'modules'
      puppet.manifests_path = 'manifests'
      puppet.facter = { 'fqdn' => config.vm.hostname, 'flags' => 'rabbitmq_slave' } 
      puppet.options        = '--verbose'
    end 
  end
  config.vm.define 'rabbit' do |config|
    config.vm.box = config_vm_box
    config.vm.box_url  = config_vm_box_url
    config.vm.hostname = 'rabbit.example.com'
    config.vm.network 'private_network', ip: '192.168.50.100'
    config.vm.network :forwarded_port, guest: 5672, host: 5672 
    config.vm.network :forwarded_port, guest: 15672, host: 15672 
  # Provision software
      # Use shell provisioner to install puppet 3.8.1
      config.vm.provision :shell, :path=> 'bootstrap.sh'
      # Use puppet provisioner to install puppetlabs-rabitmq v. 4.0.0
    config.vm.provision :puppet do |puppet| 
      puppet.manifest_file = 'step3.pp'
      puppet.module_path = 'modules'
      puppet.manifests_path = 'manifests'

      puppet.facter = { 'fqdn' => config.vm.hostname, 'flags' => 'rabbitmq_master' } 
      puppet.options        = '--verbose'
    end
  end
end
