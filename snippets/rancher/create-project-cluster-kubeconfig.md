---
vars:
  CLUSTER_NAME:
    required: true
  RANCHER_TOKEN:
    required: true
  RANCHER_HOST:
    required: true
register_vars:
  - CLUSTER_KUBECONFIG_FILE
---

```bash
CLUSTER_KUBECONFIG=`curl -s -X POST -H "User-Agent: infra-as-loop" -H "Authorization: Bearer $RANCHER_TOKEN" https://$RANCHER_HOST/v3/clusters/${CLUSTER_ID}?action=generateKubeconfig | jq -r '.config'`

CLUSTER_KUBECONFIG_FILE="$PWD/kubeconfig"

echo "$CLUSTER_KUBECONFIG" > $CLUSTER_KUBECONFIG_FILE
```