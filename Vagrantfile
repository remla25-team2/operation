VM_MEMORY_CTRL = 4096
VM_MEMORY_NODE = 6144
VM_CPUS_CTRL = 2
VM_CPUS_NODE = 2
NODE_COUNT = ENV.fetch("WORKER_COUNT", 2).to_i
BASE_IP = "192.168.56."

# Prepare host information for Ansible
ALL_HOSTS = []
ALL_HOSTS << { name: "ctrl", ip: "#{BASE_IP}100" }
(1..NODE_COUNT).each do |i|
  ALL_HOSTS << { name: "node-#{i}", ip: "#{BASE_IP}#{100 + i}" }
end

Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-24.04"
  config.vm.box_version = "202502.21.0"

  # Define common Ansible provisioning for general.yml
  # This ensures extra_vars are available to general.yml on all nodes
  common_general_ansible_config = Proc.new do |ansible|
    ansible.compatibility_mode = "2.0"
    ansible.playbook = "provision/general.yml"
    ansible.extra_vars = {
      all_cluster_hosts: ALL_HOSTS
    }
  end

  # Control Node
  config.vm.define "ctrl" do |ctrl|
    ctrl.vm.hostname = "ctrl"
    ctrl.vm.network "private_network", ip: "#{BASE_IP}100"
    ctrl.vm.provider "virtualbox" do |vb|
      vb.memory = VM_MEMORY_CTRL
      vb.cpus = VM_CPUS_CTRL
    end

    # Apply common general ansible config
    ctrl.vm.provision "general_config_ctrl", type: "ansible", &common_general_ansible_config

    ctrl.vm.provision "ctrl", type: "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.playbook = "provision/ctrl.yml"
    end
  end

  # Worker Nodes
  (1..NODE_COUNT).each do |i|
    node_name = "node-#{i}"
    config.vm.define "node-#{i}" do |node|
      node.vm.hostname = "node-#{i}"
      node.vm.network "private_network", ip: "#{BASE_IP}#{100 + i}"
      node.vm.provider "virtualbox" do |vb|
        vb.memory = VM_MEMORY_NODE
        vb.cpus = VM_CPUS_NODE
      end

      node.vm.provision "general_config_#{node_name}", type: "ansible", &common_general_ansible_config

      node.vm.provision 'node', type: 'ansible' do |ansible|
        ansible.compatibility_mode = "2.0"
        ansible.playbook = "provision/node.yml"
      end
    end
  end
end
