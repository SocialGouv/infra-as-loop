---
vars:
  GITHUB_TOKEN:
    required: true
  GITHUB_ORG:
    required: true
  TEAM_DATA_FILE:
    default: data/github-teams.json
check: |
  validjson < $TEAM_DATA_FILE
tmpdir: false
---

```sh
mkdir -p `dirname $TEAM_DATA_FILE`
curl \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -f \
  https://api.github.com/orgs/$GITHUB_ORG/teams \
    > $TEAM_DATA_FILE
```