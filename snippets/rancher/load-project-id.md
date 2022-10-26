---
vars:
  PROJECT_NAME:
    required: true
  CLUSTER_ID:
    required: true
  RANCHER_TOKEN:
    required: true
  RANCHER_HOST:
    required: true
register_vars:
  - FULL_PROJECT_ID
  - PROJECT_ID
---

```bash
FULL_PROJECT_ID=`curl -s -H "User-Agent: infra-as-loop" -H "Authorization: Bearer $RANCHER_TOKEN" https://$RANCHER_HOST/v3/clusters/$CLUSTER_ID/projects | jq -r '.data | .[] | select( .name == "'$PROJECT_NAME'") | .id'`

PROJECT_ID=${FULL_PROJECT_ID#*:}
```