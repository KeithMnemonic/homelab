Notes for setting up home-assistant with SSL and client certs.

Install the NGINX Home Assistant SSL proxy and Let's Encrypt add-ons and the Renew Let's Encrypt Certificate blueprint

Let's Encrypt:

1) Configure the add on with:

    ```
    Domains: Add required domains
    Challenge: Use 'dns' if the home-assistant server or Nginx will not be exposed on port 80/443. Otherwise use 'http'.
    DNS:
        provider: dns-cloudflare
        cloudflare_api_token:  <CF token>
    ```

NGINX Home Assistant SSL proxy

1) Configure the add on with:
   ```
    Domains: Add required domains
    Certificate File: <path from Let's Encrypt>
    Private Key File: <path from Let's Encrypt>
    Customize:
        active: true
        default: nginx_proxy_default*.conf
        servers: nginx_proxy/*.con

Renew Let's Encrypt Certificate

https://community.home-assistant.io/t/automatic-renewal-of-lets-encrypt-addon-and-restart-of-nginx/306939

https://community.home-assistant.io/t/blueprint-for-automatic-renewal-of-a-lets-encrypt-certificate/300533


Once this is done you can access HA using https://<domain>

Once https access is working you can lock it down via a client certificate. 

1) Create a client cert.

   https://medium.com/@lukaszpinkosz/tls-client-authentication-for-your-home-assistant-e92452e26073

   https://gist.github.com/rkaramandi/20a04a41536f3d7e6d2f26b0b9605ab6

   create private CA

       ```
       openssl genrsa -out ca.key 4096
       openssl req -new -x509 -days 36500 -key ca.key -out ca.crt
       ```
   create client certificate for hass

      ```
      openssl genrsa -out hass.key 4096
      openssl req -new -key hass.key -out hass.csr
      openssl x509 -req -days 36500 -in hass.csr -CA ca.crt -CAkey ca.key -set_serial 01 -out hass.crt
      ```

   create PKCS#12 package to be installed on client side

      ```
      openssl pkcs12 -export -out hass.pfx -inkey hass.key -in hass.crt -certfile ca.crt
      ```

    Note: Use different OU name for CA vs Client cert.

2) Login to home-assistant using an ssh session or terminal.
   
3) Create nginx_proxy_default-client_ssl.conf in the share directory containing:

    ```
    ssl_client_certificate /ssl/ca.crt;
    ssl_verify_client on;
    ```

4) Copy the ca.crt from step 1 to the home-assistant host.
   
5) Restart Nginx and using the client cert from above try verify access to home-assistant is working.

    ```
    curl -i --cert hass.crt --key hass.key https://<ha FQDN>/
    ```