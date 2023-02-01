Steps to setup a 3 node k3s cluster using a nginx loadbalancer and with SSL pass through termination

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

9) Install dehydrated on the nginx host

10) Configure `/etc/dehydrated/domains.txt` with the name of the HA rancher UI, for example rancher.bergerhome.org

11) Create a custom config file in `/etc/dehydrated/config.d` for any specific configuration needed for the cert provider and/or dns provider

	For example:
    ```
	HOOK="/home/kberger/cfhookbash/hook.sh"
	CHALLENGETYPE="dns-01"
    ```

12) Create the initial certs by running:

	```
    dehydrated --register --accept-terms
	dehydrated -c
    ```
	
13) Check to ensure the certs are created in the `/etc/dehydrated/certs` directory

14) Add entries into nginx for ports 80 and 443

Example in nginx.conf or conf.d file

```
http {
    upstream rancher_servers_http {
        least_conn;
        server 192.168.1.35:80 max_fails=3 fail_timeout=5s;
        server 192.168.1.36:80 max_fails=3 fail_timeout=5s;
        server 192.168.1.37:80 max_fails=3 fail_timeout=5s;
    }
    server {
        listen 80;
        server_name rancher.bergerhome.org;
        location / {
            return 301 https://$host$request_uri;
        }
    }
}
stream {
    upstream rancher_servers_https {
        least_conn;
        server 192.168.1.35:443 max_fails=3 fail_timeout=5s;
        server 192.168.1.36:443 max_fails=3 fail_timeout=5s;
        server 192.168.1.37:443 max_fails=3 fail_timeout=5s;
    }
    server {
        listen     443;
        proxy_pass rancher_servers_https;
    }
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

14) Restart nginx with:
		
	`systemctl restart nginx`
		
15) On either the nginx or cluster hosts, create the namespace where rancher will be installed.

	`kubectl create namespace cattle-system`

16) On the nginx server, create `/etc/dehydrated/postrun-hooks.d/update_rancher_certs.sh`  with the following:

	```
    kubectl -n cattle-system create secret tls tls-rancher-ingress \
		--cert=/etc/dehydrated/certs/rancher.bergerhome.org/fullchain.pem \
		--key=/etc/dehydrated/certs/rancher.bergerhome.org/privkey.pem \
		--dry-run --save-config -o yaml | kubectl apply -f -
    ```
		
17) Setup the deyhdrated timer service

	```	
    systemctl enable dehydrated.timer
	systemctl start dehydrated.timer
    ```

18) Create the following directory;

	`/etc/systemd/system/dehydrated.service.d/`
		
19) Edit an override file with:

    ```
    vi /etc/systemd/system/dehydrated.service.d/override.conf
    ```
    and add the following:

	```
    [Install]
	WantedBy=multi-user.target
	```
	
21) Enable and start the dehydrated service

	```
    systemctl enable dehydrated.service
	systemctl enable dehydrated.service
    ```

22) On either the nginx or cluster node, check the secret was created.

	`kubectl get secret --namespace cattle-system`
		
	```
    NAME                  TYPE                DATA   AGE
	tls-rancher-ingress   kubernetes.io/tls   2      4s
    ```

23) Install rancher using the "Bring your own certs" option

	```
    helm install rancher rancher-latest/rancher --namespace cattle-system --set hostname=rancher.bergerhome.org --set bootstrapPassword=admin --set ingress.tls.source=secret
    ```

24) Access the rancher UI using the HA hostname.
