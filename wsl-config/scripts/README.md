
Steps to bring up new WSL/ vagrant

1) copy ssh keys and gpg keys
	   mkdir ~/.ssh
	   cp -R /mnt/d/wsl_config/ssh/* ~/.ssh
	   chmod 600 ~/.ssh/id_rsa
	   gpg --list-keys
	   gpg --import /mnt/d/wsl_config/gpg/kberger.secret.key
	   gpg --import /mnt/d/wsl_config/gpg/myprivatekeys.asc
	   gpg --import /mnt/d/wsl_config/gpg/mypubkeys.asc
	   gpg -K
       gpg -k
	   gpg --import-ownertrust /mnt/d/wsl_config/gpg/otrust.txt
	   
2) setup sudo
		sudo sed -i  '/^root ALL.*/a kberger ALL=(ALL) NOPASSWD: ALL' /etc/sudoers
3) install packages (xauth, git, ansible, python3-virtualenv, lnav
		sudo zypper ref
		sudo zypper up  -y
		sudo zypper in xauth git ansible python3-virtualenv lnav zsh vagrant rsync osc

4) Clone wsl-config, create repo dirs and setup gitconfig
		
		setup_git_config.sh
		
5) install oh-my-zsh with plugin
		mkdir ~/tmp
		cd ~/tmp
		wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
		sh install.sh
		git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/plugins/zsh-autosuggestions
		git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/plugins/zsh-syntax-highlighting
		cp ~/repos/gitlab/wsl-config/zsh/.zshrc ~
	

8) Setup links
		ln -s /mnt/c/Users/kberger.HOME/Downloads Downloads

TODO see if you can get vagrant/virtualbox windows intergration working
