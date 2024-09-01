# Ansible

## Installation
```
sudo apt install ansible -y
```

## Python environment
```
make setup-env
```

### Useful Commands
1. Test connection to control node (to see if NSG configured correctly):
    ```
    sudo curl --cert /var/lib/rancher/k3s/agent/client-kubelet.crt \
            --key /var/lib/rancher/k3s/agent/client-kubelet.key \
            --cacert /var/lib/rancher/k3s/agent/client-ca.crt \
            -k -v https://<ip>/api/v1/nodes/k3s-worker-arm-0
    ```


curl -k https://140.238.194.151:6443
