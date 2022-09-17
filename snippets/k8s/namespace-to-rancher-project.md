---
vars:
  KUBECONFIG:
    required: true
  PROJECT_NAME:
    required: true
  CLUSTER_ID:
    required: true
  PROJECT_ID:
    required: true
  NAMESPACE:
    required: true
check: |
  [ "`kubectl get namespace $NAMESPACE --no-headers --output=go-template='{{index .metadata.annotations "field.cattle.io/projectId"}}'`" = "${CLUSTER_ID}:${PROJECT_ID}" ]
allow_fail: true
---

```bash
kubectl annotate --overwrite namespaces $NAMESPACE field.cattle.io/projectId=${CLUSTER_ID}:${PROJECT_ID}
```