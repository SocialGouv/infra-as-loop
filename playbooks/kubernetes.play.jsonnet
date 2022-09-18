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
              CI_NAMESPACE: "${STARTUP_NAME}-ci",
            },
            play: [
              {
                loop_on: "clusters as cluster",
                loop_sequential: true,
                vars: {
                  CLUSTER_ID: { from_register: true },
                  PROJECT_ID: { from_register: true },
                  KUBECONFIG: { from_var: "CLUSTER_KUBECONFIG_FILE" },
                },
                play: [
                  "rancher/load-cluster-id.md",
                  "rancher/load-cluster-kubeconfig.md",
                  {
                    vars: {
                      NAMESPACE: "$CI_NAMESPACE",
                      PROJECT_NAME: "$STARTUP_NAME",
                    },
                    play: [
                      "rancher/create-project.md",
                      "rancher/load-project-id.md",
                      "k8s/create-namespace.md",
                      "k8s/namespace-to-rancher-project.md",
                      "secrets/deploy-key.k8s.md",
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