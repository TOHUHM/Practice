Vagrant.configure(2) do |config|

  (1..3).each do |i|

    # 配置master虚机
    config.vm.define "master#{i}" do |master|

      # 设置虚拟机的Box
      master.vm.box = "centos7"

      # 设置虚拟机的主机名
      master.vm.hostname = "kube-master#{i}"
      
      # 设置虚拟机的IP
      master.vm.network "private_network", ip: "192.168.88.#{i+30}"

      # VirtaulBox相关配置
      master.vm.provider "virtualbox" do |vb|

          # 设置虚拟机的内存大小
          vb.memory = 2048

          # 设置虚拟机的CPU个数
          vb.cpus = 4
      end

      # master上shell脚本
       master.vm.provision "shell", path: "common.sh"
    end

    # 配置node虚机
    config.vm.define "node#{i}" do |node|

      # 设置虚拟机的Box
      node.vm.box = "centos7"

      # 设置虚拟机的主机名
      node.vm.hostname = "kube-node#{i}"
      
      # 设置虚拟机的IP
      node.vm.network "private_network", ip: "192.168.88.#{i+40}"

      # VirtaulBox相关配置
      node.vm.provider "virtualbox" do |vb|

          # 设置虚拟机的内存大小
          vb.memory = 2048

          # 设置虚拟机的CPU个数
          vb.cpus = 4
      end

      # node上shell脚本
      # node.vm.provision "shell", path: "node.sh"

    end

  end

  # master和node公共脚本
  config.vm.provision "shell", path: "common.sh"

  # ssh配置
 # config.ssh.username = "vagrant"
#  config.ssh.private_key_path = "D:/virtualization/.vagrant.d/insecure_private_key"
#  config.ssh.insert_key = false

end
