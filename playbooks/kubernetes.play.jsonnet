local env = std.native("env");
local envOr = std.native("envOr");

{
  play: {
    
    key: "main",
    title: "🌍 provisioning kubernetes",
    loop_sets: {
      startups: std.parseYaml(importstr "inventories/startups.yaml"),
      clusters: [
        {
          name: "dev",
        },
        {
          name: "prod",
        },
      ],
    },

    vars: {
      RANCHER_HOST: envOr("RANCHER_HOST", "rancher.fabrique.social.gouv.fr"),
      RANCHER_TOKEN: env("RANCHER_TOKEN"),
      KUBECONFIG: env("KUBECONFIG"),
    },

    play: [

      {
        key: "kubernetes-bootstrap",
        title: "🐳 prepare kubernetes for each startup",
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
                      // "secrets/deploy-key.k8s.md",
                    ],
                  },
                ],
              },
            ],
          },
        ],
      },

      {
        key: "deploy-keys",
        title: "🔑 create deploy keys for each repository",
        loop_on: "startups as startup",
        vars: {
          TEAM_NAME: "${STARTUP_TEAM:-$STARTUP_NAME}",
          CI_NAMESPACE: "${STARTUP_NAME}-ci",
        },
        play: [
          {
            loop_on: "exec:inventories/github-team-repo.mjs",
            play: [
              "github/deploy-key.init-k8s.md",
              "github/deploy-key.register-gh-repo.md",
              "github/deploy-key.register-gh-ci.md"
            ]
          },
        ],
      },
    ],
  }
}