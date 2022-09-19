local env = std.native("env");
local envOr = std.native("envOr");

{
  log_level: envOr("LOG_LEVEL", "info"),
  play: {
    key: "github-play",
    title: "🐙 prepare github for each startup",
    vars: {
      GITHUB_TOKEN: env("GITHUB_TOKEN"),
      GITHUB_ORG: env("GITHUB_ORG"),
    },
    loop_sets: {
      startups: std.parseYaml(importstr "inventories/startups.yaml"),
      repositories: std.parseJson(importstr "inventories/github-repos.json"),
    },
    play: {
      loop_on: "startups as startup",
      vars: {
        TEAM_NAME: "${STARTUP_TEAM:-$STARTUP_NAME}",
      },
      play: {
        loop_on: "repositories as repository",
        // filter: "github-team-repo",
        play: [
          "github/create-deploy-key.md",
        ],
      },
    }
  }
}