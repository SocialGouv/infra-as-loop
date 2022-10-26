---
vars:
  CLUSTER_NAME:
    required: true
  RANCHER_TOKEN:
    required: true
  RANCHER_HOST:
    required: true
register_vars:
  - CLUSTER_ID
---

```bash
CLUSTER_ID=`curl -s -H "Authorization: Bearer $RANCHER_TOKEN" https://$RANCHER_HOST/v3/clusters | jq -r '.data | .[] | select( .name == "'$CLUSTER_NAME'" ) | .id'`
```