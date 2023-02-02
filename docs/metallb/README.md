Steps to install metallb

Prerequisites: Install k3s using the README.md files in docs/k3s.

Source: https://metallb.universe.tf/installation/

1) Setup helm
    ```
    helm repo add metallb https://metallb.github.io/metallb
    helm install metallb metallb/metallb
    ```

1) Setup namespace

   ```
   kubectl create namespace metallb-system
   kubectl label namespace  metallb-system pod-security.kubernetes.io/enforce=privileged
   kubectl label namespace  metallb-system pod-security.kubernetes.io/warn=privileged
   kubectl label namespace  metallb-system pod-security.kubernetes.io/audit=privileged
   kubectl describe namespace metallb-system
   ```

2) Setup helm
    ```
    helm repo add metallb https://metallb.github.io/metallb
    helm install -n metallb-system metallb metallb/metallb
    ```

3) Create IPAddressPool with:
   ```
    apiVersion: metallb.io/v1beta1
    kind: IPAddressPool
    metadata:
      name: first-pool
      namespace: metallb-system
    spec:
      addresses:
      - 192.168.1.40-192.168.1.55
    ```
4) Create L2Advertisement with:
    ```
    apiVersion: metallb.io/v1beta1
    kind: L2Advertisement
    metadata:
      name: example
      namespace: metallb-system
    spec:
      ipAddressPools:
      - first-pool
5) Apply IPAddressPool and L2Advertisement

