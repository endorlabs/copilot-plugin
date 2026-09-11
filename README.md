# Endor Labs Agent Kit Copilot Agent Plugin

Version: `2.3.0`

An Agent Plugins 1.0 bundle of Endor Labs security workflows: portable Agent
Skills, an Endor MCP server, plus Copilot custom agents and repo-wide rules. It
installs into GitHub Copilot — no `.vsix` and no VS Code Marketplace.

## Start Here

| Reader | First move |
| --- | --- |
| Human installer | Install the plugin from this Git repo or a local checkout, then ask Copilot to use the `endor-agent-kit-setup` skill. |
| Agent installer | Do not broaden tool permissions, change the logo, or add plugin-wide MCP without the user's approval. |

Content releases require a package version bump. If a host still shows old
prompt content after reinstalling the same version, remove or reinstall the
plugin, clear the host cache when supported, and start a fresh host session.

## Host Support

| Component | Where it works |
| --- | --- |
| `skills/<id>/SKILL.md` | Any Agent-Plugins-capable host. Host-neutral by design. |
| `mcp.json` (`endor-cli-tools`) | Any host that supports plugin MCP servers. |
| `com.github.copilot/agents/<id>.agent.md` | VS Code only — each agent sets `target: vscode`. |
| `com.github.copilot/rules/` | Copilot repo-wide rules. |
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

`endorctl` on PATH is the only prerequisite. Both the CLI workflows and the
`endor-cli-tools` MCP server run that same binary.

There is deliberately **no** dependency on Node, `npx`, Python, `jq`, or any
other interpreter or Unix tool. Every workflow reduces results server-side with
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
skills, agents, and MCP server become visible. Installed plugins appear under
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

The setup skill can guide a no-admin `endorctl` install, verify Endor auth and
namespace readiness, and report missing `gh` prerequisites. It does not run
scans, run `endorctl host-check`, edit shell profiles, auto-install `gh`, or
install language runtimes and package managers.

## Capabilities And Skills

| Job | Skill | Custom agent | Safety |
| --- | --- | --- | --- |
| AI SAST Remediation | `ai-sast-remediation` | `ai-sast-remediation` | mutating, approval-gated |
| CI/CD And Supply Chain Posture | `cicd-posture` | `cicd-posture` | read-only |
| Configuration Automation | `configuration-automation` | `configuration-automation` | read-only |
| Dependency Reviewer | `dependency-reviewer` | `dependency-reviewer` | read-only |
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
- Never run setup scans or `endorctl host-check`.
- Never auto-install `gh`, language runtimes, or package managers.
- Never print, persist, or copy Endor API key, secret, token, or full config values.
- Never use `npx`, `npm exec`, `pnpm dlx`, or `yarn dlx`.
- Never use `--list-all`; use server-side counts and aggregates instead.

## Provider Docs

- https://code.visualstudio.com/docs/agent-customization/agent-plugins
- https://code.visualstudio.com/docs/agent-customization/agent-skills
- https://code.visualstudio.com/docs/copilot/customization/custom-agents
- https://agent-plugins.org/
