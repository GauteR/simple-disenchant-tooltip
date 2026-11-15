-- Feature flags and shared addon settings for WoW Forever.
Disenchanter = Disenchanter or {}

Disenchanter.Config = {
  -- Set to false to disable slash command, Options actions, and tooltip lines.
  ENABLED = true,
  -- Material hover: show which items DE into this reagent (with %).
  MATERIAL_SOURCES = true,
  -- Gear hover: show expected DE outcomes (with %).
  ITEM_OUTCOMES = true,
  ADDON_NAME = "Disenchanter",
  -- Shown in Options when TOC ## Version: @project-version@ is not packaged yet.
  VERSION = "0.1.0",
  SLASH_COMMAND = "/disenchanter",
}
