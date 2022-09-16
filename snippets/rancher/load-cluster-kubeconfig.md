---
vars:
  CLUSTER_NAME:
    required: true
  RANCHER_TOKEN:
    required: true
  RANCHER_HOST:
    required: true
register_vars:
  - CLUSTER_KUBECONFIG
---

```bash
CLUSTER_KUBECONFIG=`curl -s -X POST -H "Authorization: Bearer $RANCHER_TOKEN" https://$RANCHER_HOST/v3/clusters/${CLUSTER_ID}?action=generateKubeconfig | jq -r '.config'`
```