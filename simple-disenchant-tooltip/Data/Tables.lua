-- Vanilla Classic (1.12) forward disenchant tables.
-- Each range lists expected outcomes: material item id, chance %, quantity min/max.
SimpleDisenchantTooltip = SimpleDisenchantTooltip or {}
SimpleDisenchantTooltip.Tables = SimpleDisenchantTooltip.Tables or {}

local Tables = SimpleDisenchantTooltip.Tables

-- Material display names for tooltips/tests when GetItemInfo is unavailable.
Tables.MATERIAL_NAMES = {
  [10940] = "Strange Dust",
  [11083] = "Soul Dust",
  [11137] = "Vision Dust",
  [11176] = "Dream Dust",
  [16204] = "Illusion Dust",
  [10938] = "Lesser Magic Essence",
  [10939] = "Greater Magic Essence",
  [10998] = "Lesser Astral Essence",
  [11082] = "Greater Astral Essence",
  [11134] = "Lesser Mystic Essence",
  [11135] = "Greater Mystic Essence",
  [11174] = "Lesser Nether Essence",
  [11175] = "Greater Nether Essence",
  [16202] = "Lesser Eternal Essence",
  [16203] = "Greater Eternal Essence",
  [10978] = "Small Glimmering Shard",
  [11084] = "Large Glimmering Shard",
  [11138] = "Small Glowing Shard",
  [11139] = "Large Glowing Shard",
  [11177] = "Small Radiant Shard",
  [11178] = "Large Radiant Shard",
  [14343] = "Small Brilliant Shard",
  [14344] = "Large Brilliant Shard",
  [20725] = "Nexus Crystal",
}

-- outcome = { id, chance, min, max }
local function O(id, chance, minQty, maxQty)
  return { id = id, chance = chance, min = minQty, max = maxQty or minQty }
end

-- Uncommon armor (dust-primary).
local UNCOMMON_ARMOR = {
  { minLevel = 5, maxLevel = 15, outcomes = { O(10940, 80, 1, 2), O(10938, 20, 1, 2) } },
  { minLevel = 16, maxLevel = 20, outcomes = { O(10940, 75, 2, 3), O(10939, 20, 1, 2), O(10978, 5, 1) } },
  { minLevel = 21, maxLevel = 25, outcomes = { O(10940, 75, 4, 6), O(10998, 15, 1, 2), O(10978, 10, 1) } },
  { minLevel = 26, maxLevel = 30, outcomes = { O(11083, 75, 1, 2), O(11082, 20, 1, 2), O(11084, 5, 1) } },
  { minLevel = 31, maxLevel = 35, outcomes = { O(11083, 75, 2, 5), O(11134, 20, 1, 2), O(11138, 5, 1) } },
  { minLevel = 36, maxLevel = 40, outcomes = { O(11137, 75, 1, 2), O(11135, 20, 1, 2), O(11139, 5, 1) } },
  { minLevel = 41, maxLevel = 45, outcomes = { O(11137, 75, 2, 5), O(11174, 20, 1, 2), O(11177, 5, 1) } },
  { minLevel = 46, maxLevel = 50, outcomes = { O(11176, 75, 1, 2), O(11175, 20, 1, 2), O(11178, 5, 1) } },
  { minLevel = 51, maxLevel = 55, outcomes = { O(11176, 75, 2, 5), O(16202, 20, 1, 2), O(14343, 5, 1) } },
  { minLevel = 56, maxLevel = 60, outcomes = { O(16204, 75, 1, 2), O(16203, 20, 1, 2), O(14344, 5, 1) } },
  { minLevel = 61, maxLevel = 65, outcomes = { O(16204, 75, 2, 5), O(16203, 20, 2, 3), O(14344, 5, 1) } },
}

-- Uncommon weapons, shields, and off-hands (essence-primary).
local UNCOMMON_WEAPON = {
  { minLevel = 5, maxLevel = 15, outcomes = { O(10938, 80, 1, 2), O(10940, 20, 1, 2) } },
  { minLevel = 16, maxLevel = 20, outcomes = { O(10939, 75, 1, 2), O(10940, 20, 2, 3), O(10978, 5, 1) } },
  { minLevel = 21, maxLevel = 25, outcomes = { O(10998, 75, 1, 2), O(10940, 15, 4, 6), O(10978, 10, 1) } },
  { minLevel = 26, maxLevel = 30, outcomes = { O(11082, 75, 1, 2), O(11083, 20, 1, 2), O(11084, 5, 1) } },
  { minLevel = 31, maxLevel = 35, outcomes = { O(11134, 75, 1, 2), O(11083, 20, 2, 5), O(11138, 5, 1) } },
  { minLevel = 36, maxLevel = 40, outcomes = { O(11135, 75, 1, 2), O(11137, 20, 1, 2), O(11139, 5, 1) } },
  { minLevel = 41, maxLevel = 45, outcomes = { O(11174, 75, 1, 2), O(11137, 20, 2, 5), O(11177, 5, 1) } },
  { minLevel = 46, maxLevel = 50, outcomes = { O(11175, 75, 1, 2), O(11176, 20, 1, 2), O(11178, 5, 1) } },
  { minLevel = 51, maxLevel = 55, outcomes = { O(16202, 75, 1, 2), O(11176, 22, 2, 5), O(14343, 3, 1) } },
  { minLevel = 56, maxLevel = 60, outcomes = { O(16203, 75, 1, 2), O(16204, 22, 1, 2), O(14344, 3, 1) } },
  { minLevel = 61, maxLevel = 65, outcomes = { O(16203, 75, 2), O(16204, 22, 2, 5), O(14344, 3, 1) } },
}

-- Rare gear: guaranteed shard by item level.
local RARE_ANY = {
  { minLevel = 16, maxLevel = 25, outcomes = { O(10978, 100, 1) } },
  { minLevel = 26, maxLevel = 30, outcomes = { O(11084, 100, 1) } },
  { minLevel = 31, maxLevel = 35, outcomes = { O(11138, 100, 1) } },
  { minLevel = 36, maxLevel = 40, outcomes = { O(11139, 100, 1) } },
  { minLevel = 41, maxLevel = 45, outcomes = { O(11177, 100, 1) } },
  { minLevel = 46, maxLevel = 50, outcomes = { O(11178, 100, 1) } },
  { minLevel = 51, maxLevel = 55, outcomes = { O(14343, 100, 1) } },
  { minLevel = 56, maxLevel = 65, outcomes = { O(14344, 100, 1) } },
}

-- Epic gear: Nexus Crystal band (Vanilla high-end).
local EPIC_ANY = {
  { minLevel = 51, maxLevel = 65, outcomes = { O(20725, 100, 1, 2) } },
}

Tables.FORWARD = {
  UNCOMMON = {
    ARMOR = UNCOMMON_ARMOR,
    WEAPON = UNCOMMON_WEAPON,
  },
  RARE = {
    ANY = RARE_ANY,
  },
  EPIC = {
    ANY = EPIC_ANY,
  },
}

local function FindRange(ranges, itemLevel)
  if type(itemLevel) ~= "number" or not ranges or #ranges == 0 then
    return nil
  end
  for i = 1, #ranges do
    local row = ranges[i]
    if itemLevel >= row.minLevel and itemLevel <= row.maxLevel then
      return row
    end
  end
  return nil
end

-- Nearest band when ilvl is below, above, or in a gap between Vanilla ranges.
local function FindNearestRange(ranges, itemLevel)
  if type(itemLevel) ~= "number" or not ranges or #ranges == 0 then
    return nil
  end
  local exact = FindRange(ranges, itemLevel)
  if exact then
    return exact
  end
  if itemLevel < ranges[1].minLevel then
    return ranges[1]
  end
  if itemLevel > ranges[#ranges].maxLevel then
    return ranges[#ranges]
  end
  -- Gap between bands: pick the closer edge (ties prefer lower band).
  local best = ranges[1]
  local bestDist = math.abs(itemLevel - best.maxLevel)
  for i = 1, #ranges do
    local row = ranges[i]
    local distBelow = math.abs(itemLevel - row.minLevel)
    local distAbove = math.abs(itemLevel - row.maxLevel)
    local dist = distBelow
    if distAbove < dist then
      dist = distAbove
    end
    if dist < bestDist then
      best = row
      bestDist = dist
    end
  end
  return best
end

-- quality: UNCOMMON|RARE|EPIC, itemType: ARMOR|WEAPON, itemLevel: number
-- clampToNearest: use nearest band when ilvl is outside Vanilla tables (Forever).
function Tables:GetOutcomes(quality, itemType, itemLevel, clampToNearest)
  local byQuality = self.FORWARD[quality]
  if not byQuality then
    return nil
  end
  local ranges = byQuality[itemType] or byQuality.ANY
  local row
  if clampToNearest then
    row = FindNearestRange(ranges, itemLevel)
  else
    row = FindRange(ranges, itemLevel)
  end
  if not row then
    return nil
  end
  return row.outcomes
end

local function RowHasAll(row, materialIds)
  for i = 1, #materialIds do
    local found = false
    for j = 1, #row.outcomes do
      if row.outcomes[j].id == materialIds[i] then
        found = true
        break
      end
    end
    if not found then
      return false
    end
  end
  return true
end

local function RowDistance(row, itemLevel)
  if type(itemLevel) ~= "number" then
    return 0
  end
  if itemLevel < row.minLevel then
    return row.minLevel - itemLevel
  end
  if itemLevel > row.maxLevel then
    return itemLevel - row.maxLevel
  end
  return 0
end

-- Outcomes for an item whose real disenchant results were observed in game.
-- materialIds: materials the item was seen to disenchant into (Data/ObservedItems.lua).
-- Picks the band that contains every observed material (closest to itemLevel when several
-- do) and replaces its chances by rank: primary, secondary, shard (chances = {75, 35, 10}).
-- Returns nil when no band matches so callers fall back to the item-level lookup.
-- Uncommon gear only: Rare/Epic bands are fixed 100% drops.
function Tables:GetObservedOutcomes(quality, itemType, materialIds, itemLevel, chances)
  if quality ~= "UNCOMMON" or type(materialIds) ~= "table" or #materialIds == 0 then
    return nil
  end
  local byQuality = self.FORWARD[quality]
  local ranges = byQuality and byQuality[itemType]
  if not ranges then
    return nil
  end
  local best, bestDist
  for i = 1, #ranges do
    local row = ranges[i]
    if RowHasAll(row, materialIds) then
      local dist = RowDistance(row, itemLevel)
      if not best or dist < bestDist then
        best, bestDist = row, dist
      end
    end
  end
  if not best then
    return nil
  end
  chances = chances or { 75, 35, 10 }
  local outcomes = {}
  for i = 1, #best.outcomes do
    local o = best.outcomes[i]
    outcomes[i] = { id = o.id, chance = chances[i] or o.chance, min = o.min, max = o.max }
  end
  return outcomes
end

function Tables:GetMaterialName(itemId)
  return self.MATERIAL_NAMES[itemId]
end

-- Build reverse index: materialId → { { quality, itemType, minLevel, maxLevel, chance, min, max }, ... }
function Tables:BuildMaterialSources()
  local byId = {}
  local function add(quality, itemType, range)
    for i = 1, #range.outcomes do
      local o = range.outcomes[i]
      local list = byId[o.id]
      if not list then
        list = {}
        byId[o.id] = list
      end
      list[#list + 1] = {
        quality = quality,
        itemType = itemType,
        minLevel = range.minLevel,
        maxLevel = range.maxLevel,
        chance = o.chance,
        min = o.min,
        max = o.max,
      }
    end
  end

  for qi = 1, #UNCOMMON_ARMOR do
    add("UNCOMMON", "ARMOR", UNCOMMON_ARMOR[qi])
  end
  for qi = 1, #UNCOMMON_WEAPON do
    add("UNCOMMON", "WEAPON", UNCOMMON_WEAPON[qi])
  end
  for qi = 1, #RARE_ANY do
    add("RARE", "ANY", RARE_ANY[qi])
  end
  for qi = 1, #EPIC_ANY do
    add("EPIC", "ANY", EPIC_ANY[qi])
  end
  return byId
end
