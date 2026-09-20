---
name: endor-agent-kit-setup
description: Use when setting up Endor Labs Agent Kit for VS Code / Copilot, checking readiness, verifying Endor auth, choosing namespaces, or diagnosing missing endorctl, gh, Copilot agent plugins, or workflow prerequisites.
---

# Endor Agent Kit Setup For Copilot Agent Plugins

Generated for the Endor Labs Agent Kit Copilot agent plugin (Agent Plugins 1.0).

## Bundled Workflows

- `AI SAST Remediation` -> skill `ai-sast-remediation`, agent `ai-sast-remediation`
- `CI/CD And Supply Chain Posture` -> skill `cicd-posture`, agent `cicd-posture`
- `Configuration Automation` -> skill `configuration-automation`, agent `configuration-automation`
- `Dependency Reviewer` -> skill `dependency-reviewer`, agent `dependency-reviewer`
- `Diff Scan` -> skill `diff-scan`, agent `diff-scan`
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
skills and agents become visible.

## Bundled Hook

The plugin ships one hook, declared in `com.github.copilot/hooks/hooks.json`:

| Event | Script | Behaviour |
| --- | --- | --- |
| `PostToolUse` | `dependency-introduction.sh` / `.ps1` | Reminds the agent to check newly added or upgraded dependencies against Endor. Never blocks. |

Hook support is preview, and coverage differs by surface: VS Code and the
Copilot CLI run hooks, the Copilot app may not. A surface that ignores the hook
loses only the reminder — every workflow still works when invoked directly, so
report an absent hook as reduced coverage, not as a broken install.

The hook needs no new tooling. On macOS and Linux it is POSIX `sh` plus `grep`;
on Windows it is in-box PowerShell. It never calls `jq`, `node`, `python`, or
`npx`, matching the rest of the plugin.

Report the hook in the readiness report: whether `hooks.json` is present in the
installed plugin, whether the surface supports hooks, and — on macOS and Linux
— whether `dependency-introduction.sh` carries its execute bit. Do not install,
edit, enable, or disable hooks without explicit approval.

If the hook is present but never fires, check in this order: the surface
supports hooks at all; the plugin is installed and the window was reloaded; the
plugin-root variable in `hooks.json` resolves on this host, since an unresolved
root yields a path that silently does not exist.

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
  `ENDOR_API` and `ENDOR_NAMESPACE`, and report the region `ENDOR_API` implies.
- Report the presence of credential fields by key name only.
- Report the presence of `ENDOR_API_CREDENTIALS_*` authentication variables by
  key name only.
- Run lightweight read-only Endor auth verification when config or credentials
  are present.
- Read the tenant's licensed features from `EndorLicense` and report which
  bundled workflows they enable.
- Offer re-authentication when verification fails.
- Ask which Endor region a tenant is in when no endpoint is configured, and
  re-authenticate against the other region after approval when a region
  mismatch is the likely cause of a missing tenant namespace.
- Check `gh` authentication and point to official installation guidance.
- Verify `endorctl agent api` access for workflows that read Endor evidence.
- Report whether the bundled `PostToolUse` hook is installed and whether the
  current Copilot surface supports hooks.
- Explain the exact file, command, and validation step before proposing any
  host configuration change.
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
- Start, register, or remove an MCP server on the user's behalf.
- Install, edit, enable, or disable plugin hooks without explicit approval.

## Cross-Platform Notes

Report the host platform and shell in the readiness report, because the install
route and PATH mechanics differ. On Windows the shell is usually PowerShell,
Unix tools may be absent, and the binary is `endorctl.exe` — accept that name
wherever `endorctl` is expected. Use the host's own file tools to inspect
config files rather than `cat`, `type`, or `Get-Content`. Where a PATH change
is offered, prefer a route that needs no execution-policy change and no
administrator rights.

That preference is about what setup asks the *user* to change. It does not
conflict with the bundled hook's `powershell -NoProfile -ExecutionPolicy Bypass
-File ...` command line: `-ExecutionPolicy Bypass` applies to that one
invocation only, needs no administrator rights, and leaves the machine and user
execution policies untouched. Say so if a user asks why the hook uses it, and
do not offer to change a persistent execution policy.

## Endor Region

Endor Labs runs more than one cluster, and a tenant exists in exactly one of
them. Authentication against the wrong cluster fails in a confusing way: the
login itself can succeed while no tenant namespace is returned.

| Region | API endpoint | Application URL |
| --- | --- | --- |
| US (default) | `https://api.endorlabs.com` | `https://app.endorlabs.com` |
| EU | `https://api.eu.endorlabs.com` | `https://app.eu.endorlabs.com` |

Determine the region before authenticating, in this order:

1. If `~/.endorctl/config.yaml` already has an `ENDOR_API` value, or `ENDOR_API`
   is set in the environment, report it with its provenance and the region it
   implies. Do not change it without approval.
2. If both are set and disagree, surface both with provenance and stop. Ask
   which to use, exactly as for a namespace conflict.
3. If neither is set, **ask the user which region their tenant is in**. Offer
   US (default) and EU, and say that the region is the one whose application URL
   they sign in to. Do not assume US silently.

Pass the choice with `--api` on the authenticating command:

```
endorctl init --api https://api.eu.endorlabs.com --auth-mode <MODE>
```

US is the built-in default, so `--api` may be omitted for it. On success
`endorctl init` writes the chosen endpoint to `~/.endorctl/config.yaml` as
`ENDOR_API`, alongside `ENDOR_NAMESPACE`; `ENDOR_API: https://api.eu.endorlabs.com`
is a valid and expected value. Report that key by name and value — it is not a
secret — while continuing to report `ENDOR_API_CREDENTIALS_*` by key name only.

Valid `--auth-mode` values are `github`, `google`, `gitlab`, `azureadv2`, `sso`,
and `browser-auth`. `sso` also needs `--auth-tenant <tenant>`. Add
`--headless-mode` where no browser is available. `api-key` is not an auth mode:
API-key access is configured through `ENDOR_API_CREDENTIALS_KEY` and
`ENDOR_API_CREDENTIALS_SECRET` instead.

Region affects the API and application hosts only. The binary download and
checksum endpoints serve an identical artifact from either host, so an existing
install needs no change when the region is corrected. An EU user whose egress
policy blocks the US host can substitute `api.eu.endorlabs.com` in the
[no-admin install](#no-admin-install) URLs.

### No Tenant Namespace After Authentication

If authentication completes but no tenant namespace is returned — an empty
namespace list, a namespace prompt with no choices, or verified auth that then
fails every namespace-scoped lookup — treat the region as the first suspect,
not the credentials. Report it as a distinct outcome rather than a generic auth
failure, and walk these steps in order:

1. State the endpoint currently in use and the region it implies.
2. Ask the user to confirm which application URL they sign in to. If they sign
   in at `https://app.eu.endorlabs.com` but the endpoint is
   `https://api.endorlabs.com`, that mismatch is the likely cause.
3. Offer to re-run authentication against the other region with an explicit
   `--api`, and ask before changing a stored `ENDOR_API`.
4. If the region is confirmed correct and there is still no namespace, stop
   guessing. The account most likely has no tenant membership or has not been
   invited. Tell the user to check the namespace in the top left of the Endor
   Labs application under the logo, and to contact Endor Labs support or their
   internal Endor administrator for tenant access.
5. Record `unavailable:tenant_namespace` in `data_gaps` and do not proceed to
   live Endor lookups.

Never report this state as success, and never substitute a guessed namespace,
`oss`, or a namespace from a previous session.

## Licensed Features

Which Endor capabilities a tenant may use is decided by its licence, not by
local configuration. Read it from the `EndorLicense` resource:

```
endorctl agent api --agent-id endor-agent-kit-setup list -r EndorLicense -n <namespace> --field-mask "spec.type,spec.target_namespace,spec.license_info.type,spec.bundle_info.type" --page-size 1 -o json
```

`spec.license_info[].type` is the authoritative per-feature list, as
`ENDOR_LICENSE_FEATURE_TYPE_*` values. Report from that list. Do not derive
capability from `spec.bundle_info[]`: bundles are commercial packaging, and a
bundle such as `ENDOR_LICENSE_BUNDLE_TYPE_CODE_PRO` already carries the Code
Core features, so mapping bundle names to capabilities will misreport.

Features that gate bundled workflows:

| Capability | Licence feature |
| --- | --- |
| Endor SAST (`--sast`) | `ENDOR_LICENSE_FEATURE_TYPE_SAST` |
| AI SAST (`--ai-sast`) | `ENDOR_LICENSE_FEATURE_TYPE_AI_SAST` |
| Secret scanning (`--secrets`) | `ENDOR_LICENSE_FEATURE_TYPE_SECRETS` |
| Package Firewall | `ENDOR_LICENSE_FEATURE_TYPE_PACKAGE_FIREWALL` |
| Dependency scanning | `ENDOR_LICENSE_FEATURE_TYPE_SCA` |
| Container scanning | `ENDOR_LICENSE_FEATURE_TYPE_CONTAINER_SCAN` |

Each entry carries an `expiration_time`; treat a feature whose expiry has
passed as not licensed. The query works from a child namespace and resolves to
the owning tenant, reported as `spec.target_namespace`. A 403 means the
credential cannot read licences for that namespace — report that as a gap
rather than as an absence of features.

Report licensed features by name in the readiness report. They are not secrets.
If the lookup fails, record `unavailable:license_lookup` and say that
entitlement is unknown, rather than implying a feature is missing.

## Readiness Report

Start with a concise readiness report. Separate configured state from verified
state.

Include these sections when relevant:

- Ready
- Needs action
- Optional checks
- Available fixes

Include a hook line alongside the tooling lines, for example
`Dependency hook: hooks.json present, surface supports hooks` or
`Dependency hook: present, surface does not run hooks — reminder unavailable`.

For Endor auth, report sanitized fields only:

```text
Endor config: found
API endpoint: https://api.endorlabs.com (US, default) from ~/.endorctl/config.yaml
Region: US — sign-in at https://app.endorlabs.com
Namespace candidates:
- ENDOR_NAMESPACE: not set
- ~/.endorctl/config.yaml ENDOR_NAMESPACE: example-namespace
Selected namespace: example-namespace from ~/.endorctl/config.yaml
Auth: API credential fields present
Endor auth: verified for namespace example-namespace
Licence: ENDOR_LICENSE_TYPE_PREMIUM for tenant example-tenant
Licensed features: SAST, AI_SAST, SECRETS, SCA, PACKAGE_FIREWALL, CONTAINER_SCAN
Secret values: hidden
```

An EU tenant reports `https://api.eu.endorlabs.com (EU)` and
`https://app.eu.endorlabs.com` on those two lines. When no endpoint is
configured, say so and ask for the region rather than printing the default as
though it were a verified choice.

If a namespace is missing, say that a namespace is required before live Endor
lookups. If a namespace is detected, let the user use it or override it for the
current workflow. If authentication succeeded but produced no tenant namespace
at all, follow [No Tenant Namespace After Authentication](#no-tenant-namespace-after-authentication)
before anything else — the usual cause is the wrong region, not bad credentials.

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

`endorctl` is the single prerequisite for this plugin: every workflow reads
Endor evidence by invoking that binary directly. `npx`, `npm exec`,
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

When browser or SSO authentication is requested, confirm the region and the
namespace first, and pass the region explicitly with `--api` when it is not the
US default. Use non-interactive flags where supported. If multi-tenant selection
appears, summarize the available tenant choices and ask the user before
retrying. If no tenant choices appear at all, follow
[No Tenant Namespace After Authentication](#no-tenant-namespace-after-authentication).

## Endor CLI API Access

Require `endorctl agent api --agent-id endor-agent-kit-setup --help` to succeed
for workflows that use Endor CLI API calls. Probe it with that `--agent-id`
rather than bare `--help`: hosts that enforce agent attribution reject an
`endorctl agent api` invocation with an empty `--agent-id`, so a bare `--help`
probe reports a readiness failure that is not real. Each selected workflow must pass its canonical recipe id through
`--agent-id`; never fall back to the unattributed legacy API command.

This plugin ships no MCP server. Every workflow reads Endor evidence through
`endorctl agent api --agent-id <canonical-recipe-id>`, so `endorctl` on PATH
plus working authentication is the whole requirement. If a host already has an
Endor MCP server registered from some other source, treat it as pre-existing
host configuration: report it, do not depend on it, and do not start, register,
or remove it.

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
- Do not add plugin-wide MCP. This plugin ships no MCP server; if a host has one registered from another source, report it and leave it alone.
- Do not collect, write, or persist Endor API credential values. Report credential presence by key name only.
- Invoke workflow custom agents from the agent picker; do not invent alternate invocation names.
- Copilot custom agents are host-managed; if a custom agent is unavailable, use the matching skill and report the limitation.
- Tell the user to reload the window / restart the Copilot surface after installing or updating the plugin if new skills or agents are not visible.
