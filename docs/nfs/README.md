Setup the NFS Provisioner

Prerequistes

    docs/k3s
    An nfs server with one exported path

Sources: 

https://www.phillipsj.net/posts/k3s-enable-nfs-storage/

https://docs.k3s.io/helm#using-the-helm-crd

https://michael-tissen.medium.com/setting-up-an-raspberrypi4-k3s-cluster-with-nfs-persistent-storage-a931ebb85737

https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner/blob/master/charts/nfs-subdir-external-provisioner/README.md

1) Create the nfs-system namespace
   ```
   kubectl create namespace nfs-system
   ```

2) Create an `nfs.yaml` file in
   
   `/var/lib/rancher/k3s/server/manifests/`

    ```
    apiVersion: helm.cattle.io/v1
    kind: HelmChart
    metadata:
      name: nfs
      namespace: nfs-system
    spec:
      chart: nfs-subdir-external-provisioner
      repo: https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner
      targetNamespace: nfs-system
      set:
        nfs.server: 192.168.1.17
        nfs.path: /mnt/HDD/NFS
        storageClass.name: nfs
    ```
3) After a few minutes, check the storage class.

    ```
    kubectl get sc -A
    NAME                   PROVISIONER                                         RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
    local-path (default)   rancher.io/local-path                               Delete          WaitForFirstConsumer   false                  23h
    longhorn (default)     driver.longhorn.io                                  Delete          Immediate              true                   19h
    nfs                    cluster.local/nfs-nfs-subdir-external-provisioner   Delete          Immediate              true                   11m
    ```
