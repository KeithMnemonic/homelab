Steps to setup a 3 node k3s cluster using a nginx loadbalancer.

Source: https://docs.k3s.io/installation/ha-embedded

1) Install nginx and kubectl on the host with the HA IP address.

2) Setup nginx to handle port 6443

    Example in nginx.conf or conf.d file

      ```
      stream {
          upstream k3s {
              server 192.168.1.35:6443;
              server 192.168.1.36:6443;
              server 192.168.1.37:6443;
          }
          server {
              listen 6443;
              proxy_pass k3s;
          }
      }
      ```
3) Enable and start nginx with:
    ```
   systemctl enable nginx
   systemctl start nginx
    ```
4) Create `/etc/rancher/k3s/config.yaml` on all cluster hosts with the following contents before installing k3s . (You may need to create this directory)

    ```
   tls-san:
     - rancher.bergerhome.org
     - 192.168.1.38
    ```

5) Install k3s on all 3 cluster hosts

	1st server:

    ```
    curl -sfL https://get.k3s.io | K3S_TOKEN=SECRET INSTALL_K3S_VERSION=v1.24.10+k3s1 sh -s - server --cluster-init
    ```

	2nd and 3rd server:
    
    ```
    curl -sfL https://get.k3s.io | K3S_TOKEN=SECRET INSTALL_K3S_VERSION=v1.24.10+k3s1 sh -s - server  --server https://192.168.1.35:6443
    ```

6) Copy `/etc/rancher/k3s/k3s.yaml` to the host running nginx into  `~/.kube/config`

7) On the nginx host, run  ` vi ~/.kube/config` and set the server address to the HA IP address.
 
	For example:
    ```
	server: https://rancher.bergerhome.org:6443
    ```

8) Check access to the cluster by running:

	`kubectl get nodes -A`
