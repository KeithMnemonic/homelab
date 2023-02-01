Architecture: 

One part of the lab consists of 3 hosts running openSUSE MicroOS. Running on these hosts is:

    k3s (HA and an embedded DB)
    rancher (Using "Bring your own certs")
    longhorn (Using an extra storage disk)
    metallb (for LoadBalancer service types)

There is an additional container running nginx and dehydrated to handle cert requests and load balancing amongst services.