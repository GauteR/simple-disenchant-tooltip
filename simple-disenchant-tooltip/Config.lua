-- Feature flags and shared addon settings for WoW Forever.
SimpleDisenchantTooltip = SimpleDisenchantTooltip or {}

SimpleDisenchantTooltip.Config = {
  -- Set to false to disable slash command, Options actions, and tooltip lines.
  ENABLED = true,
  -- Material hover: top two DE sources (chance-colored).
  MATERIAL_SOURCES = true,
  -- Gear hover: all expected DE outcomes (chance-colored).
  ITEM_OUTCOMES = true,
  -- When ilvl is outside Vanilla DE bands, use nearest band (Forever low/high gear).
  OUTCOME_LEVEL_FALLBACK = true,
  -- Append Disenchant line with most-likely outcome AH value (TSM then Auctionator).
  OUTCOME_PRICES = true,
  -- TSM custom price source for material unit prices (soft-dep).
  TSM_PRICE_SOURCE = "DBMarket",
  -- Tooltip line colors by drop chance: green / yellow / gray.
  CHANCE_GREEN = 75,
  CHANCE_YELLOW = 35,
  ADDON_NAME = "Simple Disenchant Tooltip",
  -- Shown in Options when TOC ## Version: @project-version@ is not packaged yet.
  VERSION = "1.1.5",
  SLASH_COMMAND = "/sdt",
}
