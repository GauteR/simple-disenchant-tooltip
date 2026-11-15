-- Material reverse lookup and item classification helpers.
Disenchanter = Disenchanter or {}
Disenchanter.Materials = Disenchanter.Materials or {}

local Materials = Disenchanter.Materials

-- Built from Tables.FORWARD (percentages per band).
local BY_ID = Disenchanter.Tables:BuildMaterialSources()

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
  local Tables = Disenchanter.Tables
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
  -- Enchanting mats are not disenchanted; skip.
  if self:IsTracked(itemId) then
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

  local Tables = Disenchanter.Tables
  if not Tables then
    return nil
  end
  return Tables:GetOutcomes(qualityKey, typeKey, itemLevel), qualityKey, typeKey, itemLevel
end

-- Pure-Lua outcome lookup (tests / callers with explicit stats).
function Materials:GetOutcomesForStats(qualityKey, typeKey, itemLevel)
  local Tables = Disenchanter.Tables
  if not Tables then
    return nil
  end
  return Tables:GetOutcomes(qualityKey, typeKey, itemLevel)
end

-- RGB for tooltip lines: >= greenThresh green, >= yellowThresh yellow, else gray.
function Materials:ChanceColor(chance)
  local Config = Disenchanter.Config or {}
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

-- Collapse sources into one primary farm line (highest chance quality+type, merged ilvl).
function Materials:GetPrimarySource(itemId)
  local entry = self:GetEntry(itemId)
  if not entry or not entry.sources or #entry.sources == 0 then
    return nil
  end

  local bestChance = -1
  local bestQuality, bestType
  for i = 1, #entry.sources do
    local s = entry.sources[i]
    if s.chance > bestChance then
      bestChance = s.chance
      bestQuality = s.quality
      bestType = s.itemType
    end
  end

  local minLevel, maxLevel, chance = nil, nil, bestChance
  for i = 1, #entry.sources do
    local s = entry.sources[i]
    if s.quality == bestQuality and s.itemType == bestType then
      if not minLevel or s.minLevel < minLevel then
        minLevel = s.minLevel
      end
      if not maxLevel or s.maxLevel > maxLevel then
        maxLevel = s.maxLevel
      end
      if s.chance > chance then
        chance = s.chance
      end
    end
  end

  return {
    quality = bestQuality,
    itemType = bestType,
    minLevel = minLevel,
    maxLevel = maxLevel,
    chance = chance,
  }
end

-- Highest-chance outcome only (primary DE result).
function Materials:GetPrimaryOutcome(outcomes)
  if not outcomes or #outcomes == 0 then
    return nil
  end
  local best = outcomes[1]
  for i = 2, #outcomes do
    if outcomes[i].chance > best.chance then
      best = outcomes[i]
    end
  end
  return best
end

Materials.BY_ID = BY_ID
Materials.WEAPON_EQUIP = WEAPON_EQUIP
