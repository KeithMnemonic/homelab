#### Setup base repo directories ####
mkdir -p ~/repos/github
mkdir -p ~/repos/gitlab

# Add local .gitconfig for each repo base directory #

git config -f  ~/repos/github/.gitconfig --add user.name KeithMnemonic
git config -f ~/repos/github/.gitconfig --add user.email kberger@suse.com
git config -f  ~/repos/github/.gitconfig --add gitreview.username kberger

git config -f  ~/repos/gitlab/.gitconfig --add user.name KeithMnemonic
git config -f ~/repos/gitlab/.gitconfig --add user.email kberger@suse.com


# copy master gitconfig #
mkdir ~/.config/git
cp ~/repos/gitlab-suse/wsl-config/config/git/config ~/.config/git
