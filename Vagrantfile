VM_MEMORY_CTRL = 4096
VM_MEMORY_NODE = 6144
VM_CPUS_CTRL = 1
VM_CPUS_NODE = 2
NODE_COUNT = ENV.fetch("WORKER_COUNT", 2).to_i
BASE_IP = "192.168.56."

Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-24.04"

  # Control Node
  config.vm.define "ctrl" do |ctrl|
    ctrl.vm.hostname = "ctrl"
    ctrl.vm.network "private_network", ip: "#{BASE_IP}100"
    ctrl.vm.provider "virtualbox" do |vb|
      vb.memory = VM_MEMORY_CTRL
      vb.cpus = VM_CPUS_CTRL
    end

    ctrl.vm.provision 'ansible' do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.playbook = "provision/general.yml"
    end

    ctrl.vm.provision 'ansible' do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.playbook = "provision/ctrl.yml"
    end
  end

  # Worker Nodes
  (1..NODE_COUNT).each do |i|
    config.vm.define "node-#{i}" do |node|
      node.vm.hostname = "node-#{i}"
      node.vm.network "private_network", ip: "#{BASE_IP}#{100 + i}"
      node.vm.provider "virtualbox" do |vb|
        vb.memory = VM_MEMORY_NODE
        vb.cpus = VM_CPUS_NODE
      end
      node.vm.provision 'ansible' do |ansible|
        ansible.compatibility_mode = "2.0"
        ansible.playbook = "provision/general.yml"
      end
  
      node.vm.provision 'ansible' do |ansible|
        ansible.compatibility_mode = "2.0"
        ansible.playbook = "provision/node.yml"
      end
    end
  end
end