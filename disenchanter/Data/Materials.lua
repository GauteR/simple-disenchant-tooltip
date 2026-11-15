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

Materials.BY_ID = BY_ID
Materials.WEAPON_EQUIP = WEAPON_EQUIP
