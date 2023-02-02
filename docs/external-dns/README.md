Install external-dns to integrate with cloudflare

1) Add the bitnami repo

    ```
    helm repo add bitnami https://charts.bitnami.com/bitnami
    ```

2) Create a namespace
   ```
    kubectl create namespace external-dns
    ```

3) Create a values.yaml with:

    ```
    sources:
     - service
     - ingress
    provider: cloudflare
    domainFilters:
     - bergerhome.org
    cloudflare:
        apiToken: "<TOKEN>"
        email: "<email>"
    policy: sync
    ```
4) install external-dns helm chart:
    ```
    helm install -n external-dns external-dns bitnami/external-dns -f values.yaml
    ```

5) For any services needing DNS entries add the following to the service
    ```
    external-dns.alpha.kubernetes.io/hostname: <svc-name>.bergerhome.org
    external-dns.alpha.kubernetes.io/cloudflare-proxied: "false"
    ```


