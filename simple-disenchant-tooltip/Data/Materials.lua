-- Material reverse lookup and item classification helpers.
SimpleDisenchantTooltip = SimpleDisenchantTooltip or {}
SimpleDisenchantTooltip.Materials = SimpleDisenchantTooltip.Materials or {}

local Materials = SimpleDisenchantTooltip.Materials

-- Built from Tables.FORWARD (percentages per band).
local BY_ID = SimpleDisenchantTooltip.Tables:BuildMaterialSources()

-- Equip locations treated as weapons for Classic DE (essence-primary).
local WEAPON_EQUIP = {
  INVTYPE_WEAPON = true,
  INVTYPE_WEAPONMAINHAND = true,
  INVTYPE_WEAPONOFFHAND = true,
  INVTYPE_2HWEAPON = true,
  INVTYPE_RANGED = true,
  INVTYPE_RANGEDRIGHT = true,
  INVTYPE_THROWN = true,
  INVTYPE_SHIELD = true,
  INVTYPE_HOLDABLE = true,
}

-- Gear that looks disenchantable by quality/type but is not (e.g. wands made by Enchanting).
local NOT_DISENCHANTABLE = {
  [11287] = true, -- Lesser Magic Wand
  [11288] = true, -- Greater Magic Wand
  [11289] = true, -- Lesser Mystic Wand
  [11290] = true, -- Greater Mystic Wand
}

function Materials:IsNotDisenchantable(itemId)
  return type(itemId) == "number" and NOT_DISENCHANTABLE[itemId] == true
end

function Materials:GetEntry(itemId)
  if type(itemId) ~= "number" then
    return nil
  end
  local sources = BY_ID[itemId]
  if not sources then
    return nil
  end
  return { sources = sources }
end

function Materials:IsTracked(itemId)
  return self:GetEntry(itemId) ~= nil
end

function Materials:ParseItemId(link)
  if type(link) ~= "string" then
    return nil
  end
  local id = link:match("item:(%d+)")
  if not id then
    return nil
  end
  return tonumber(id)
end

function Materials:GetMaterialName(itemId)
  local Tables = SimpleDisenchantTooltip.Tables
  if Tables and Tables.GetMaterialName then
    return Tables:GetMaterialName(itemId)
  end
  return nil
end

-- Map API quality number (2/3/4) or Enum to internal quality key.
function Materials:QualityKey(quality)
  if quality == 2 or quality == "UNCOMMON" then
    return "UNCOMMON"
  elseif quality == 3 or quality == "RARE" then
    return "RARE"
  elseif quality == 4 or quality == "EPIC" then
    return "EPIC"
  end
  return nil
end

-- Classify as ARMOR or WEAPON for DE tables (shields/OH count as WEAPON).
function Materials:ClassifyItemType(className, equipLoc)
  if WEAPON_EQUIP[equipLoc] then
    return "WEAPON"
  end
  if className == "Weapon" or className == "WEAPON" then
    return "WEAPON"
  end
  if className == "Armor" or className == "ARMOR" then
    return "ARMOR"
  end
  -- Numeric class ids used by some clients (2 weapon, 4 armor).
  if className == 2 then
    return "WEAPON"
  end
  if className == 4 then
    return "ARMOR"
  end
  return nil
end

-- Resolve disenchant outcomes for an equipment item id via GetItemInfo when available.
function Materials:GetOutcomesForItem(itemId)
  if type(itemId) ~= "number" then
    return nil
  end
  -- Enchanting mats and known non-DE items are not disenchanted; skip.
  if self:IsTracked(itemId) or self:IsNotDisenchantable(itemId) then
    return nil
  end

  local name, _, quality, itemLevel, _, itemType, _, _, equipLoc
  if GetItemInfo then
    name, _, quality, itemLevel, _, itemType, _, _, equipLoc = GetItemInfo(itemId)
  end
  if not name and C_Item and C_Item.GetItemInfo then
    name, _, quality, itemLevel, _, itemType, _, _, equipLoc = C_Item.GetItemInfo(itemId)
  end
  if not quality or not itemLevel then
    return nil
  end

  local qualityKey = self:QualityKey(quality)
  local typeKey = self:ClassifyItemType(itemType, equipLoc)
  if not qualityKey or not typeKey then
    return nil
  end

  local Tables = SimpleDisenchantTooltip.Tables
  if not Tables then
    return nil
  end
  local Config = SimpleDisenchantTooltip.Config
  local clamp = Config and Config.OUTCOME_LEVEL_FALLBACK == true
  return Tables:GetOutcomes(qualityKey, typeKey, itemLevel, clamp), qualityKey, typeKey, itemLevel
end

-- Pure-Lua outcome lookup (tests / callers with explicit stats).
function Materials:GetOutcomesForStats(qualityKey, typeKey, itemLevel)
  local Tables = SimpleDisenchantTooltip.Tables
  if not Tables then
    return nil
  end
  local Config = SimpleDisenchantTooltip.Config
  local clamp = Config and Config.OUTCOME_LEVEL_FALLBACK == true
  return Tables:GetOutcomes(qualityKey, typeKey, itemLevel, clamp)
end

-- RGB for tooltip lines: >= greenThresh green, >= yellowThresh yellow, else gray.
function Materials:ChanceColor(chance)
  local Config = SimpleDisenchantTooltip.Config or {}
  local greenAt = Config.CHANCE_GREEN or 75
  local yellowAt = Config.CHANCE_YELLOW or 35
  if type(chance) ~= "number" then
    return 0.5, 0.5, 0.5
  end
  if chance >= greenAt then
    return 0.12, 1.0, 0.12
  end
  if chance >= yellowAt then
    return 1.0, 0.82, 0.0
  end
  return 0.55, 0.55, 0.55
end

-- Merge source bands by quality+type, then return top N by chance (default 2).
function Materials:GetTopSources(itemId, limit)
  limit = limit or 2
  local entry = self:GetEntry(itemId)
  if not entry or not entry.sources or #entry.sources == 0 then
    return nil
  end

  local groups = {}
  local order = {}
  for i = 1, #entry.sources do
    local s = entry.sources[i]
    local key = s.quality .. "\0" .. s.itemType
    local g = groups[key]
    if not g then
      g = {
        quality = s.quality,
        itemType = s.itemType,
        minLevel = s.minLevel,
        maxLevel = s.maxLevel,
        chance = s.chance,
      }
      groups[key] = g
      order[#order + 1] = key
    else
      if s.minLevel < g.minLevel then
        g.minLevel = s.minLevel
      end
      if s.maxLevel > g.maxLevel then
        g.maxLevel = s.maxLevel
      end
      if s.chance > g.chance then
        g.chance = s.chance
      end
    end
  end

  local list = {}
  for i = 1, #order do
    list[#list + 1] = groups[order[i]]
  end
  table.sort(list, function(a, b)
    if a.chance ~= b.chance then
      return a.chance > b.chance
    end
    if a.minLevel ~= b.minLevel then
      return a.minLevel < b.minLevel
    end
    return tostring(a.itemType) < tostring(b.itemType)
  end)

  local top = {}
  for i = 1, math.min(limit, #list) do
    top[i] = list[i]
  end
  if #top == 0 then
    return nil
  end
  return top
end

-- Outcomes sorted by chance descending (all expected results for gear).
function Materials:SortOutcomesByChance(outcomes)
  if not outcomes or #outcomes == 0 then
    return nil
  end
  local sorted = {}
  for i = 1, #outcomes do
    sorted[i] = outcomes[i]
  end
  table.sort(sorted, function(a, b)
    if a.chance ~= b.chance then
      return a.chance > b.chance
    end
    return (a.id or 0) < (b.id or 0)
  end)
  return sorted
end

Materials.BY_ID = BY_ID
Materials.WEAPON_EQUIP = WEAPON_EQUIP
