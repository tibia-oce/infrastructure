# Monitoring with Prometheus and Grafana

[kube-prometheus](https://github.com/prometheus-operator/kube-prometheus/tree/main)

![architecture](/docs/assets/images/prometheus-architecture.png)

## CPU & Memmory

### Pods:
```
for i in $(kubectl get nodes | grep -v NAME | awk -F " " '{print $1}'); do
  amount=$(kubectl describe node $i | grep "Non-terminated" | awk -F " " '{print $3}' | sed s/\(//) && \
  kubectl describe node $i | grep -A$amount Namespace
done
```

### Node 
```
kubectl top nodes
```

### Pods
```
kubectl top pods
```
