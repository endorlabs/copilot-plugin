---
name: 'Dependency Introduction Check'
description: 'Check newly added or upgraded dependencies for vulnerabilities and malware before reporting the change as done'
applyTo: '**/pom.xml,**/build.gradle,**/build.gradle.kts,**/build.sbt,**/WORKSPACE,**/MODULE.bazel,**/BUILD.bazel,**/go.mod,**/go.sum,**/Cargo.toml,**/Cargo.lock,**/package.json,**/package-lock.json,**/pnpm-lock.yaml,**/yarn.lock,**/rush.json,**/requirements*.txt,**/setup.py,**/setup.cfg,**/pyproject.toml,**/poetry.lock,**/pdm.lock,**/uv.lock,**/Pipfile,**/Pipfile.lock,**/*.csproj,**/packages.lock.json,**/project.assets.json,**/*.props,**/Gemfile,**/Gemfile.lock,**/*.gemspec,**/Podfile,**/Podfile.lock,**/Package.swift,**/composer.json,**/composer.lock,**/conanfile.txt,**/conanfile.py,**/conan.lock'
---

# Dependency Introduction Check

When a dependency is added, or its version is raised, in any manifest or lock
file, check it against Endor Labs before reporting the edit as done. This
applies to dependencies you introduce yourself and to ones introduced by a
package-manager command you ran.

Covered manifests, matching what Endor resolves:

| Ecosystem | Manifests |
| --- | --- |
| Java / Kotlin / Scala | `pom.xml`, `build.gradle`, `build.gradle.kts`, `build.sbt` |
| Bazel (Java, Go, Python, Scala) | `WORKSPACE`, `MODULE.bazel`, `BUILD.bazel` |
| Go | `go.mod`, `go.sum` |
| Rust | `Cargo.toml`, `Cargo.lock` |
| JavaScript / TypeScript | `package.json`, `package-lock.json`, `pnpm-lock.yaml`, `yarn.lock`, `rush.json` |
| Python | `requirements*.txt`, `setup.py`, `setup.cfg`, `pyproject.toml`, `poetry.lock`, `pdm.lock`, `uv.lock`, `Pipfile`, `Pipfile.lock` |
| .NET / C# | `*.csproj`, `packages.lock.json`, `project.assets.json`, `Directory.Build.props`, `Directory.Packages.props`, `*.props` |
| Ruby | `Gemfile`, `Gemfile.lock`, `*.gemspec` |
| Swift / Objective-C | `Podfile`, `Podfile.lock`, `Package.swift` |
| PHP | `composer.json`, `composer.lock` |
| C / C++ | `conanfile.txt`, `conanfile.py`, `conan.lock` |

The equivalent package-manager commands count too: `npm`/`pnpm`/`yarn`/`bun`/`rush`,
`pip`/`pipenv`/`poetry`/`pdm`/`uv`, `cargo`, `go get`, `go mod tidy`, `gem`/`bundle`,
`composer`, `dotnet add package`/`dotnet restore`/`nuget`, `pod install`,
`swift package resolve`, `conan install`, and Bazel dependency syncs.

Check the exact coordinate in two reads. Vulnerabilities and malware come back
together, which is why this is preferred over a vulnerability-only lookup:

```
endorctl agent api --agent-id dependency-reviewer list -r PackageVersion -n oss --filter 'meta.name=="<PACKAGE_URL_PREFIX>://<PACKAGE_NAME>@<VERSION>"' --field-mask "uuid,meta.name,spec.ecosystem" --page-size 1 -o json
```

```
endorctl agent api --agent-id dependency-reviewer list -r Finding -n oss --filter 'spec.target_uuid=="<PACKAGE_VERSION_UUID>"' --field-mask "uuid,meta.name,spec.level,spec.finding_categories,spec.finding_tags" --page-size 25 -o json
```

Reporting rules:

- A Finding whose `spec.finding_categories` contains `FINDING_CATEGORY_MALWARE`
  is malware. It outranks every severity. Say so first and recommend removing
  the dependency, not upgrading it.
- Report `spec.level` and reachability together. A critical unreachable
  vulnerability is lower priority than a high reachable one. Reachability is
  `FINDING_TAGS_REACHABLE_FUNCTION` in `spec.finding_tags` when present; if the
  tag is absent, say reachability is unknown rather than implying unreachable.
- Say whether the dependency is direct or transitive.
- Distinguish "no findings returned" (the package is known to Endor and clean)
  from "no PackageVersion record" (Endor has never seen this coordinate) and
  from "the query failed". Never report an unknown or failed lookup as clean.
- Resolve an exact version first. Do not send a range, a tag, or a guess. If the
  manifest pins a range, read the lock file for the resolved version, and say
  so if no lock file is present.
- Always scope by namespace and by `spec.target_uuid`. An unscoped Findings
  list against a large namespace will exceed the request deadline.

For a fuller review — package health, licence, upgrade paths, whole-repository
inventory — use the `dependency-reviewer` skill or custom agent instead.
