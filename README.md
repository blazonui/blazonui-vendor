# BlazonuiVendor

Addon für World of Warcraft (Retail). Repariert deine Ausrüstung automatisch beim Händler
und verkauft automatisch Ramsch (graue Gegenstände) — beides einzeln an-/abschaltbar.

`/bv` öffnet ein eigenes Fenster mit Schaltern für beide Funktionen und einer kleinen
Session-Statistik (repariert/verkauft in Gold). Alternativ per Minimap-Icon (ziehbar) oder
über `Einstellungen → AddOns → BlazonuiVendor`. Schnell-Befehle: `/bv repair`, `/bv sell`.

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
