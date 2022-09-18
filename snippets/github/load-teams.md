---
vars:
  GITHUB_TOKEN:
    required: true
  GITHUB_ORG:
    required: true
check: |
  validjson < inventories/github-teams.json
tmpdir: false
---

```sh
curl \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -f \
  https://api.github.com/orgs/$GITHUB_ORG/teams \
    > inventories/github-teams.json
```