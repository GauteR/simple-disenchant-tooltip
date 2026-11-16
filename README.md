# Simple Disenchant Tooltip

Tooltip helper for **World of Warcraft: Forever** that shows disenchant sources and expected outcomes.

Hover materials to see the top farm sources, or hover gear to see all expected disenchant results (optionally with Auctionator prices).

| | |
| --- | --- |
| Interface | `16001` (Forever / build line 1.60.x) |
| Slash command | `/sdt` |
| Language | English (UI and docs) |
| Optional dep | Auctionator (outcome prices) |
| Version | From git tag via `@project-version@` in TOC (see [`docs/RELEASE.md`](docs/RELEASE.md)) |

## Features

- Material tooltips: top two disenchant farm sources (chance-colored)
- Gear tooltips: all expected DE outcomes (chance-colored)
- Optional Auctionator pricing on outcomes + Disenchant value line
- Pure Lua unit tests for materials and pricing helpers
- Minimal memory footprint

## Install

1. Copy the `simple-disenchant-tooltip` folder into your Forever AddOns directory, for example:

   `World of Warcraft\_forever_\Interface\AddOns\simple-disenchant-tooltip`

2. Restart the client, or log out and back in.
3. Enable **Simple Disenchant Tooltip** on the character addon list if it is disabled.
4. Type `/sdt` in chat for status.

## Usage

- Hover a enchanting material (Strange Dust → Nexus Crystal) to see the two best item sources.
- Hover disenchantable gear to see every expected outcome line.
- With Auctionator and known AH prices, a **Disenchant** value appear when prices exist.
- Line color by drop chance: green ≥75, yellow ≥35, gray otherwise.

## Configuration

Edit [`simple-disenchant-tooltip/Config.lua`](simple-disenchant-tooltip/Config.lua):

| Setting | Default | Meaning |
| --- | --- | --- |
| `ENABLED` | `true` | Master flag. `false` disables slash, tooltips, and Options actions. |
| `MATERIAL_SOURCES` | `true` | Material hover: top two DE sources. |
| `ITEM_OUTCOMES` | `true` | Gear hover: all expected DE outcomes. |
| `OUTCOME_LEVEL_FALLBACK` | `true` | Clamp out-of-range item level to nearest Vanilla DE band (Forever low/high gear). |
| `OUTCOME_PRICES` | `true` | Append Auctionator expected value when available. |
| `CHANCE_GREEN` | `75` | Chance threshold for green line color. |
| `CHANCE_YELLOW` | `35` | Chance threshold for yellow line color. |
| `SLASH_COMMAND` | `"/sdt"` | Documented slash command. |

After changing config or data files, reload with `/reload`.

## Documentation

| Doc | Contents |
| --- | --- |
| [`docs/DISENCHANT.md`](docs/DISENCHANT.md) | Data source, tooltip behaviour, Forever notes |
| [`docs/RELEASE.md`](docs/RELEASE.md) | Local packager / CurseForge–Wago release |
| [`docs/CURSEFORGE.md`](docs/CURSEFORGE.md) | User-facing CurseForge / Wago description |

## Local Forever install (dev)

```powershell
.\scripts\publish-local.ps1
```

```bash
./scripts/publish-local.sh
```

Then `/reload` in-game.

## Release (local)

```powershell
.\scripts\release.ps1 -DryRun
```

```bash
./scripts/release.sh --dry-run
```

See [`docs/RELEASE.md`](docs/RELEASE.md).

## Tests

```bash
lua tests/test_materials.lua
lua tests/test_pricing.lua
lua tests/test_tooltip.lua
```

## License

[MIT](LICENSE) © 2026 GauteR
