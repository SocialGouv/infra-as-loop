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
  SECRET_NAME:
    default: DEPLOY_KEY
check: |
  curl \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $GITHUB_TOKEN" \
    -f \
    https://api.github.com/repos/$GITHUB_ORG/$REPOSITORY_NAME/actions/secrets \
      | jq -r '.secrets | .[] | select( .name == "'$SECRET_NAME'" ) | .name' > .secret-name
  [ "$SECRET_NAME" = "$(cat .secret-name)" ]
---

```bash
KEY_NAME=$(kube-slug "deploy-key-$REPOSITORY_NAME")
privateKey=$(kubectl -n $CI_NAMESPACE get secrets $KEY_NAME -o jsonpath='{.data.PRIVATE_KEY}' | base64 --decode)

export GITHUB_REPO_PUBLIC_KEY=$(curl -s -H "authorization: Bearer $GITHUB_TOKEN" https://api.github.com/repos/${GITHUB_ORG}/${REPOSITORY_NAME}/actions/secrets/public-key)
GITHUB_REPO_PUBLIC_KEY_ID=$(echo $GITHUB_REPO_PUBLIC_KEY | jq -r .key_id)
export BASE64_ENCODED_PUBLIC_KEY=$(echo $GITHUB_REPO_PUBLIC_KEY | jq -r .key)
encryptedToken=$(echo -n "$privateKey" | encrypt-secret-for-github-api)

curl \
  -X PUT \
  -H "Accept: application/vnd.github.v3+json" \
  -u "$GITHUB_USERNAME:$GITHUB_TOKEN" \
  "https://api.github.com/repos/${GITHUB_ORG}/${REPOSITORY_NAME}/actions/secrets/${SECRET_NAME}" \
  -d '{"encrypted_value":"'${encryptedToken}'","key_id": "'${GITHUB_REPO_PUBLIC_KEY_ID}'"}'      
```