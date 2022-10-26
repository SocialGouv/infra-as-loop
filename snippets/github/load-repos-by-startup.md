---
vars:
  GITHUB_TOKEN:
    required: true
  GITHUB_ORG:
    required: true
  TEAM_NAME:
    required: true
  TEAM_DIR:
    default: data/github-teams/$TEAM_NAME
check: |
  validjson < $TEAM_DIR/github-repos.json
tmpdir: false
---

https://docs.github.com/en/rest/teams/teams#list-team-repositories

```sh
mkdir -p $TEAM_DIR

PAGE=0
JSONFILE=$TEAM_DIR/github-repos.json
echo "[]" > $JSONFILE
while true; do
  PAGE=$((PAGE+1))
  JSONFILE_PAGE=$TEAM_DIR/github-repos-page-${PAGE}.json
  curl \
    -H "Accept: application/vnd.github+json" \
    -H "User-Agent: infra-as-loop" \
    -H "Authorization: Bearer $GITHUB_TOKEN" \
    -f \
    "https://api.github.com/orgs/$GITHUB_ORG/teams/$TEAM_NAME/repos?page=${PAGE}&per_page=100" > $JSONFILE_PAGE
  if [ "$(cat $JSONFILE_PAGE | jq -r)" = "[]" ]; then
    break;
  fi
  JSON=$(jq -s 'add' $JSONFILE $JSONFILE_PAGE)
  echo $JSON > $JSONFILE
done
```