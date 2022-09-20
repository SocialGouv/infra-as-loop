---
vars:
  KUBECONFIG:
    required: true
  CI_NAMESPACE:
    required: true
  REPOSITORY_NAME:
    required: true
check: |
  KEY_NAME=$(kube-slug "deploy-key-$REPOSITORY_NAME")
  kubectl -n "$CI_NAMESPACE" get secrets "$KEY_NAME"
---

```bash
KEY_NAME=$(kube-slug "deploy-key-$REPOSITORY_NAME")
ssh-keygen -b 4096 -m pem -t rsa -f ./sshkey -q -N ""
kubectl -n "$CI_NAMESPACE" create secret generic "$KEY_NAME" --from-file=PRIVATE_KEY=./sshkey
```