## BGP and DRG

Given I'd eventually like to migrate the cluster to a hybrid (on-prem & cloud) configuration, I opted to use a dynamic routing gateway and configure MetalLB in BGP mode.

1. High-Level Traffic Flow without DRG (Traditional Setup)

In a typical Kubernetes cluster using NodePort or LoadBalancer services (without MetalLB and DRG), the traffic flow is straightforward:

    External traffic comes to the OCI Flexible Load Balancer.
    The load balancer forwards traffic to the NodePort on specific nodes (via their private IP addresses).
    The Kubernetes NodePort service directs traffic to the appropriate pod hosting the service (e.g., an NGINX pod).

2. Introducing MetalLB in BGP Mode

MetalLB allows Kubernetes to expose services of type LoadBalancer natively, eliminating the need for manually managing NodePorts. When MetalLB operates in BGP mode, it can dynamically advertise IP routes to an external router or gateway using the BGP (Border Gateway Protocol) or ARP (which doesn't seem to be all that well supported/documented by cloud providers).

Here’s how MetalLB with BGP mode integrates into the traffic flow with the DRG and OCI Flexible Load Balancer:
Traffic Flow with MetalLB (BGP) and DRG:

1. External Traffic Reaches the OCI Flexible Load Balancer
    A client sends a request to your service (e.g., NGINX).
    The request arrives at the OCI Flexible Load Balancer, which is configured to listen on a specific external IP address (e.g., 203.0.113.100).
    The load balancer needs to forward the request to the IP address assigned to the Kubernetes service by MetalLB.

2. MetalLB Assigns an External IP
    MetalLB assigns an external IP from its configured IP range (for example, 192.168.1.240/29) to your NGINX service.
    This external IP is part of a private IP range within your Kubernetes cluster network, **which is not natively routable from the OCI cloud network.**

3. MetalLB Advertises the IP via BGP to the DRG

    Since MetalLB is operating in BGP mode, it advertises the routes for the IPs it manages (e.g., 192.168.1.240/29) to an external BGP peer—in this case, the DRG.
    The DRG (Dynamic Routing Gateway) is the gateway between the OCI cloud network and your Kubernetes cluster network. It supports BGP peering and allows routes from MetalLB to be advertised to OCI’s network infrastructure.
    MetalLB uses BGP to tell the DRG, "I can route traffic directly to the IP range 192.168.1.240/29."

4. DRG Propagates Routes to OCI

    The DRG learns the IP range advertised by MetalLB (e.g., 192.168.1.240/29) and propagates these routes to the OCI cloud network.
    Now, the OCI network, including the Flexible Load Balancer, is aware that traffic destined for the IP 192.168.1.240 (or any IP in that range) should be routed via the DRG.

5. OCI Flexible Load Balancer Forwards Traffic via the DRG

    The OCI Flexible Load Balancer forwards the client’s traffic to the external IP assigned by MetalLB (e.g., 192.168.1.240).
    The traffic is routed through the DRG, which passes the traffic into the Kubernetes cluster.

6. MetalLB Receives the Traffic and Routes to the Kubernetes Service

    MetalLB receives the traffic at the advertised IP (192.168.1.240) and forwards it to the appropriate Kubernetes service (the LoadBalancer type service, such as NGINX).
    Kubernetes directs the traffic to one of the pods hosting the NGINX service, completing the request.

---

## Nodeport

Setting up Traefik as an ingress controller within the K3s cluster allows you to manage how incoming traffic is routed to your services. 

1. Traefik serves as an ingress controller, which means it manages how external traffic from the internet or other sources is routed to various services running in your Kubernetes cluster. It listens to incoming requests and routes them based on rules defined in Kubernetes ingress resources.

2. K3s comes with Traefik installed by default as the ingress controller. However, if you need to customize its configuration, you can modify it or install a different version of Traefik.

To Verify or Modify Traefik Installation:

Check if Traefik is Running:
    Run kubectl get pods --namespace kube-system to see if Traefik pods are running.

Customizing Traefik:
    You can override the default configuration by editing the HelmChart configuration:

----

o verify that your worker nodes are correctly exposing the Traefik dashboard service, you can follow these steps:
1. Check the Traefik Deployment and Service

First, ensure that the Traefik deployment and service are running as expected.

    Check the Traefik Deployment:

    bash

kubectl get deployments -n kube-system

Look for the Traefik deployment in the output. Ensure that it shows the desired number of replicas and that they are all available.

Check the Traefik Service:

bash

    kubectl get service traefik -n kube-system

    This command will show you the service details, including the ports that are exposed and the ClusterIP, NodePort, or LoadBalancer IP assigned to the service.

2. Verify the NodePort

If the Traefik service is exposed as a NodePort, you can check which port is being used:

    Run the following command to get the details of the Traefik service:

    bash

kubectl describe service traefik -n kube-system

Look for the NodePort in the output under the Ports section. This will tell you which port on the worker nodes is being used to expose the Traefik service.