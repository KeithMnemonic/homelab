Steps to install longhorn

Prerequisites: Install k3s, rancher, and metallb using the README.md files in docs/k3s, docs/rancher, and docs/metallb.

Source: https://rpi4cluster.com/k3s/k3s-storage-setting/

1) Add any additional disks to the 3 hosts prior to installing longhorn

2) Create a new primary partition on the disk with `fdisk`

3) Create a btrfs filesystem with:
    
    `mkfs -t btrfs /dev/<device>`

4) Mount the disk at `/var/lib/longhorn` You may need to create this directory
   
5) Setup longhorn using an IP from the metallb IPAddressPool
    ```
    helm repo add longhorn https://charts.longhorn.io
    helm repo update
    helm install longhorn longhorn/longhorn --namespace longhorn-system --create-namespace  --set service.ui.loadBalancerIP="192.168.1.40" --set service.ui.type="LoadBalancer"
    ```

6) Check the UI service is created.

   ```
   kubectl get svc -n longhorn-system longhorn-frontend
    NAME                TYPE           CLUSTER-IP    EXTERNAL-IP    PORT(S)        AGE
    longhorn-frontend   LoadBalancer   10.43.62.79   192.168.1.40   80:31209/TCP   57m
   ```

7) Login to the longhorn UI using the EXTERNAL-IP.

