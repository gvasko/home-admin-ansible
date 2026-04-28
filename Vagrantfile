Vagrant.configure("2") do |config|
  # Use Ubuntu 24.04 LTS
  config.vm.box = "ubuntu/jammy64"

  config.vm.hostname = "ansible-control-node"

  # Networking (Optional: Static IP for easier SSH)
  config.vm.network "private_network", ip: "192.168.56.10"

  # Provisioning: Install Ansible
  config.vm.provision "shell", inline: <<-SHELL
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get install -y software-properties-common
    add-apt-repository --yes --update ppa:ansible/ansible
    apt-get install -y ansible
    
    echo "Ansible installation complete. Version:"
    ansible --version
  SHELL

  # Provider-specific tweaks (Memory/CPU)
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048"
    vb.cpus = 2
  end
end
