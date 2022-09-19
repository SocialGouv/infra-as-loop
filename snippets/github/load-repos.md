---
vars:
  GITHUB_TOKEN:
    required: true
  GITHUB_ORG:
    required: true
check: |
  validjson < inventories/github-repos.json
tmpdir: false
---

```sh
curl \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -f \
  https://api.github.com/orgs/$GITHUB_ORG/repos?per_page=100 \
    | jq -r '.[] | {name: .name}' \
    | jq -r -s \
      > inventories/github-repos.json
```