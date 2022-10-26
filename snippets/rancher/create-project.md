---
vars:
  PROJECT_NAME:
    required: true
  RANCHER_TOKEN:
    required: true
  RANCHER_HOST:
    required: true
  CLUSTER_ID:
    required: true
check: |
  PROJECT_ID=`curl -s -H "Authorization: Bearer $RANCHER_TOKEN" https://$RANCHER_HOST/v3/clusters/$CLUSTER_ID/projects | jq -r '.data | .[] | select( .name == "'$PROJECT_NAME'") | .id'`
  [ ! -z "$PROJECT_ID" ]
---

```bash
curl -s -u "$RANCHER_TOKEN" \
  -X POST \
  -H "Authorization: Bearer $RANCHER_TOKEN" \
  -H 'Accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{"clusterId":"'$CLUSTER_ID'","name":"'$PROJECT_NAME'"}' \
  'https://'$RANCHER_HOST'/v3/projects'
```