# Simple Disenchant Tooltip — datakilde

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
- Ilvl utenfor Vanilla-bånd: `Config.OUTCOME_LEVEL_FALLBACK` klamper til **nærmeste** band (f.eks. Rare under ilvl 16 → Small Glimmering; Uncommon over 65 → topp Illusion-band). Forever lavnivå-blues som Gemmed Copper Boots.
- Gear-priser: `Config.OUTCOME_PRICES` — under outcome-linjer (kun navn/antall, sjanssefarget): `AddDoubleLine` **Disenchant** (gul etikett, hvit myntverdi) med forventet AH-verdi for det **mest sannsynlige** utfallet via Auctionator (`OptionalDeps`). Formel: `(sjanse/100) × snittantall × enhetspris`. MoneyFrame-ikoner; null-denominationer skjules; sølv/kobber med ledende null (`02s` / `03c`). Mangler pris på topp-utfallet → ingen Disenchant-linje.
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
