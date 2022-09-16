local env = std.native("env");
local envOr = std.native("envOr");

{
  log_level: envOr("LOG_LEVEL", "info"),
  play: {

    key: "main",
    title: "🌍 declarative infra as loop reconciliation",

    vars_sets: {
      kubernetes: {
        RANCHER_HOST: envOr("RANCHER_HOST", "rancher.fabrique.social.gouv.fr"),
        RANCHER_TOKEN: env("RANCHER_TOKEN"),
        KUBECONFIG: env("KUBECONFIG"),
      },
      github: {
        GITHUB_TOKEN: env("GITHUB_TOKEN"),
      },
    },
    loop_sets: {
      startups: std.parseYaml(importstr "./startups.yaml"),
      clusters: [
        {
          name: "dev",
        },
        {
          name: "prod",
        },
      ],
    },

    play: [

      {
        key: "kubernetes",
        title: "🐳 prepare kubernetes for each startup",
        loop_on: ["kubernetes"],
        play: [
          {
            loop_on: "startups as startup",
            vars: {
              CI_NAMESPACE: "${startup_name}-ci",
            },
            play: [
              {
                loop_on: "clusters as cluster",
                loop_sequential: true,
                vars: {
                  CLUSTER_NAME: "${cluster_name}",
                },
                play: [
                  {
                    play: [
                      
                      "demo/hello.md",
                    ],
                  },
                  {
                    vars: {
                      NAMESPACE: "$CI_NAMESPACE",
                      RANCHER_PROJECT_NAME: "$startup_name",
                    },
                    play: [
                      // "rancher/create-project.md",
                      // "rancher/load-project-id.md",
                      // "k8s/namespace.md",
                      // "rancher/namespace-to-project.md",
                    ],
                  },
                ],
              },
            ],
          },
        ],
      },

      // {
      //   key: "github",
      //   title: "🐙 prepare github for each startup",
      //   loop_on: ["github"],
      //   play: {
      //     loop_on: "startups",
      //     play: [
            
      //     ],
      //   },
      // },

    ],
  }
}