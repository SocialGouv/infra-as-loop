---
vars:
  KUBECONFIG:
    required: true
  NAMESPACE:
    required: true
check: |
  [ ! -z "`kubectl get namespace $NAMESPACE --no-headers --output=go-template={{.metadata.name}}`" ]
check_quiet: true
---

```bash
kubectl create namespace $NAMESPACE
```