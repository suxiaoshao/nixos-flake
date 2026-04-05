{
  pkgs,
  pkgs-unstable,
  ...
}:

{
  home.file.".codex/config.toml".text = ''
    personality = "pragmatic"
    model = "gpt-5.4"
    model_reasoning_effort = "medium"
    plan_mode_reasoning_effort = "xhigh"
    approvals_reviewer = "guardian_subagent"
    approval_policy = "on-request"
    sandbox_mode = "workspace-write"

    [features]
    multi_agent = true
    js_repl = true
    apps = true
    prevent_idle_sleep = true
    fast_mode = false
    guardian_approval = true

    [plugins."github@openai-curated"]
    enabled = true
  '';

  home.packages = with pkgs; [
    nixd
    nil
    nixfmt-rfc-style
    pkgs-unstable.codex
  ];
}
