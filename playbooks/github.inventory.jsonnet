local env = std.native("env");
local envOr = std.native("envOr");

{
  play: {
    key: "github-inventory",
    title: "🐙 read github organization",
    vars: {
      GITHUB_TOKEN: env("GITHUB_TOKEN"),
      GITHUB_ORG: env("GITHUB_ORG"),
    },
    loop_sets: {
      startups: std.parseYaml(importstr "inventories/startups.yaml"),
    },
    play: [
      {
        key: "load-teams",
        play: "github/load-teams.md",
      },
      {
        key: "load-repositories",
        play: "github/load-repos.md",
      },
      {
        key: "load-repositories-by-startup",
        loop_on: "startups as startup",
        vars: {
          TEAM_NAME: '${STARTUP_TEAM:-$STARTUP_NAME}'
        },
        play: "github/load-repos-by-startup.md",
      },
    ],
  }
}