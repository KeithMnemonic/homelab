#!/bin/sh

add_config()
{
	git config --local --add user.name KeithMnemonic
	git config --local --add user.email kberger@suse.com
	git config --local --add gitreview.username kberger
}

clone_repo()
{
	git clone https://github.com/openstack/$1.git
}

echo "Cloning openstack/$1"
clone_repo $1

echo "Adding git local gitconfig settings"
cd $1
add_config
pwd

