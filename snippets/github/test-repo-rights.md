---
vars:
  GITHUB_ORG:
    required: true
  GITHUB_TOKEN:
    required: true
  REPOSITORY_NAME:
    required: true
tmpdir: false
pre_check: |
  curl \
    -f \
    -H "Accept: application/vnd.github+json" \
    -H "User-Agent: infra-as-loop" \
    -H "Authorization: Bearer $GITHUB_TOKEN" \
    https://api.github.com/repos/$GITHUB_ORG/$REPOSITORY_NAME/keys
tmpdir: false
---

```sh
DIR=data/missing-rights-repos
mkdir -p $DIR
touch $DIR/$REPOSITORY_NAME.log
```