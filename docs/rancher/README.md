Steps to setup a 3 node rancher cluster using a nginx loadbalancer and with SSL pass through termination.

Prerequisites: Install an HA k3s per the README.md in docs/k3s

Source: https://ranchermanager.docs.rancher.com/pages-for-subheaders/install-upgrade-on-a-kubernetes-cluster

1) Install dehydrated on the nginx host

2) Configure `/etc/dehydrated/domains.txt` with the name of the HA rancher UI, for example rancher.bergerhome.org

3) Create a custom config file in `/etc/dehydrated/config.d` for any specific configuration needed for the cert provider and/or dns provider

	For example:
    ```
	HOOK="/home/kberger/cfhookbash/hook.sh"
	CHALLENGETYPE="dns-01"
    ```

4) Create the initial certs by running:

	```
    dehydrated --register --accept-terms
	dehydrated -c
    ```
	
5) Check to ensure the certs are created in the `/etc/dehydrated/certs` directory

6) Add entries into nginx for ports 80 and 443

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

7) Restart nginx with:
		
	`systemctl restart nginx`
		
15) On either the nginx or cluster hosts, create the namespace where rancher will be installed.

	`kubectl create namespace cattle-system`

8) On the nginx server, create `/etc/dehydrated/postrun-hooks.d/update_rancher_certs.sh`  with the following:

	```
    kubectl -n cattle-system create secret tls tls-rancher-ingress \
		--cert=/etc/dehydrated/certs/rancher.bergerhome.org/fullchain.pem \
		--key=/etc/dehydrated/certs/rancher.bergerhome.org/privkey.pem \
		--dry-run --save-config -o yaml | kubectl apply -f -
    ```
		
9) Setup the deyhdrated timer service

	```	
    systemctl enable dehydrated.timer
	systemctl start dehydrated.timer
    ```

10) Create the following directory;

	`/etc/systemd/system/dehydrated.service.d/`
		
11) Edit an override file with:

    ```
    vi /etc/systemd/system/dehydrated.service.d/override.conf
    ```
    and add the following:

	```
    [Install]
	WantedBy=multi-user.target
	```
	
12) Enable and start the dehydrated service

	```
    systemctl enable dehydrated.service
	systemctl enable dehydrated.service
    ```

13) On either the nginx or cluster node, check the secret was created.

	`kubectl get secret --namespace cattle-system`
		
	```
    NAME                  TYPE                DATA   AGE
	tls-rancher-ingress   kubernetes.io/tls   2      4s
    ```

14) Install rancher using the "Bring your own certs" option

	```
    helm install rancher rancher-latest/rancher --namespace cattle-system --set hostname=rancher.bergerhome.org --set bootstrapPassword=admin --set ingress.tls.source=secret
    ```

15) Access the rancher UI using the HA hostname.
