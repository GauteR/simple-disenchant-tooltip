# Disenchanter — datakilde

Addonen viser **én** disenchant-linje i tooltips:

1. **Materiale** — primær farm-kilde (quality, type, sammenslått item level)
2. **Utstyr** — primært forventet DE-utfall (materiale + antall)

Linjefarge etter drop-sjanse: **grønn** ≥ `CHANCE_GREEN` (75), **gul** ≥ `CHANCE_YELLOW` (35), ellers **grå**. Ingen %-tall i teksten.

## Scope

- Forever (`Interface: 16001`)
- Tabeller basert på **Vanilla Classic (1.12)** disenchant-data (`Data/Tables.lua`)
- Kun Vanilla-reagenser (Strange Dust → Nexus Crystal); ingen TBC+

## Oppførsel

- Material-hover: `Config.MATERIAL_SOURCES` (én sammenslått primærkilde)
- Gear-hover: `Config.ITEM_OUTCOMES` (én primær outcome; krever `GetItemInfo` / `C_Item.GetItemInfo`)
- Master-flag: `Config.ENABLED`
- Shield / off-hand telles som **WEAPON** i DE-tabellene (essence-primær)
- Tooltip-hook: `TooltipDataProcessor` når tilgjengelig; ellers `OnTooltipSetItem` på GameTooltip, ItemRefTooltip, ShoppingTooltip1/2, EmbeddedItemTooltip
- `ENABLED = false`: chat-melding ved login; ingen slash/tooltip/Options

## Referanser

- [Warcraft Wiki — Disenchanting tables](https://warcraft.wiki.gg/wiki/Disenchanting_tables)
- [Legacy of Warcraft — Classic disenchanting table](https://legacyofwarcraft.com/db/classic/professions/disenchanting.html)

Forever kan avvike; merk avvik i `MEMORIES.md` etter in-game sjekk.

## Lokal publish

```bash
./scripts/publish-local.sh
```

PowerShell-speil: `scripts/publish-local.ps1`. Begge skal finnes i alle Forever-addons (Git Bash er primær).
