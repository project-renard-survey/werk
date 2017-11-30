# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
	config.vm.hostname = "werk"
	config.vm.box = "stuffo/xenial64"

	config.vm.provider "virtualbox" do |vb|
		vb.cpus = "4"
		vb.memory = "1024"
	end

	config.vm.provision "shell", inline: <<-SHELL
		apt-get update
		apt-get install -y build-essential \
			curl \
			graphviz

		# --- Perl
		curl -sL http://cpanmin.us | perl - App::cpanminus

		cpanm Module::Build
		cpanm App::pmuninstall

		echo "installdeps --cpan_client='cpanm --mirror http://cpan.org'" | tee "${HOME}/.modulebuildrc"
	SHELL
end
