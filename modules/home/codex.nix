{
  pkgs-unstable,
  ...
}:

{
  home.file.".codex/config.toml".text = ''
    personality = "pragmatic"
    model = "gpt-5.4"
    model_reasoning_effort = "medium"
    plan_mode_reasoning_effort = "xhigh"
    approvals_reviewer = "auto_review"
    approval_policy = "on-request"
    sandbox_mode = "workspace-write"

    [features]
    multi_agent = true
    apps = true
    prevent_idle_sleep = true
    fast_mode = false
    guardian_approval = true

    [plugins."github@openai-curated"]
    enabled = true
  '';

  home.packages = [ pkgs-unstable.codex ];
}
