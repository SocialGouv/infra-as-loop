---
vars:
  KUBECONFIG:
    required: true
  GITHUB_ORG:
    required: true
  GITHUB_TOKEN:
    required: true
  REPOSITORY_NAME:
    required: true
  CI_NAMESPACE:
    required: true
  GH_KEY_NAME:
    default: infra-as-loop-deploy-key
check: |
  KEY_NAME=$(kube-slug "deploy-key-$REPOSITORY_NAME")
  if [ ! -f id_rsa.key ]; then
    kubectl -n $CI_NAMESPACE get secrets $KEY_NAME -o jsonpath='{.data.PRIVATE_KEY}' | base64 --decode > id_rsa.key
    chmod 0400 id_rsa.key
    echo $private_key | ssh-keygen -y -f id_rsa.key > id_rsa.pub
  fi
  curl \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $GITHUB_TOKEN" \
    -f \
    https://api.github.com/repos/$GITHUB_ORG/$REPOSITORY_NAME/keys \
      | jq -r '.[] | select( .title == "'$GH_KEY_NAME'" ) | .key' > id_rsa.pub.remote
  [ "$(cat id_rsa.pub)" = "$(cat id_rsa.pub.remote)" ]
---

```bash
echo
echo "+ deploy key:"
echo -n ">> "
{
curl \
  -i \
  -H "Authorization: token $GITHUB_TOKEN"\
  --data @- https://api.github.com/repos/$GITHUB_ORG/$REPOSITORY_NAME/keys << EOF
{
  "title" : "$GH_KEY_NAME",
  "key" : "$(cat id_rsa.pub)",
  "read_only" : false
}
EOF
} 2>/dev/null | head -1 # status code should be 201
```