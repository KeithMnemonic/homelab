Steps to install portainer using the longhorn persisted storage.

1) Check the storage class to ensure longhorn is listed
   
   `kubectl get sc -A`

2) Add the portainer helm chart repo
   
   ```
   helm repo add portainer https://portainer.github.io/k8s/
    helm repo update
    ```
3) Install portainer using the loadbalancer option.
   
    ```
    helm install --create-namespace -n portainer portainer portainer/portainer \
    --set service.type=LoadBalancer \
    --set tls.force=true --set persistence.storageClass=longhorn
    ```
4) Annotate the service so external-dns will create the DNS name
   
   ```
    kubectl annotate service -n portainer portainer external-dns.alpha.kubernetes.io/cloudflare-proxied=false
    kubectl annotate service -n portainer portainer  external-dns.alpha.kubernetes.io/hostname=portainer.bergerhome.org