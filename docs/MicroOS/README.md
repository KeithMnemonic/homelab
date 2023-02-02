Steps to install MicroOS

Prerequisites:

Minimum VM/Host requirments:

Disks: 2 (one is for the system and the second is for longhorn. (200 GB, for example)
Memory: 2048
CPU: 1 Core/vCPU

1) Install using "MicroOS Container Host" scenario.
   
2) In "Partitioning" add the second disk using XFS and mounted at /var/lib/longhorn

3) In "Software" add Patterns "Base System" and "Enhanced Base System. Under details add:

   ```
   nfs-client (Enhanced)
   bind-utils
   wget
   distrobox (Container Runtime)
    ```
4) Adjust "Network Configuration" and "Security" as needed

5) After installation add the following packages using `transactional-update pkg install`
   ```
   open-iscsi
   jq
   cockpit
   cockpit-ws
   cockpit-tukit
   cockpit-networkmanager
   git
   zsh
   lnav
   ```

6) Enable cockpit service `systemctl enable --now cockpit.socket`

7) Add user via cli or cockpit
8) Create `~/.ssh` directory and add public ssh key to `authorized_keys`
9)  Enable sudo 
   ```
   sudo sed -i  '/^root ALL.*/a <user> ALL=(ALL) NOPASSWD: ALL' /etc/sudoers```
