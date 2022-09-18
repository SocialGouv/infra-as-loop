---
vars:
  GITHUB_TOKEN:
    required: true
  GITHUB_ORG:
    required: true
  TEAM_NAME:
    required: true
  TEAM_DIR:
    default: inventories/github-teams/$TEAM_NAME
check: |
  validjson < $TEAM_DIR/github-repos.json
tmpdir: false
---

```sh
mkdir -p $TEAM_DIR
curl \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -f \
  https://api.github.com/orgs/$GITHUB_ORG/teams/$TEAM_NAME/repos \
    > $TEAM_DIR/github-repos.json
```