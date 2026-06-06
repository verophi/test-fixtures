# Test Cases — verophi E2E Fixtures

Stand: 6. Juni 2026

Dieses Dokument beschreibt alle Test-Cases die durch das Fixture-Repo abgedeckt werden.
Jeder Case wird durch Packages in der `dependency-matrix.yaml` repräsentiert und durch
die `renovate.json`-Konfiguration gesteuert.

---

## Cases

### Case: Patch-Update mit CVE-Fix

Ein einzelnes Package bekommt ein Patch-Update das eine bekannte CVE fixt.

- **Packages:** lodash (4.17.20→4.17.21), minimist (1.2.5→1.2.6), actionpack (6.1.4→6.1.7.8)
- **Renovate-Verhalten:** Ein Branch pro Package, UpdateType `patch`
- **Assertion:** verophi erkennt CVE-Fix, ordnet Risiko korrekt zu

### Case: Minor-Update

Ein einzelnes Package bekommt ein Minor-Update.

- **Packages:** express (4.17.1→4.21.0), golang.org/x/net, golang.org/x/crypto, gin, log4j-core, rustls, tokio, guzzlehttp/guzzle, phoenix, swift-nio-http2
- **Renovate-Verhalten:** Ein Branch pro Package, UpdateType `minor`
- **Assertion:** verophi unterscheidet Minor von Patch korrekt

### Case: Major-Update (separateMajorMinor)

Ein Package bekommt ein Major-Update. Renovate erzeugt zwei Branches (minor + major).

- **Packages:** PyYAML (5.3.1→6.0), Pillow (9.0.0→10.2.0), Newtonsoft.Json (12.0.3→13.0.3), System.Text.Json (6.0.0→8.0.5), dio (4.0.0→5.0.0)
- **Renovate-Verhalten:** Zwei Branches (z.B. `renovate/pyyaml-5.x` + `renovate/pyyaml-6.x`)
- **Assertion:** verophi findet beide Branches, erkennt Major vs Minor

### Case: Disabled Package

Ein Package ist in renovate.json deaktiviert — es wird kein PR erzeugt.

- **Packages:** requests (Python)
- **Renovate-Verhalten:** Kein Branch, kein PR
- **Assertion:** verophi ignoriert das Package oder meldet "no update available"

### Case: Unfixable CVEs (Cap zu niedrig)

Die erlaubte Version reicht nicht aus um alle CVEs zu fixen.

- **Packages:** lodash (Cap 4.17.21, aber CVE-2025-13465 braucht 4.17.23)
- **Renovate-Verhalten:** Update auf 4.17.21 (maximale erlaubte Version)
- **Assertion:** verophi erkennt dass CVEs trotz Update offen bleiben (`fixed_by_to: false`)

### Case: Monorepo-Gruppierung (implizit)

Renovate erkennt ein Monorepo und gruppiert automatisch.

- **Packages:** lodash (lodash-monorepo), log4j-core (log4j2-monorepo), System.Text.Json (dotnet-monorepo)
- **Renovate-Verhalten:** Branch heißt nach Monorepo, Description-Tabelle kann mehrere Rows haben
- **Assertion:** verophi parst den Monorepo-Branch korrekt

### Case: Docker pinDigest

Ein Docker-Image bekommt ein Digest-Pin (kein Versions-Bump, nur SHA).

- **Packages:** node (Docker, 20-alpine)
- **Renovate-Verhalten:** Branch `renovate/pin-dependencies`, UpdateType `pinDigest`
- **Assertion:** verophi erkennt pinDigest als eigenen UpdateType

### Case: Docker Versions-Update mit CVE

Ein Docker-Image bekommt ein Minor-Update das eine CVE fixt.

- **Packages:** nginx (Docker, 1.24-alpine → 1.25.5-alpine)
- **CVE:** CVE-2025-23419 (TLS session resumption bypass)
- **Renovate-Verhalten:** Branch `renovate/nginx-1.x`, UpdateType `minor`
- **Assertion:** verophi erkennt Docker-Updates mit CVE-Bezug

### Case: Explizite Gruppierung (groupName)

Drei unrelated Packages werden via `groupName: "http-client-group"` in einen einzigen Renovate-Branch gepackt. Testet ob verophi die Description-Tabelle mit mehreren Zeilen parsen und pro Zeile korrekte Daten extrahieren kann.

- **Packages:**
  - axios 0.21.1 → 0.21.4 (patch) — CVE-2021-3749 (ReDoS)
  - tough-cookie 4.1.2 → 4.1.3 (patch) — CVE-2023-26136 (Prototype Pollution)
  - semver 7.3.7 → 7.5.2 (minor) — CVE-2022-25883 (ReDoS)
- **Renovate-Verhalten:** Ein Branch `renovate/http-client-group`, Description mit 3-Zeilen-Tabelle
- **Assertion:**
  - verophi extrahiert alle 3 Changes aus der Tabelle
  - Pro Zeile wird der korrekte UpdateType erkannt (patch vs minor)
  - Jedes Package wird der richtigen CVE zugeordnet

### Case: npm rangeStrategy pin

Ein Package mit `^`-Range wird auf eine exakte Version gepinnt. Testet den UpdateType `pin` separat von `pinDigest`.

- **Packages:**
  - json5 ^2.2.1 → 2.2.2 (pin) — CVE-2022-46175 (Prototype Pollution via Parse)
  - ws ^7.5.9 → 7.5.10 (pin) — CVE-2024-37890 (DoS via HTTP headers)
- **Renovate-Verhalten:** Branch `renovate/pin-dependencies`, Change zeigt Range→Exact
- **Assertion:**
  - verophi erkennt UpdateType `pin`
  - Der `currentValue` (Range `^x.y.z`) wird korrekt geparst
  - CVE-Zuordnung funktioniert auch bei Pin-Updates

---

## Übersicht aller Packages

| Package | Ecosystem | From | To | Bump | CVE | Case |
|---|---|---|---|---|---|---|
| lodash | npm | 4.17.20 | 4.17.21 | patch | CVE-2021-23337 | Patch, Unfixable |
| minimist | npm | 1.2.5 | 1.2.6 | patch | CVE-2021-44906 | Patch |
| express | npm | 4.17.1 | 4.21.0 | minor | — | Minor |
| axios | npm | 0.21.1 | 0.21.4 | patch | CVE-2021-3749 | Gruppierung |
| tough-cookie | npm | 4.1.2 | 4.1.3 | patch | CVE-2023-26136 | Gruppierung |
| semver | npm | 7.3.7 | 7.5.2 | minor | CVE-2022-25883 | Gruppierung |
| json5 | npm | ^2.2.1 | 2.2.2 | pin | CVE-2022-46175 | Pin |
| ws | npm | ^7.5.9 | 7.5.10 | pin | CVE-2024-37890 | Pin |
| PyYAML | python | 5.3.1 | 6.0 | major | CVE-2020-14343 | Major |
| Pillow | python | 9.0.0 | 10.2.0 | major | multiple | Major |
| requests | python | 2.31.0 | 2.32.0 | patch | CVE-2024-35195 | Disabled |
| golang.org/x/net | go | 0.16.0 | 0.33.0 | minor | CVE-2023-44487 | Minor |
| golang.org/x/crypto | go | 0.16.0 | 0.31.0 | minor | CVE-2023-48795 | Minor |
| gin | go | 1.7.0 | 1.9.1 | minor | CVE-2023-26125 | Minor |
| log4j-core | maven | 2.14.1 | 2.17.1 | minor | CVE-2021-44228 | Minor, Monorepo |
| rustls | rust | 0.20.8 | 0.21.11 | minor | RUSTSEC-2024-0336 | Minor |
| tokio | rust | 1.17.0 | 1.27.0 | minor | RUSTSEC-2023-0001 | Minor |
| actionpack | ruby | 6.1.4 | 6.1.7.8 | patch | multiple | Patch, Monorepo |
| Newtonsoft.Json | nuget | 12.0.3 | 13.0.3 | major | GHSA-5crp-9r3c-p9vr | Major |
| System.Text.Json | nuget | 6.0.0 | 8.0.5 | major | GHSA-8g4q-xg66-9fp4 | Major, Monorepo |
| guzzlehttp/guzzle | php | 7.4.0 | 7.8.0 | minor | multiple | Minor |
| phoenix | elixir | 1.6.0 | 1.7.0 | minor | GHSA-p8f7-22gq-m7j9 | Minor |
| dio | dart | 4.0.0 | 5.0.0 | major | CVE-2021-31402 | Major |
| swift-nio-http2 | swift | 1.25.0 | 1.28.0 | minor | CVE-2023-44487 | Minor |
| nginx | docker | 1.24-alpine | 1.25.5 | minor | CVE-2025-23419 | Docker CVE |
| node | docker | 20-alpine | pinDigest | pinDigest | — | pinDigest |

---

## Noch nicht abgedeckt (für spätere Phasen)

| Case | Beschreibung | Entscheidung nötig |
|---|---|---|
| Replacement | Renovate schlägt Package-Replacement vor (z.B. `request` → `got`) | In-scope für MVP? |
| Rollback | UpdateType `rollback` (zurückgezogene Version) | Sehr selten, vermutlich out-of-scope |
| Digest | Git SHA-basierte Updates (z.B. GitHub Actions) | Eigenes Fixture-Repo nötig |
| Lockfile | Lock-File-Maintenance Updates | Aktuell deaktiviert in renovate.json |
| Custom Prefix | Custom `branchPrefix` (z.B. `deps/` statt `renovate/`) | Branch-Parsing-Frage |
| Mixed-Types-Group | Gruppe mit gemischten Major+Minor+Patch in einem Branch | Braucht `separateMajorMinor: false` |
| Title-Fallback | PR ohne Description / mit unparsbarem Titel | Manuelle PRs nach Remote-Push |
