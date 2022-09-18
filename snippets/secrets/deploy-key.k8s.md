---
vars:
  KUBECONFIG:
    required: true
  NAMESPACE:
    required: true
check: |
  kubectl -n $NAMESPACE get secrets deploy-key
---

```bash
ssh-keygen -b 4096 -m pem -t rsa -f ./sshkey -q -N ""
kubectl -n $NAMESPACE create secret generic deploy-key --from-file=PRIVATE_KEY=./sshkey
```