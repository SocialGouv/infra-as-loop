local env = std.native("env");
local envOr = std.native("envOr");

{
  log_level: envOr("LOG_LEVEL", "info"),
  playbooks: [
    "kubernetes.play.jsonnet",
  ],
}