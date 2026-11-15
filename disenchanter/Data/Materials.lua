-- Vanilla Classic (1.12) disenchant sources keyed by enchanting material item ID.
-- Primary rows are the main farm targets; secondary rows are alternate drops.
Disenchanter = Disenchanter or {}
Disenchanter.Materials = Disenchanter.Materials or {}

local Materials = Disenchanter.Materials

-- quality: UNCOMMON | RARE | EPIC
-- itemType: ARMOR | WEAPON | ANY
-- secondary: true = lower drop chance / side product
local BY_ID = {
  -- Dusts (primarily uncommon armor)
  [10940] = { -- Strange Dust
    sources = {
      { quality = "UNCOMMON", itemType = "ARMOR", minLevel = 5, maxLevel = 25 },
      { quality = "UNCOMMON", itemType = "WEAPON", minLevel = 5, maxLevel = 25, secondary = true },
    },
  },
  [11083] = { -- Soul Dust
    sources = {
      { quality = "UNCOMMON", itemType = "ARMOR", minLevel = 26, maxLevel = 35 },
      { quality = "UNCOMMON", itemType = "WEAPON", minLevel = 26, maxLevel = 35, secondary = true },
    },
  },
  [11137] = { -- Vision Dust
    sources = {
      { quality = "UNCOMMON", itemType = "ARMOR", minLevel = 36, maxLevel = 45 },
      { quality = "UNCOMMON", itemType = "WEAPON", minLevel = 36, maxLevel = 45, secondary = true },
    },
  },
  [11176] = { -- Dream Dust
    sources = {
      { quality = "UNCOMMON", itemType = "ARMOR", minLevel = 46, maxLevel = 55 },
      { quality = "UNCOMMON", itemType = "WEAPON", minLevel = 46, maxLevel = 55, secondary = true },
    },
  },
  [16204] = { -- Illusion Dust
    sources = {
      { quality = "UNCOMMON", itemType = "ARMOR", minLevel = 56, maxLevel = 65 },
      { quality = "UNCOMMON", itemType = "WEAPON", minLevel = 56, maxLevel = 65, secondary = true },
    },
  },

  -- Essences (primarily uncommon weapons / shields / off-hands)
  [10938] = { -- Lesser Magic Essence
    sources = {
      { quality = "UNCOMMON", itemType = "WEAPON", minLevel = 5, maxLevel = 15 },
      { quality = "UNCOMMON", itemType = "ARMOR", minLevel = 5, maxLevel = 15, secondary = true },
    },
  },
  [10939] = { -- Greater Magic Essence
    sources = {
      { quality = "UNCOMMON", itemType = "WEAPON", minLevel = 16, maxLevel = 20 },
      { quality = "UNCOMMON", itemType = "ARMOR", minLevel = 16, maxLevel = 20, secondary = true },
    },
  },
  [10998] = { -- Lesser Astral Essence
    sources = {
      { quality = "UNCOMMON", itemType = "WEAPON", minLevel = 21, maxLevel = 25 },
      { quality = "UNCOMMON", itemType = "ARMOR", minLevel = 21, maxLevel = 25, secondary = true },
    },
  },
  [11082] = { -- Greater Astral Essence
    sources = {
      { quality = "UNCOMMON", itemType = "WEAPON", minLevel = 26, maxLevel = 30 },
      { quality = "UNCOMMON", itemType = "ARMOR", minLevel = 26, maxLevel = 30, secondary = true },
    },
  },
  [11134] = { -- Lesser Mystic Essence
    sources = {
      { quality = "UNCOMMON", itemType = "WEAPON", minLevel = 31, maxLevel = 35 },
      { quality = "UNCOMMON", itemType = "ARMOR", minLevel = 31, maxLevel = 35, secondary = true },
    },
  },
  [11135] = { -- Greater Mystic Essence
    sources = {
      { quality = "UNCOMMON", itemType = "WEAPON", minLevel = 36, maxLevel = 40 },
      { quality = "UNCOMMON", itemType = "ARMOR", minLevel = 36, maxLevel = 40, secondary = true },
    },
  },
  [11174] = { -- Lesser Nether Essence
    sources = {
      { quality = "UNCOMMON", itemType = "WEAPON", minLevel = 41, maxLevel = 45 },
      { quality = "UNCOMMON", itemType = "ARMOR", minLevel = 41, maxLevel = 45, secondary = true },
    },
  },
  [11175] = { -- Greater Nether Essence
    sources = {
      { quality = "UNCOMMON", itemType = "WEAPON", minLevel = 46, maxLevel = 50 },
      { quality = "UNCOMMON", itemType = "ARMOR", minLevel = 46, maxLevel = 50, secondary = true },
    },
  },
  [16202] = { -- Lesser Eternal Essence
    sources = {
      { quality = "UNCOMMON", itemType = "WEAPON", minLevel = 51, maxLevel = 55 },
      { quality = "UNCOMMON", itemType = "ARMOR", minLevel = 51, maxLevel = 55, secondary = true },
    },
  },
  [16203] = { -- Greater Eternal Essence
    sources = {
      { quality = "UNCOMMON", itemType = "WEAPON", minLevel = 56, maxLevel = 65 },
      { quality = "UNCOMMON", itemType = "ARMOR", minLevel = 56, maxLevel = 65, secondary = true },
    },
  },

  -- Shards (guaranteed from rares; also uncommon side drops in overlapping ranges)
  [10978] = { -- Small Glimmering Shard
    sources = {
      { quality = "RARE", itemType = "ANY", minLevel = 16, maxLevel = 25 },
      { quality = "UNCOMMON", itemType = "ANY", minLevel = 16, maxLevel = 25, secondary = true },
    },
  },
  [11084] = { -- Large Glimmering Shard
    sources = {
      { quality = "RARE", itemType = "ANY", minLevel = 26, maxLevel = 30 },
      { quality = "UNCOMMON", itemType = "ANY", minLevel = 26, maxLevel = 30, secondary = true },
    },
  },
  [11138] = { -- Small Glowing Shard
    sources = {
      { quality = "RARE", itemType = "ANY", minLevel = 31, maxLevel = 35 },
      { quality = "UNCOMMON", itemType = "ANY", minLevel = 31, maxLevel = 35, secondary = true },
    },
  },
  [11139] = { -- Large Glowing Shard
    sources = {
      { quality = "RARE", itemType = "ANY", minLevel = 36, maxLevel = 40 },
      { quality = "UNCOMMON", itemType = "ANY", minLevel = 36, maxLevel = 40, secondary = true },
    },
  },
  [11177] = { -- Small Radiant Shard
    sources = {
      { quality = "RARE", itemType = "ANY", minLevel = 41, maxLevel = 45 },
      { quality = "UNCOMMON", itemType = "ANY", minLevel = 41, maxLevel = 45, secondary = true },
    },
  },
  [11178] = { -- Large Radiant Shard
    sources = {
      { quality = "RARE", itemType = "ANY", minLevel = 46, maxLevel = 50 },
      { quality = "UNCOMMON", itemType = "ANY", minLevel = 46, maxLevel = 50, secondary = true },
    },
  },
  [14343] = { -- Small Brilliant Shard
    sources = {
      { quality = "RARE", itemType = "ANY", minLevel = 51, maxLevel = 55 },
      { quality = "UNCOMMON", itemType = "ANY", minLevel = 51, maxLevel = 55, secondary = true },
    },
  },
  [14344] = { -- Large Brilliant Shard
    sources = {
      { quality = "RARE", itemType = "ANY", minLevel = 56, maxLevel = 65 },
      { quality = "UNCOMMON", itemType = "ANY", minLevel = 56, maxLevel = 65, secondary = true },
    },
  },

  -- Crystals
  [20725] = { -- Nexus Crystal
    sources = {
      { quality = "EPIC", itemType = "ANY", minLevel = 51, maxLevel = 60 },
    },
  },
}

function Materials:GetEntry(itemId)
  if type(itemId) ~= "number" then
    return nil
  end
  return BY_ID[itemId]
end

function Materials:IsTracked(itemId)
  return self:GetEntry(itemId) ~= nil
end

-- Parse numeric item id from an item link or "item:12345:..." string.
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

-- Expose table for pure Lua tests.
Materials.BY_ID = BY_ID
