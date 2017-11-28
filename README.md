# werk

## Setting up a development environment

	vagrant up
	vagrant ssh

	sudo su -
	cd /vagrant

	perl Build.PL
	./Build installdeps
	./Build
	./Build test
