# Endor Labs Agent Kit Copilot Agent Plugin

Version: `3.0.0`

An Agent Plugins 1.0 bundle of Endor Labs security workflows: portable Agent
Skills, plus Copilot custom agents, rules, and hooks. It installs into GitHub
Copilot — no `.vsix` and no VS Code Marketplace.

**3.0.0 removes the MCP server.** Every workflow now reads Endor evidence
through `endorctl agent api --agent-id <id>`, so `endorctl` on PATH is the whole
dependency. See [Retiring The MCP Server](#retiring-the-mcp-server).

## Start Here

| Reader | First move |
| --- | --- |
| Human installer | Install the plugin from this Git repo or a local checkout, then ask Copilot to use the `endor-agent-kit-setup` skill. |
| Agent installer | Do not broaden tool permissions, change the logo, or add a plugin-wide MCP server without the user's approval. |

Content releases require a package version bump. If a host still shows old
prompt content after reinstalling the same version, remove or reinstall the
plugin, clear the host cache when supported, and start a fresh host session.

## Host Support

| Component | Where it works |
| --- | --- |
| `skills/<id>/SKILL.md` | Any Agent-Plugins-capable host. Host-neutral by design. |
| `com.github.copilot/agents/<id>.agent.md` | VS Code only — each agent sets `target: vscode`. |
| `com.github.copilot/rules/` | Copilot rules and instructions. |
| `com.github.copilot/hooks/hooks.json` | Copilot agent hooks. Preview; VS Code and Copilot CLI. |
| `.github/plugin/marketplace.json` | Lets the Copilot app and CLI add this repo as a marketplace. |

The custom agents are VS Code-specific. On the Copilot CLI and the Copilot app,
use the matching skill of the same name instead; the skills carry the same
workflow contract.

The Copilot app installs plugins only from a marketplace, so this repo ships
its own manifest at `.github/plugin/marketplace.json` — one of the four
locations a host searches (`marketplace.json`, `.plugin/marketplace.json`,
`.github/plugin/marketplace.json`, `.claude-plugin/marketplace.json`). The
entry's `source` names this repo with no `path`, which is how a marketplace
points at a plugin whose `plugin.json` is at the repository root.

## Requirements

`endorctl` on PATH is the only prerequisite. Every workflow invokes that binary
directly — there is no MCP server and no other runtime.

There is deliberately **no** dependency on Node, `npx`, Python, `jq`, or any
other interpreter or Unix tool in the workflows themselves. Every workflow reduces results server-side with
`endorctl` flags (`--field-mask`, `--count`, `--group-aggregation-paths`,
`--page-size`), so nothing needs local post-processing. This is what lets the
plugin work unchanged in PowerShell on Windows.

If `endorctl` is missing, the setup skill can guide a checksum-verified download
into a user-controlled directory on PATH — no administrator rights and no
package manager required.

Agent frontmatter omits `model`, so Copilot uses whatever the agent-mode model
picker has selected.

## Install

This repository is both the plugin and a single-entry plugin marketplace, so
every Copilot surface has a working route. `plugin.json` sits at the repo root
and `.github/plugin/marketplace.json` lists it.

**Copilot app** — the app installs plugins only from a marketplace; it has no
install-from-source route. Add this repo as a marketplace source:

```text
endorlabs/copilot-plugin
```

then install **endor-labs-agent-kit** from it. If the app reports
`File not found: marketplace.json, .plugin/marketplace.json, ...`, it is
looking at a repo with no marketplace manifest — check the source spelling.

**Copilot CLI** — either route works:

```bash
copilot plugin marketplace add endorlabs/copilot-plugin
```

```bash
copilot plugin install endorlabs/copilot-plugin
```

**VS Code** — Command Palette -> `Chat: Install Plugin From Source`, pointed at
this repository, or register a local checkout in settings:

```json
"chat.pluginLocations": { "C:\\src\\copilot-plugin": true, "/path/to/copilot-plugin": true }
```

Reload the window or restart the Copilot surface after installing so the
skills, agents, rules, and hooks become visible. Installed plugins appear under
**Agent Plugins - Installed**.

To offer the plugin org-wide without each developer adding the marketplace by
hand, add it to `extraKnownMarketplaces` in `.github/copilot/settings.json`, or
to `managed-settings.json` for enterprise-managed installs.

### Releasing

The marketplace entry's `source` pins no `ref` or `sha`, so it tracks the
default branch. Keep three values in step on every release — `version` in
`plugin.json`, `version` in `.github/plugin/marketplace.json`, and the
`Version:` line above — and add a `"ref": "v<version>"` to the marketplace
`source` once you start tagging releases, so installs stop following `main`.

## Set Up This Machine

Ask Copilot:

```text
Use the endor-agent-kit-setup skill to check Endor Agent Kit readiness.
```

The setup skill can guide a no-admin `endorctl` install, ask which Endor region
your tenant is in (US `https://api.endorlabs.com` or EU
`https://api.eu.endorlabs.com`), verify Endor auth and namespace readiness, and
report missing `gh` prerequisites. If authentication succeeds but returns no
tenant namespace, it treats a region mismatch as the first suspect before
blaming credentials. It does not run
scans, run `endorctl host-check`, edit shell profiles, auto-install `gh`, or
install language runtimes and package managers.

## Capabilities And Skills

| Job | Skill | Custom agent | Safety |
| --- | --- | --- | --- |
| AI SAST Remediation | `ai-sast-remediation` | `ai-sast-remediation` | mutating, approval-gated |
| CI/CD And Supply Chain Posture | `cicd-posture` | `cicd-posture` | read-only |
| Configuration Automation | `configuration-automation` | `configuration-automation` | read-only |
| Dependency Reviewer | `dependency-reviewer` | `dependency-reviewer` | read-only |
| Diff Scan (local SAST / AI SAST) | `diff-scan` | `diff-scan` | runs a scan, approval-gated |
| Findings Browser | `findings-browser` | `findings-browser` | read-only |
| Malware Responder | `malware-responder` | `malware-responder` | read-only |
| OSS Upgrade Investigator | `oss-upgrade-investigator` | `oss-upgrade-investigator` | read-only |
| Remediation Planning | `remediation-planning` | `remediation-planning` | read-only |
| SCA Remediation | `sca-remediation` | `sca-remediation` | mutating, approval-gated |
| Troubleshooting | `troubleshooting` | `troubleshooting` | read-only |
| Vulnerability Explainer | `vulnerability-explainer` | `vulnerability-explainer` | read-only |

Mutating workflows keep file edits, branch pushes, PR/MR creation, comments,
approval verification, and Endor policy writes behind separate approval gates.
Setup never performs those workflow actions.

## Boundaries And Rules

- Always run readiness and namespace checks before live Endor lookups.
- Always keep setup, file edits, branch pushes, PR/MR creation, comments, tickets, and policy writes as separate evidence-backed steps.
- Never run setup scans or `endorctl host-check`. Scanning belongs to `diff-scan` alone, behind its approval gate.
- Never auto-install `gh`, language runtimes, or package managers.
- Never print, persist, or copy Endor API key, secret, token, or full config values.
- Never use `npx`, `npm exec`, `pnpm dlx`, or `yarn dlx`.
- Never use `--list-all`; use server-side counts and aggregates instead.

## Rules And Hooks

Two rules files ship in `com.github.copilot/rules/`:

| File | Scope |
| --- | --- |
| `endor-labs-agent-kit.md` | Always on. Capability ladder, cross-platform execution, safety contract, job routing. |
| `dependency-introduction.md` | Path-scoped via `applyTo` to dependency manifests and lock files, across every ecosystem Endor resolves. |

> `applyTo` is documented for `.github/instructions/*.instructions.md` and
> `.claude/rules/*.instructions.md`. Whether a *plugin's* `com.github.copilot/rules/`
> directory honours it is unconfirmed — if a host ignores it, the file loads
> always-on instead, which is why it is kept short.

One hook ships in `com.github.copilot/hooks/`:

| Event | Script | Behaviour |
| --- | --- | --- |
| `PostToolUse` | `dependency-introduction.sh` / `.ps1` | Reminds the agent to check newly added or upgraded dependencies against Endor. Never blocks. |

Manifest coverage matches Endor's own resolution matrix — Maven, Gradle, Bazel,
sbt, Go, Cargo, npm/pnpm/Yarn/Rush, pip/Poetry/PDM/uv/Pipenv, NuGet, Bundler,
CocoaPods, SwiftPM, Composer, and Conan — plus the equivalent package-manager
commands (`dotnet add package`, `pod install`, `conan install`, and the rest),
which catch dependencies added without the agent editing a manifest directly.
The full table is in `com.github.copilot/rules/dependency-introduction.md`.

The hook is the deterministic backstop for the rule above; the rule is the
portable baseline for hosts with no hook support. Three things to know:

- **Hooks are Preview.** The plugin works correctly without them.
- **VS Code ignores hook `matcher` values**, so the script runs after every tool
  call and filters itself on `tool_name`. The early exits are deliberately cheap.
- **Tool property casing differs by host** — VS Code sends camelCase
  (`filePath`), Claude Code sends snake_case (`file_path`). The script matches both.

A POSIX `sh` script runs on macOS and Linux and a PowerShell script on Windows,
selected by the `osx` / `linux` / `windows` keys in `hooks.json`. Neither needs
Node, Python, or `jq`.

## Licensed Features

Which capabilities a tenant may use is decided by its Endor licence. Read it
from the `EndorLicense` resource (`/v1/namespaces/{namespace}/endor-licenses`):

```bash
endorctl agent api --agent-id endor-agent-kit-setup list -r EndorLicense -n <namespace> --field-mask "spec.type,spec.target_namespace,spec.license_info.type" --page-size 1 -o json
```

`spec.license_info[].type` is the authoritative per-feature list, as
`ENDOR_LICENSE_FEATURE_TYPE_*` values — `SAST`, `AI_SAST`, `SECRETS`,
`PACKAGE_FIREWALL`, `SCA`, `CONTAINER_SCAN`, and others, each with an
`expiration_time`.

Read features, not bundles. `spec.bundle_info[]` is commercial packaging and a
bundle such as `ENDOR_LICENSE_BUNDLE_TYPE_CODE_PRO` already carries the Code
Core features, so mapping bundle names to capabilities misreports. The query
works from a child namespace and resolves to the owning tenant, reported as
`spec.target_namespace`; a 403 means the credential cannot read licences there,
which is a gap, not an absence of features.

`diff-scan` gates its SAST and AI SAST modes on this, `endor-agent-kit-setup`
reports it in the readiness report, and `troubleshooting` checks it before
diagnosing a capability as broken.

## Retiring The MCP Server

3.0.0 removes `mcp.json` and the `endor-cli-tools/*` tool grant from every
custom agent. The server was `endorctl ai-tools mcp-server`, which `endorctl`
itself marks *"Currently experimental"*, and only two skills ever used it.

Each MCP tool that was in use has a direct `endorctl` replacement:

| Removed MCP tool | Replacement |
| --- | --- |
| `check_dependency_for_vulnerabilities` | `list -r PackageVersion` on the exact coordinate, then `list -r Finding --filter 'spec.target_uuid=="<uuid>"'` |
| `check_dependency_for_risks` | the same two reads; malware is `FINDING_CATEGORY_MALWARE` in `spec.finding_categories` |
| `get_endor_vulnerability` | `list -r Finding --filter 'spec.finding_metadata.vulnerability.spec.aliases contains ["<CVE_OR_GHSA>"]'`, then read the embedded record |
| `get_resource(Finding, uuid)` | `get -r Finding --uuid <uuid>` |
| `scan`, `security_review` | the `diff-scan` skill, which calls `endorctl scan` directly |

The Endor vulnerability record is **not** a listable resource — `list -r Vulnerability`
fails with `message found in the proto registry is not a manipulable message`.
The full record is instead carried on every Finding that references it, at
`spec.finding_metadata.vulnerability`, and Findings are filterable by that
nested id.

Filter on `spec.aliases`, not `meta.name`. Endor stores the GHSA id as the
record's `meta.name` and lists every id — including the CVE — in
`spec.aliases`, so a CVE filtered against `meta.name` returns nothing even when
the vulnerability is present. The alias list contains the GHSA too, so one
filter serves both id forms.

Scope every read by namespace, and by `spec.target_uuid` or project where the
shape allows it. An unscoped list against a very large namespace will exceed the
request deadline.

If a host already has an Endor MCP server registered from another source, the
plugin leaves it alone and does not depend on it.

## Provider Docs

- https://code.visualstudio.com/docs/agent-customization/agent-plugins
- https://code.visualstudio.com/docs/agent-customization/agent-skills
- https://code.visualstudio.com/docs/copilot/customization/custom-agents
- https://code.visualstudio.com/docs/copilot/customization/hooks
- https://code.visualstudio.com/docs/copilot/customization/custom-instructions
- https://docs.endorlabs.com/scan/ai-sast/
- https://agent-plugins.org/
