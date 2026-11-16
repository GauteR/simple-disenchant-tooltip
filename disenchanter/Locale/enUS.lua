-- English (enUS) UI strings.
Disenchanter = Disenchanter or {}
local L = {}
Disenchanter.L = L

L.ADDON_NAME = "Disenchanter"
L.CHAT_PREFIX = "|cff33ff99Disenchanter|r: "

L.CHAT_DISABLED = "Addon is disabled."
L.CHAT_LOADED = "Loaded. /disenchanter for status."
L.CHAT_STATUS_ON = "Tooltips enabled."
L.CHAT_STATUS_OFF = "Addon is disabled in Config."

L.OPTIONS_VERSION_FMT = "Version %s"
L.OPTIONS_HELP =
  "Hover reagents for the top two disenchant sources, or gear for all expected outcomes. Line color: green high chance, yellow medium, gray low. With Auctionator, gear shows a Disenchant line with the most likely outcome AH value."

L.SOURCE_LINE_FMT = "%s %s, item level %d–%d"
L.OUTCOME_LINE_FMT = "%s %s"
L.DISENCHANT_TOTAL = "Disenchant"
L.QUALITY_UNCOMMON = "Uncommon"
L.QUALITY_RARE = "Rare"
L.QUALITY_EPIC = "Epic"
L.TYPE_ARMOR = "Armor"
L.TYPE_WEAPON = "Weapons"
L.TYPE_ANY = "Armor or Weapons"

-- Resolve a locale key; optional format args.
function Disenchanter:T(key, ...)
  local text = (self.L and self.L[key]) or key
  if select("#", ...) > 0 then
    return string.format(text, ...)
  end
  return text
end
