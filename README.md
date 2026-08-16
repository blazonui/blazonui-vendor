# BlazonuiVendor

Addon für World of Warcraft (Retail). Automatisches Reparieren (optional per `/bv repair`)
und automatisches Verkaufen von Ramsch (graue Gegenstände) beim Händler.

Quellcode ist öffentlich einsehbar — siehe [LICENSE](LICENSE) für Nutzungsbedingungen.
Bugs/Vorschläge bitte über den [Discord](https://blazonui.de/join) (`/report`, `/suggest`),
nicht direkt als GitHub-Issue.

## Release-Automation

Ein `git tag vX.Y.Z` + `git push --tags` löst automatisch (via `.github/workflows/release.yml`,
[BigWigsMods/packager](https://github.com/BigWigsMods/packager)) einen Release aus, der das
Addon gleichzeitig auf GitHub Releases, CurseForge und Wago.io veröffentlicht.

Dafür müssen einmalig diese Repository-Secrets gesetzt sein
(Settings → Secrets and variables → Actions):

- `CF_API_KEY` — CurseForge API-Token
- `WAGO_API_TOKEN` — Wago.io API-Token
