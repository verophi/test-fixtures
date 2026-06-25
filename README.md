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
├── renovate.json   # allowedVersions caps for deterministic PRs
├── test-cases.md   # documented test & edge cases
└── packages/       # 12 ecosystems
```

## Expected outcomes

The authoritative expected outcome (scores, status, CVE correlation) lives in
`verophi-inttest/expectations.yaml`, generated from a verified verophi run
against the open PRs/MRs and the frozen SBOM. See `test-cases.md` for the
documented cases. Re-generate and review the diff when changing fixtures.

## Renovate

`renovate.json` caps versions via `allowedVersions` so PRs are deterministic.
The inttest orchestrates Renovate runs; this repo has no automation.

## Adding a package

1. Package manifest under `packages/<ecosystem>/`
2. Lock file if applicable
3. `packageRule` in `renovate.json` (cap the version for determinism)
4. Re-generate `verophi-inttest/expectations.yaml` and review the diff
5. Verify via dry-run in verophi-inttest
