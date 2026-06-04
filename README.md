# verophi test-fixtures

⚠️ Intentionally outdated and vulnerable dependencies. Not a project template.

## What this is

Fixture packages for verophi E2E tests. Renovate runs against this repo,
creates PRs/MRs, and verophi correlates them with CVEs from SBOMs.

Same content on both platforms:
- `github.com/verophi/test-fixtures`
- `gitlab.com/verophi/test-fixtures`

## Structure

```
.
├── renovate.json            # allowedVersions caps
├── dependency-matrix.yaml   # versions, bumps, CVEs (assertion input)
└── packages/                # 12 ecosystems
```

## dependency-matrix.yaml

Assertion input for `verophi-inttest`. Per package: from/to versions,
expected bump type, known CVEs. Update this file first when changing fixtures.

## Renovate

`renovate.json` caps versions via `allowedVersions` so PRs are deterministic.
The inttest orchestrates Renovate runs — this repo has no automation.

## Adding a package

1. Package manifest under `packages/<ecosystem>/`
2. Lock file if applicable
3. Entry in `dependency-matrix.yaml`
4. `packageRule` in `renovate.json`
5. Verify via dry-run in verophi-inttest
