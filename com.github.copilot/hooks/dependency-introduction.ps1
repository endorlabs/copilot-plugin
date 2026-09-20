# Endor Labs Agent Kit - PostToolUse dependency-introduction reminder (Windows).
#
# VS Code ignores hook matcher values, so this runs after EVERY tool call and
# must filter itself. Keep the early exits cheap.
#
# It never blocks. A false positive costs one extra sentence of context; a false
# negative lets an unchecked dependency through, so the match is deliberately
# generous.
#
# Windows PowerShell only - no jq, node, python, or npx, matching the plugin's
# "endorctl is the only prerequisite" contract. Pattern set is kept identical to
# dependency-introduction.sh.

$ErrorActionPreference = 'SilentlyContinue'

$payload = [Console]::In.ReadToEnd()
if ([string]::IsNullOrWhiteSpace($payload)) { exit 0 }

# 1. Only tools that write files or run commands.
#    VS Code sends camelCase tool names, Claude Code sends snake_case.
$toolPattern = '"(tool_name|toolName)"\s*:\s*"(edit|write|multi_?edit|apply_?patch|create_?file|editfiles|bash|runcommands|run_?in_?terminal)'
if ($payload -notmatch $toolPattern) { exit 0 }

# 2. A dependency manifest or lock file, covering every ecosystem Endor resolves.
#    Bare-word filenames (WORKSPACE, Gemfile, Podfile, Pipfile) are anchored to a
#    path separator or quote so identifiers like GITHUB_WORKSPACE do not match.
$manifests = @(
  'pom\.xml',
  'build\.gradle(\.kts)?', 'build\.sbt',
  '([/\\"])(WORKSPACE|MODULE\.bazel|BUILD\.bazel)"',
  'go\.(mod|sum)',
  'Cargo\.(toml|lock)',
  'package\.json', 'package-lock\.json', 'pnpm-lock\.yaml', 'yarn\.lock', 'rush\.json',
  'requirements[A-Za-z0-9_.-]*\.txt', 'setup\.(py|cfg)', 'pyproject\.toml',
  'poetry\.lock', 'pdm\.lock', 'uv\.lock',
  '([/\\"])Pipfile(\.lock)?"',
  '[A-Za-z0-9_.-]+\.csproj', 'packages\.lock\.json', 'project\.assets\.json', '[A-Za-z0-9_.-]+\.props',
  '([/\\"])Gemfile(\.lock)?"', '[A-Za-z0-9_.-]+\.gemspec',
  '([/\\"])Podfile(\.lock)?"', 'Package\.swift',
  'composer\.(json|lock)',
  'conanfile\.(txt|py)', 'conan\.lock'
) -join '|'

# 3. Package-manager commands that add or resolve dependencies without the agent
#    editing a manifest itself.
$installs = @(
  '(npm|pnpm|yarn|bun)\s+(i|install|ci|add|update)',
  'rush\s+(add|update|install)',
  'pip[23]?\s+install', 'pipenv\s+(install|update)',
  'poetry\s+(add|install|update)', 'pdm\s+(add|install|sync|update)',
  'uv\s+(add|sync|lock|pip\s+install)',
  'cargo\s+(add|install|update)',
  'go\s+get', 'go\s+mod\s+(tidy|download)',
  'gem\s+install', 'bundle\s+(add|install|update)',
  'composer\s+(require|install|update)',
  'dotnet\s+(add\s+[^\s]+\s+package|add\s+package|restore)',
  'nuget\s+(install|restore)',
  '(pod|swift\s+package)\s+(install|update|resolve)',
  'conan\s+install',
  'mvn\s+[^"]*dependency', 'gradle\s+[^"]*dependencies',
  'bazel\s+(sync|fetch|mod\s+deps)'
) -join '|'

if ($payload -notmatch "$manifests|$installs") { exit 0 }

$context = 'A dependency manifest or lock file changed, or a package-manager install ran. ' +
  'Before reporting this change as done, check each newly added or upgraded dependency against ' +
  'Endor Labs using the Dependency Introduction Check rule: resolve the exact coordinate to a ' +
  'PackageVersion, then list the Findings targeting its uuid. Malware (FINDING_CATEGORY_MALWARE) ' +
  'outranks every severity. Report severity together with reachability, and never report an ' +
  'unknown or failed lookup as clean. If these dependencies were already checked earlier in this ' +
  'session, say so and move on.'

$out = [ordered]@{
  hookSpecificOutput = [ordered]@{
    hookEventName     = 'PostToolUse'
    additionalContext = $context
  }
}

$out | ConvertTo-Json -Depth 4 -Compress
exit 0
