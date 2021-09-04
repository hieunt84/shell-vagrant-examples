# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  # make vm 
  config.vm.define "srv_docker" do |node|
    node.vm.box = "centos/7"
    node.vm.box_check_update = false             # không check update image centos/7
    node.vm.provider "virtualbox" do |vb|        # Máy ảo dùng nền tảng virtualbox, với các cấu hình bổ sung thêm cho provider
      vb.cpus = 2                                # cấp 2 nhân CPU
      vb.memory = "2048"                         # cấu hình dùng 2GB bộ nhớ
    end
#    node.vm.hostname = "srv-docker"
    node.vm.network "public_network", ip: "172.20.10.10"
    node.vm.provision "shell", path: "bootstrap.sh"   
  end

end
