# Disenchanter — datakilde

Addonen viser disenchant-linjer i tooltips:

1. **Materiale** — de **to** beste farm-kildene (høyeste + nest høyeste sjanse; sammenslått ilvl per quality+type)
2. **Utstyr** — **alle** forventede DE-utfall (sortert etter sjanse)

Linjefarge etter drop-sjanse: **grønn** ≥ `CHANCE_GREEN` (75), **gul** ≥ `CHANCE_YELLOW` (35), ellers **grå**. Ingen %-tall i teksten.

## Scope

- Forever (`Interface: 16001`)
- Tabeller basert på **Vanilla Classic (1.12)** disenchant-data (`Data/Tables.lua`)
- Kun Vanilla-reagenser (Strange Dust → Nexus Crystal); ingen TBC+

## Oppførsel

- Material-hover: `Config.MATERIAL_SOURCES` (topp 2 sammenslåtte kilder)
- Gear-hover: `Config.ITEM_OUTCOMES` (alle outcomes; krever `GetItemInfo` / `C_Item.GetItemInfo`)
- Gear-priser: `Config.OUTCOME_PRICES` — forventet AH-verdi per outcome-linje via Auctionator (`OptionalDeps`). Formel: `(sjanse/100) × snittantall × enhetspris`. Format: `Strange Dust 1–2, ~1g 2s 3c` (MoneyFrame-ikoner; null-denominationer skjules). Under outcomes: `AddDoubleLine` **Disenchant** (gul) med summert forventet verdi høyrestilt (uten `~`); totalen summerer bare outcomes som har kjent AH-pris. Sjansetfarge er embedded `|cff` på navn/antall slik at mynt-ikonene ikke tintes. Mangler Auctionator/pris på alle → vanlig outcome-linje uten `~` og uten total-linje.
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
