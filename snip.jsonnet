local env = std.native("env");
local envOr = std.native("envOr");

{
  log_level: envOr("LOG_LEVEL", "info"),
  playbooks: [
    "github.inventory.jsonnet",
    "kubernetes.play.jsonnet",
  ],
}