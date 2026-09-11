---
name: endor-agent-kit-setup
description: Use when setting up Endor Labs Agent Kit for VS Code / Copilot, checking readiness, verifying Endor auth, choosing namespaces, or diagnosing missing endorctl, gh, Copilot agent plugins, Endor MCP, or workflow prerequisites.
---

# Endor Agent Kit Setup For Copilot Agent Plugins

Generated for the Endor Labs Agent Kit Copilot agent plugin (Agent Plugins 1.0).

## Bundled Workflows

- `AI SAST Remediation` -> skill `ai-sast-remediation`, agent `ai-sast-remediation`
- `CI/CD And Supply Chain Posture` -> skill `cicd-posture`, agent `cicd-posture`
- `Configuration Automation` -> skill `configuration-automation`, agent `configuration-automation`
- `Dependency Reviewer` -> skill `dependency-reviewer`, agent `dependency-reviewer`
- `Findings Browser` -> skill `findings-browser`, agent `findings-browser`
- `Malware Responder` -> skill `malware-responder`, agent `malware-responder`
- `OSS Upgrade Investigator` -> skill `oss-upgrade-investigator`, agent `oss-upgrade-investigator`
- `Remediation Planning` -> skill `remediation-planning`, agent `remediation-planning`
- `SCA Remediation` -> skill `sca-remediation`, agent `sca-remediation`
- `Troubleshooting` -> skill `troubleshooting`, agent `troubleshooting`
- `Vulnerability Explainer` -> skill `vulnerability-explainer`, agent `vulnerability-explainer`

## Install The Plugin

This is an Agent Plugins 1.0 bundle (`plugin.json` at its root). Install it
with any Agent-Plugins-capable Copilot surface — VS Code, the Copilot CLI, or
the Copilot app. There is no `.vsix` and no VS Code Marketplace step.

The custom agents set `target: vscode`, so they appear only in VS Code. On the
Copilot CLI and the Copilot app, the skills of the same name carry the same
workflow contract; say so rather than reporting the agents as broken.

The install route differs by surface. Identify the surface first, then give
only the matching route.

- Copilot app: the app installs only from a marketplace and has no
  install-from-source route. The user adds `endorlabs/copilot-plugin` as a
  marketplace source, then installs `endor-labs-agent-kit` from it. This repo
  carries `.github/plugin/marketplace.json` for exactly this purpose.
- Copilot CLI: `copilot plugin marketplace add endorlabs/copilot-plugin` and
  then install `endor-labs-agent-kit`, or install the repo directly with
  `copilot plugin install endorlabs/copilot-plugin`.
- VS Code: Command Palette -> `Chat: Install Plugin From Source` and point it
  at `endorlabs/copilot-plugin`, whose root is this plugin, or register a local
  checkout in settings:

```json
"chat.pluginLocations": { "C:\\src\\copilot-plugin": true, "/path/to/copilot-plugin": true }
```

If a host reports `File not found: marketplace.json, .plugin/marketplace.json,
.github/plugin/marketplace.json, .claude-plugin/marketplace.json`, it was asked
to add a marketplace from a repository that has no marketplace manifest in any
of those four locations. Report the exact source that was tried and confirm the
spelling; do not diagnose it as an authentication or plugin-content problem.

For org-wide distribution, `extraKnownMarketplaces` in
`.github/copilot/settings.json` registers the marketplace for a repository, and
`managed-settings.json` supports `enabledPlugins`, `extraKnownMarketplaces`,
and `strictKnownMarketplaces` for enterprise-managed installs. Describe these
as options; never write them without explicit approval.

Reload the window / restart the Copilot surface after installing so the
skills, agents, and MCP server become visible.

# Endor Agent Kit Setup

Use this setup workflow when the user asks to install, check, update, or remove
Endor Labs Agent Kit plugin support files, or when an Endor Agent Kit workflow
is blocked by missing `endorctl`, GitHub CLI, authentication, namespace, or
local toolchain readiness.

## Setup Contract

Be proactive about checking the environment, but do not make persistent changes
without explicit user approval. Report evidence for each check. Never print
secret values.

Setup may:

- Inspect command availability and versions for `endorctl`, `gh`, `git`, and
  workflow-relevant language tooling.
- Read `ENDOR_NAMESPACE` from the current process environment and report it as
  namespace provenance when present.
- Safely parse `~/.endorctl/config.yaml` for non-secret fields such as
  `ENDOR_API` and `ENDOR_NAMESPACE`.
- Report the presence of credential fields by key name only.
- Report the presence of `ENDOR_API_CREDENTIALS_*` authentication variables by
  key name only.
- Run lightweight read-only Endor auth verification when config or credentials
  are present.
- Offer re-authentication when verification fails.
- Check `gh` authentication and point to official installation guidance.
- Inspect Endor MCP support when a selected workflow needs MCP or the user asks
  for MCP setup.
- Offer host-specific Endor MCP configuration only after explaining the exact
  file, command, and validation step.
- Install, update, or uninstall host-specific Agent Kit support files only after
  explicit approval.

Setup must not:

- Run `endorctl scan`.
- Run `endorctl host-check`.
- Print `~/.endorctl/config.yaml` or secret values.
- Read, cat, source, recurse through, or point `ENDORCTL_CONFIG` or
  `--config-path` at tenant-specific, customer-specific, production, backup,
  or other non-default Endor config directories.
- Ask the user to paste API keys, API secrets, tokens, or passwords into chat.
- Write `ENDOR_API_CREDENTIALS_KEY` or `ENDOR_API_CREDENTIALS_SECRET`.
- Edit shell profile files such as `.zshrc`, `.bashrc`, or PowerShell profile.
- Install `gh`, package managers, language runtimes, Docker, JDKs, or build
  tooling.
- Configure MCP globally without explicit user approval. MCP remains opt-in per
  recipe/workflow.

## Cross-Platform Notes

Report the host platform and shell in the readiness report, because the install
route and PATH mechanics differ. On Windows the shell is usually PowerShell,
Unix tools may be absent, and the binary is `endorctl.exe` — accept that name
wherever `endorctl` is expected. Use the host's own file tools to inspect
config files rather than `cat`, `type`, or `Get-Content`. Where a PATH change
is offered, prefer a route that needs no execution-policy change and no
administrator rights.

## Readiness Report

Start with a concise readiness report. Separate configured state from verified
state.

Include these sections when relevant:

- Ready
- Needs action
- Optional checks
- Available fixes

For Endor auth, report sanitized fields only:

```text
Endor config: found
API endpoint: https://api.endorlabs.com
Namespace candidates:
- ENDOR_NAMESPACE: not set
- ~/.endorctl/config.yaml ENDOR_NAMESPACE: example-namespace
Selected namespace: example-namespace from ~/.endorctl/config.yaml
Auth: API credential fields present
Endor auth: verified for namespace example-namespace
Secret values: hidden
```

If a namespace is missing, say that a namespace is required before live Endor
lookups. If a namespace is detected, let the user use it or override it for the
current workflow.

If `ENDOR_NAMESPACE` from the current process environment and
`~/.endorctl/config.yaml` disagree, surface both values and stop before live
Endor lookups. Ask the user which namespace to use for this workflow. Do not
silently trust either value, and do not unset environment variables or edit
config files unless the user explicitly asks for that separate operational
cleanup.

When the user selects or supplies a namespace, later workflow agents must pass
it explicitly with `-n <namespace>` or `--namespace <namespace>` for scoped
Endor lookups rather than relying on bare `endorctl` namespace resolution.

## Endor Tooling

`endorctl` is the single prerequisite for this plugin: both the CLI workflows
and the `endor-cli-tools` MCP server run the same binary. `npx`, `npm exec`,
`pnpm dlx`, and `yarn dlx` are never used, so Node is not required.

If `endorctl` is missing, offer a direct binary download with checksum
verification into a user-controlled directory already on PATH. This needs no
administrator rights and no package manager. Homebrew (`brew install
endorlabs/tap/endorctl`) is an optional convenience on macOS only.

Only download or install after explicit approval, and state the size first:
these binaries are roughly 320-350 MB.

### No-Admin Install

Pick the artifact for the host platform. The names use `macos`, not `darwin`:

| Platform | Artifact |
| --- | --- |
| Windows x64 | `endorctl_windows_amd64.exe` |
| macOS Apple silicon | `endorctl_macos_arm64` |
| macOS Intel | `endorctl_macos_amd64` |
| Linux x64 | `endorctl_linux_amd64` |
| Linux arm64 | `endorctl_linux_arm64` |

There is no native Windows arm64 build. On Windows arm64, use
`endorctl_windows_amd64.exe` under emulation and record that in the readiness
report.

Windows, using only in-box tools (`curl.exe`, `certutil`, `ren`) so neither
PowerShell nor an execution-policy change is required:

```
curl -O https://api.endorlabs.com/download/latest/endorctl_windows_amd64.exe
curl https://api.endorlabs.com/sha/latest/endorctl_windows_amd64.exe
certutil -hashfile .\endorctl_windows_amd64.exe SHA256
ren endorctl_windows_amd64.exe endorctl.exe
```

macOS and Linux, substituting the artifact name:

```
curl -O https://api.endorlabs.com/download/latest/endorctl_macos_arm64
curl https://api.endorlabs.com/sha/latest/endorctl_macos_arm64
shasum -a 256 endorctl_macos_arm64
mv endorctl_macos_arm64 endorctl && chmod +x endorctl
```

Compare the two checksums yourself and show both to the user. On any mismatch,
delete the download, report it as a failed verification, and stop; never
proceed with an unverified binary.

Then place the binary in a user-writable directory and put that directory on
PATH without administrator rights:

- Windows: `%LOCALAPPDATA%\Programs\endorctl\`. For the current session only,
  `set PATH=%LOCALAPPDATA%\Programs\endorctl;%PATH%`. To persist, prefer the
  Environment Variables dialog (`rundll32 sysdm.cpl,EditEnvironmentVariables`)
  and the user `Path` entry. Warn that `setx PATH` truncates at 1024 characters
  and can destroy a long PATH, so it is not the recommended route.
- macOS and Linux: `~/.local/bin`, which is already on PATH on most systems.
  Otherwise `export PATH="$HOME/.local/bin:$PATH"` for the current shell.

Tell the user how to put the directory on PATH and let them do it. Do not edit
shell profiles, the registry, or system PATH. Confirm success by running
`endorctl --version` in a fresh shell.

If API credential fields are present, do not run browser auth unless the user
explicitly asks to switch or re-authenticate. If API credential setup is needed,
tell the user to set `ENDOR_API_CREDENTIALS_KEY` and
`ENDOR_API_CREDENTIALS_SECRET` through their preferred secure environment
mechanism.

When browser or SSO authentication is requested, confirm the namespace first.
Use non-interactive flags where supported. If multi-tenant selection appears,
summarize the available tenant choices and ask the user before retrying.

## Endor MCP

Require `endorctl agent api --help` to succeed for workflows that use Endor CLI
API calls. Each selected workflow must pass its canonical recipe id through
`--agent-id`; never fall back to the unattributed legacy API command. Configure
Endor MCP only when a selected MCP-capable workflow needs it or the user
explicitly asks for it.

This plugin's own `mcp.json` declares the `endor-cli-tools` server ready to
use. Treat it, and any other MCP config the host already holds, as a setup
input rather than permission to start or register MCP without approval.

When MCP setup is requested:

1. Check whether `endorctl` is available on PATH, and install it first if not.
2. Verify the proposed server command is `endorctl ai-tools mcp-server`, which
   is exactly what this plugin's `mcp.json` declares. Reject any snippet that
   launches the server through `npx`, `npm exec`, `pnpm dlx`, or `yarn dlx`.
3. Inspect the host-specific MCP config location or installed plugin metadata.
4. If `endor-cli-tools` is already registered, report it and ask before
   changing anything.
5. If it is missing, show the exact config that would be added and ask for
   approval before writing host config files.
6. After approval and configuration, validate in a fresh host session when the
   host supports tool visibility checks.

Do not claim Endor MCP tools are available to a workflow until the host exposes
them in the current session. If MCP tools are unavailable, continue with
CLI-first workflows when they support `endorctl agent api --agent-id
<canonical-recipe-id>`; otherwise record the missing MCP capability in
`data_gaps`.

## GitHub CLI

Check `gh auth status` when workflows need GitHub evidence, repository
inventory, pull requests, or comments. If `gh` is missing, provide current
official installation guidance instead of installing it automatically.

Do not manage GitHub token scopes or create personal access tokens. Verify
only the specific read or write capability needed for the selected workflow.

## Language Tooling

Detect and report workflow-relevant package managers, language runtimes, and
build tools. Do not install them.

These are needed only to validate a remediation in the user's own project. No
Agent Kit workflow requires Python, Node, `jq`, or any other interpreter or
Unix tool, so their absence is never itself a readiness failure. Do not report
a missing interpreter as a blocker.

When tooling is missing, report the affected validation step and ask the user to
install it through their team-standard toolchain.

## Workflow Safety

Setup never performs remediation, creates branches, opens PRs/MRs, posts
comments, writes Endor policies, or runs scans. Mutating workflows such as SCA
Remediation and AI SAST Remediation keep those actions behind their generated agent
approval gates.

## Plugin-Specific Rules

- Keep plugin installs explicit. Do not install, enable, disable, or remove agent plugins without user approval.
- Do not add plugin-wide MCP automatically. The plugin's `mcp.json` `endor-cli-tools` server is opt-in; only guide MCP setup when a selected workflow needs it and the user approves.
- Do not collect, write, or persist Endor API credential values. Report credential presence by key name only.
- Invoke workflow custom agents from the agent picker; do not invent alternate invocation names.
- Copilot custom agents are host-managed; if a custom agent is unavailable, use the matching skill and report the limitation.
- Tell the user to reload the window / restart the Copilot surface after installing or updating the plugin if new skills or agents are not visible.
