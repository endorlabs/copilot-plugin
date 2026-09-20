#!/bin/sh
# Endor Labs Agent Kit - PostToolUse dependency-introduction reminder.
#
# VS Code ignores hook matcher values, so this script runs after EVERY tool call
# and must filter itself. Keep the early exits cheap.
#
# It never blocks. A false positive costs one extra sentence of context; a false
# negative lets an unchecked dependency through, so the match is deliberately
# generous.
#
# POSIX sh + grep only - no jq, node, python, or npx, matching the plugin's
# "endorctl is the only prerequisite" contract. The Windows path uses
# dependency-introduction.ps1 instead, and the two pattern sets are kept
# identical.

payload=$(cat 2>/dev/null) || exit 0
[ -n "$payload" ] || exit 0

# 1. Only tools that write files or run commands.
#    VS Code sends camelCase tool names, Claude Code sends snake_case.
printf '%s' "$payload" | grep -qiE '"(tool_name|toolName)"[[:space:]]*:[[:space:]]*"(edit|write|multi_?edit|apply_?patch|create_?file|editfiles|bash|runcommands|run_?in_?terminal)' || exit 0

# 2. A dependency manifest or lock file, covering every ecosystem Endor resolves.
#    Bare-word filenames (WORKSPACE, Gemfile, Podfile, Pipfile) are anchored to a
#    path separator or quote so identifiers like GITHUB_WORKSPACE do not match.
manifests='pom\.xml'
manifests="$manifests|build\.gradle(\.kts)?|build\.sbt"
manifests="$manifests|([/\\\\\"])(WORKSPACE|MODULE\.bazel|BUILD\.bazel)\""
manifests="$manifests|go\.(mod|sum)"
manifests="$manifests|Cargo\.(toml|lock)"
manifests="$manifests|package\.json|package-lock\.json|pnpm-lock\.yaml|yarn\.lock|rush\.json"
manifests="$manifests|requirements[A-Za-z0-9_.-]*\.txt|setup\.(py|cfg)|pyproject\.toml"
manifests="$manifests|poetry\.lock|pdm\.lock|uv\.lock"
manifests="$manifests|([/\\\\\"])Pipfile(\.lock)?\""
manifests="$manifests|[A-Za-z0-9_.-]+\.csproj|packages\.lock\.json|project\.assets\.json|[A-Za-z0-9_.-]+\.props"
manifests="$manifests|([/\\\\\"])Gemfile(\.lock)?\"|[A-Za-z0-9_.-]+\.gemspec"
manifests="$manifests|([/\\\\\"])Podfile(\.lock)?\"|Package\.swift"
manifests="$manifests|composer\.(json|lock)"
manifests="$manifests|conanfile\.(txt|py)|conan\.lock"

# 3. Package-manager commands that add or resolve dependencies without the agent
#    editing a manifest itself.
installs='(npm|pnpm|yarn|bun)[[:space:]]+(i|install|ci|add|update)'
installs="$installs|rush[[:space:]]+(add|update|install)"
installs="$installs|pip[23]?[[:space:]]+install|pipenv[[:space:]]+(install|update)"
installs="$installs|poetry[[:space:]]+(add|install|update)|pdm[[:space:]]+(add|install|sync|update)"
installs="$installs|uv[[:space:]]+(add|sync|lock|pip[[:space:]]+install)"
installs="$installs|cargo[[:space:]]+(add|install|update)"
installs="$installs|go[[:space:]]+get|go[[:space:]]+mod[[:space:]]+(tidy|download)"
installs="$installs|gem[[:space:]]+install|bundle[[:space:]]+(add|install|update)"
installs="$installs|composer[[:space:]]+(require|install|update)"
installs="$installs|dotnet[[:space:]]+(add[[:space:]]+[^[:space:]]+[[:space:]]+package|add[[:space:]]+package|restore)"
installs="$installs|nuget[[:space:]]+(install|restore)"
installs="$installs|(pod|swift[[:space:]]+package)[[:space:]]+(install|update|resolve)"
installs="$installs|conan[[:space:]]+install"
installs="$installs|mvn[[:space:]]+[^\"]*dependency|gradle[[:space:]]+[^\"]*dependencies"
installs="$installs|bazel[[:space:]]+(sync|fetch|mod[[:space:]]+deps)"

printf '%s' "$payload" | grep -qE "$manifests|$installs" || exit 0

cat <<'JSON'
{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"A dependency manifest or lock file changed, or a package-manager install ran. Before reporting this change as done, check each newly added or upgraded dependency against Endor Labs using the Dependency Introduction Check rule: resolve the exact coordinate to a PackageVersion, then list the Findings targeting its uuid. Malware (FINDING_CATEGORY_MALWARE) outranks every severity. Report severity together with reachability, and never report an unknown or failed lookup as clean. If these dependencies were already checked earlier in this session, say so and move on."}}
JSON
exit 0
