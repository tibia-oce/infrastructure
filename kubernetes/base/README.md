## OCI Load Balancer -> NGINX Proxy -> MetalLB Speakers -> Traefik Ingress Controller

How This Works:

    Request Flow:
        A user sends a request to app1.example.com, which is resolved by Cloudflare (which is hosting the domain name) and sent to your OCI Load Balancer.
        The OCI Load Balancer forwards this request to the NGINX proxy running on your node(s). The request still contains the Host: app1.example.com header.

    NGINX Proxy:
        NGINX proxies the request to the MetalLB IP (10.0.1.110) while preserving the original Host header. This is ensured by the proxy_set_header Host $host; directive in your NGINX configuration.
        NGINX adds other headers like X-Real-IP, X-Forwarded-For, and X-Forwarded-Proto, but it doesn’t alter the Host header.

    Traefik:
        The request reaches the Traefik service (exposed via MetalLB on 10.0.1.110).
        Traefik receives the request with the Host header intact (e.g., Host: app1.example.com).
        Traefik uses this Host header to match rules in the IngressRoute or Ingress and route the request to the correct backend service.

Why This Works:

    proxy_set_header Host $host;: This directive ensures that NGINX passes along the original Host header from the client request (app1.example.com). When NGINX forwards the request to MetalLB (10.0.1.110), it doesn't change the Host header.

    Traefik’s Host-Based Routing: Traefik doesn't care that the request is coming from 10.0.1.110; it will look at the Host header in the HTTP request to determine where to route the traffic. So, even though the request is proxied through multiple layers, Traefik will still see Host: app1.example.com and route accordingly.
