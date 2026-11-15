# Disenchanter — datakilde

Addonen viser **hvilke items** (quality, type, item level) som disenchanter til et enchanting-materiale når du holder musepekeren over materialet.

## Scope

- Forever (`Interface: 16001`)
- Tabeller basert på **Vanilla Classic (1.12)** disenchant-data
- Kun Vanilla-reagenser (Strange Dust → Nexus Crystal); ingen TBC+

## Oppførsel

- Tooltip-linjer legges til for kjente material-item-IDer
- Primærkilde først; «lower chance» for sekundære drop
- Feature-flag: `Config.ENABLED` i `disenchanter/Config.lua`
- Tooltip-hook: `TooltipDataProcessor` når tilgjengelig; ellers `OnTooltipSetItem` via `pcall` (mangler handler = ingen classic-hook)
- `ENABLED = false`: chat-melding ved login; ingen slash/tooltip/Options

## Referanser

- [Warcraft Wiki — Disenchanting tables](https://warcraft.wiki.gg/wiki/Disenchanting_tables)
- [Legacy of Warcraft — Classic disenchanting table](https://legacyofwarcraft.com/db/classic/professions/disenchanting.html)

Forever kan avvike; merk avvik i `MEMORIES.md` etter in-game sjekk.
