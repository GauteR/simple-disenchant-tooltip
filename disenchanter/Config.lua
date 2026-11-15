-- Feature flags and shared addon settings for WoW Forever.
Disenchanter = Disenchanter or {}

Disenchanter.Config = {
  -- Set to false to disable slash command, Options actions, and tooltip lines.
  ENABLED = true,
  -- Material hover: top two DE sources (chance-colored).
  MATERIAL_SOURCES = true,
  -- Gear hover: all expected DE outcomes (chance-colored).
  ITEM_OUTCOMES = true,
  -- Tooltip line colors by drop chance: green / yellow / gray.
  CHANCE_GREEN = 75,
  CHANCE_YELLOW = 35,
  ADDON_NAME = "Disenchanter",
  -- Shown in Options when TOC ## Version: @project-version@ is not packaged yet.
  VERSION = "0.1.0",
  SLASH_COMMAND = "/disenchanter",
}
