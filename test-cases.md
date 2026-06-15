# Test Cases — verophi E2E Fixtures

Last updated: 2026-06-14.

This document describes the test and edge cases the fixture repo covers. Each
case is driven by manifests under `packages/<ecosystem>/` and the `renovate.json`
configuration. The authoritative expected outcome (scores, status, CVE
correlation) lives in `verophi-inttest/expectations.yaml`, generated from a
verified verophi run against the open MRs/PRs and the frozen SBOM. GitLab and
GitHub are semantically identical (only request numbers and URLs differ).

Current state: 39 open requests per platform — 22 matched, 16 unmatched,
1 unparsed.

---

## Change-type cases

### Patch / Minor / Major (separateMajorMinor)
Single updates with the correct change type and risk.
- **patch:** actionpack (6.1.4→6.1.7.8, 8 CVEs), python-multipart (0.0.5→0.0.18),
  System.Text.Json (6.0.0→6.0.11).
- **minor:** express, golang.org/x/net, golang.org/x/crypto, gin, log4j-core,
  tokio, guzzlehttp/guzzle, phoenix, swift-nio-http2.
- **major:** Pillow, PyYAML, Newtonsoft.Json, System.Text.Json, dio.
  `separateMajorMinor` yields two requests each (e.g. Pillow v9.5.0 + v10,
  System.Text.Json 6.0.11 + v8).

### Pin (rangeStrategy pin)
- **json5** `^2.2.1 → 2.2.3` (changeType `pin`, risk 1) inside the
  `pin dependencies` request. No CVE → unmatched. Exercises `pin` separately from
  `pinDigest`.

### pinDigest (Docker SHA pin)
- **node** (`20-alpine`, Docker) is pinned to a digest within the same
  `pin dependencies` request. changeType `pinDigest` (risk 1). The target is a SHA
  (`→ fb4cd12`), not a version bump; the parser recognizes the row as pinDigest
  instead of dropping it. No scoring impact (Docker, no SBOM coverage, no CVE).

### Rollback
- **left-pad** is declared at `>=2.0.0` (no such version exists), so Renovate rolls
  back to `1.3.0` (changeType `rollback`, risk 3). Requires the `left-pad@1.3.0`
  entry injected into the lockfile, otherwise Renovate autocloses the request.

### Replacement (unknown risk)
- **xmldom → @xmldom/xmldom 0.8.10** (changeType `replacement`, risk 0). RiskTier
  collapses to `unknown`, `hasUnknownRisk: true`, VME `null`. The xmldom CVEs have
  no recommendation → uncorrelated, despite the replacement.

### Bump (label)
- **chalk** `4.1.0 → 4.1.2`: Renovate emits `updateType: patch` in the table; the
  `bump` label (via packageRule) marks the request for future parser support.
  No CVE → unmatched.

### lockFileMaintenance (unparsed)
- A dedicated `lock file maintenance` request with no version table → status
  `unparsed` (no change extractable). Enabled only for
  `packages/lockfile-maintenance/**`.

---

## Grouping cases

### Explicit group (groupName) — http-client-group
Three npm packages in one branch; exercises multi-row table parsing.
- axios 0.21.1→0.21.4 (patch, CVE-2021-3749), tough-cookie 4.1.2→4.1.3 (patch,
  CVE-2023-26136), semver 7.3.7→7.5.2 (minor, CVE-2022-25883). All fully
  addressed → CR-VIS 16.

### Mixed-type group + SplitCandidate — split-candidate-group
- **minimist** (patch, CVE-2021-44906 critical, single occurrence → fully
  addressed, VIS 8) + **ws** (major, no CVE, VIS 0) in one group. RiskTier =
  major(3), CR-VIS 8, CR-VME 2.67. **minimist is the SplitCandidate** (share 1.0,
  child VME 8.0): a hint to merge the low-risk child on its own.

### Implicit monorepo grouping
- **lodash** runs standalone (branch `renovate/lodash-monorepo`), capped at
  `<=4.17.21`. Fixes only the lodash occurrence of CVE-2021-23337 + CVE-2020-28500.

---

## Correlation edge cases

### Partially addressed (multi-occurrence, not fully covered)
- **CVE-2021-23337** and **CVE-2020-28500** affect lodash AND lodash-es. lodash is
  fixed, **lodash-es is disabled** (no request) → both advisories
  `addressedOccurrences: 1/2`, uncorrelated. They do not count toward CR-VIS or
  reducible.

### Collectively reducible (multi-occurrence, jointly covered)
- **CVE-2023-44487** affects golang.org/x/net AND apple/swift-nio-http2. Neither
  request fixes the advisory alone (1/2 each), so both contribute 0 to CR-VIS — but
  together they cover all occurrences → counts toward `reducible`. Output shows
  `needs <other> to fully fix CVE-2023-44487` on both.

### target < fix (not fixed)
- **dio** patch (4.0.0→4.0.6): CVE-2021-31402 is fixed only in 5.0.0; target 4.0.6
  < 5.0.0 → not fixed → unmatched. The dio major request (→5.0.0) fixes it.

### No advisory in the SBOM
- **rustls** (0.20.8→0.21.11): no Trivy advisory in the SBOM → unmatched.

### No SBOM coverage (Docker)
- **nginx** (1.24-alpine→1.25-alpine) and **node** (20-alpine→24-alpine): Docker,
  unknown ecosystem → no version comparison → unmatched. Labeled
  `no-sbom-coverage` (the rule targets the `docker` datasource only — **not**
  github-tags, since Swift packages like swift-nio-http2 are in the SBOM).

---

## Identity / normalization cases

- **PEP 503** (Python): case-insensitivity (Pillow vs pillow) and separator
  equivalence (python-multipart vs python_multipart).
- **Maven group:artifact**: `org.apache.logging.log4j:log4j-core` resolved via the
  occurrence PURL coordinate (groupId disambiguates).
- **Swift repo shorthand**: `apple/swift-nio-http2` (Renovate) vs full module path
  `github.com/apple/swift-nio-http2` (SBOM).
- **Go v-prefix**: SBOM `v0.16.0` vs Renovate recommendation bare `0.17.0`.
- **NuGet / Composer**: best-effort comparator (generic go-version library).

---

## All requests

| Package | Ecosystem | From | To | Type | Status | Note |
|---|---|---|---|---|---|---|
| actionpack | gem | 6.1.4 | 6.1.7.8 | patch | matched | 8 CVEs, VIS 30 |
| Pillow | pip | 9.0.0 | 9.5.0 | minor | matched | PEP503; VIS 20 |
| Pillow | pip | 9.0.0 | 10.2.0 | major | matched | VIS 36 |
| PyYAML | pip | 5.3.1 | 5.4.1 | minor | matched | VIS 8 |
| PyYAML | pip | 5.3.1 | 6.0 | major | matched | VIS 8 |
| python-multipart | pip | 0.0.5 | 0.0.18 | patch | matched | PEP503; VIS 8 |
| log4j-core | maven | 2.14.1 | 2.17.1 | minor | matched | group:artifact; VIS 32 |
| golang.org/x/net | go | 0.16.0 | 0.33.0 | minor | matched | joint 44487; VIS 8 |
| golang.org/x/crypto | go | 0.16.0 | 0.31.0 | minor | matched | VIS 10 |
| gin | go | 1.7.0 | 1.9.1 | minor | matched | VIS 10 |
| guzzlehttp/guzzle | composer | 7.4.0 | 7.8.0 | minor | matched | best-effort; VIS 20 |
| phoenix | hex | 1.6.0 | 1.7.0 | minor | matched | VIS 4 |
| tokio | cargo | 1.17.0 | 1.27.0 | minor | matched | VIS 3 |
| Newtonsoft.Json | nuget | 12.0.3 | 13.0.3 | major | matched | best-effort; VIS 4 |
| System.Text.Json | nuget | 6.0.0 | 6.0.11 | patch | matched | VIS 4 |
| System.Text.Json | nuget | 6.0.0 | 8.0.5 | major | matched | VIS 4 |
| express | npm | 4.17.1 | 4.21.0 | minor | matched | VIS 6 |
| http-client-group | npm | — | — | grouped | matched | axios+semver+tough-cookie; VIS 16 |
| split-candidate-group | npm | — | — | grouped | matched | minimist+ws; SplitCandidate=minimist; VIS 8 |
| lodash | npm | 4.17.20 | 4.17.21 | patch | matched | partial (lodash-es open); VIS 0 |
| dio | pub | 4.0.0 | 5.0.0 | major | matched | fixes CVE-2021-31402; VIS 4 |
| swift-nio-http2 | swift | 1.25.0 | 1.28.0 | minor | matched | joint 44487; VIS 0 |
| dio | pub | 4.0.0 | 4.0.6 | patch | unmatched | target < fix 5.0.0 |
| rustls | cargo | 0.20.8 | 0.21.11 | minor | unmatched | no advisory |
| chalk | npm | 4.1.0 | 4.1.2 | patch | unmatched | bump label |
| json5 | npm | ^2.2.1 | 2.2.3 | pin | unmatched | in pin-dependencies request |
| node | docker | 20-alpine | (digest) | pinDigest | unmatched | in pin-dependencies request |
| left-pad | npm | 2.0.0 | 1.3.0 | rollback | unmatched | rollbackPrs |
| xmldom | npm | 0.6.0 | 0.8.10 | replacement | unmatched | unknown risk, VME null |
| nginx | docker | 1.24-alpine | 1.25-alpine | minor | unmatched | no-sbom-coverage |
| node | docker | 20-alpine | 24-alpine | major | unmatched | no-sbom-coverage |
| esbuild, ex_doc, gettext (×2), phoenix_html, phoenix_view, plug_crypto, telemetry_metrics | hex/npm | — | — | minor/major | unmatched | Elixir/JS extras without an advisory |
| (lock file maintenance) | — | — | — | — | unparsed | no version table |

Not disabled but with no open request: **requests** (pip, capped `<=2.32.0`); its
CVEs appear as uncorrelated. **lodash-es** is intentionally disabled (it drives the
partially-addressed case).

---

## Not covered (Phase 2 / not constructible)

| Case | Status |
|---|---|
| Digest update with a CVE | Not constructible: `trivy fs` does not scan base images, and image CVEs would carry a different identity than the image name. |
| Plain `digest` (vs pinDigest) | No fixture; only pinDigest is present. |
| `unparsedDeps > 0` | No fixture row that is recognized by name but fails to parse. |
| Custom branchPrefix (`deps/`) | Branch-parsing question, open. |
| Title fallback (PR without description) | Requires manual PRs after a remote push. |
| Two-manifest collapse of one dep | Treated conservatively as unknown; no dedicated fixture case. |
