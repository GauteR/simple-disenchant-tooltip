-- Pure Lua tests for observed-item disenchant outcomes.
-- Run: lua tests/test_observed.lua

local root = arg[0]:match("^(.*)[/\\]") or "."
local addonRoot = root .. "/../simple-disenchant-tooltip"

dofile(addonRoot .. "/Config.lua")
dofile(addonRoot .. "/Locale/enUS.lua")
dofile(addonRoot .. "/Data/Tables.lua")
dofile(addonRoot .. "/Data/ObservedItems.lua")
dofile(addonRoot .. "/Data/Materials.lua")

local failures = 0

local function assert_eq(actual, expected, message)
  if actual ~= expected then
    failures = failures + 1
    print(string.format("FAIL: %s\n  expected: %s\n  actual:   %s", message, tostring(expected), tostring(actual)))
  else
    print("PASS: " .. message)
  end
end

local Materials = SimpleDisenchantTooltip.Materials
local Config = SimpleDisenchantTooltip.Config

-- Item info stub: [itemId] = { name, quality, itemLevel, itemType, equipLoc }
local ITEMS = {
  [3201] = { "Barbarian War Axe", 2, 28, "Weapon", "INVTYPE_2HWEAPON" },
  [900001] = { "Unobserved Test Axe", 2, 28, "Weapon", "INVTYPE_2HWEAPON" },
}
function GetItemInfo(itemId)
  local i = ITEMS[itemId]
  if not i then
    return nil
  end
  return i[1], "link", i[2], i[3], 0, i[4], "sub", 1, i[5]
end

-- Observed data covers the Barbarian War Axe (Greater Magic Essence only).
assert_eq(SimpleDisenchantTooltip.ObservedItems["Barbarian War Axe"][1], 10939, "axe observed as Greater Magic Essence")

-- Observed: ilvl 28 would give Greater Astral by band, but the game rolled Greater Magic.
local outcomes = Materials:GetOutcomesForItem(3201)
assert_eq(outcomes[1].id, 10939, "observed axe primary is Greater Magic Essence")
assert_eq(outcomes[1].chance, 75, "observed primary chance 75")
assert_eq(outcomes[2].id, 10940, "observed axe secondary is Strange Dust")
assert_eq(outcomes[2].chance, 35, "observed secondary chance 35")
assert_eq(outcomes[3].id, 10978, "observed axe third is Small Glimmering Shard")
assert_eq(outcomes[3].chance, 10, "observed third chance 10")
assert_eq(outcomes[1].min, 1, "observed band quantity min kept")
assert_eq(outcomes[1].max, 2, "observed band quantity max kept")

-- Unobserved items fall back to the item-level band (ilvl 28 weapon -> Greater Astral).
local fallback = Materials:GetOutcomesForItem(900001)
assert_eq(fallback[1].id, 11082, "unobserved item falls back to ilvl band")
assert_eq(fallback[1].chance, 75, "fallback keeps band chance")

-- Feature flag off -> bands only.
Config.OBSERVED_ITEMS = false
assert_eq(Materials:GetOutcomesForItem(3201)[1].id, 11082, "OBSERVED_ITEMS=false uses ilvl bands")
Config.OBSERVED_ITEMS = true

-- Rare gear is never overridden (fixed 100% shard).
local Tables = SimpleDisenchantTooltip.Tables
assert_eq(Tables:GetObservedOutcomes("RARE", "ANY", { 10978 }, 20), nil, "rare ignores observations")

-- Materials that fit no band fall back (nil) instead of guessing.
assert_eq(Tables:GetObservedOutcomes("UNCOMMON", "WEAPON", { 10939, 11082 }, 20), nil, "no band holds both -> nil")

-- Ambiguous observation (Strange Dust spans three bands): closest band to ilvl wins.
local dust = Tables:GetObservedOutcomes("UNCOMMON", "ARMOR", { 10940 }, 23)
assert_eq(dust[2].id, 10998, "Strange Dust at ilvl 23 resolves to the 21-25 band")

-- Every observed name resolves to known material ids.
local unknown = 0
for _, ids in pairs(SimpleDisenchantTooltip.ObservedItems) do
  for i = 1, #ids do
    if not Tables:GetMaterialName(ids[i]) then
      unknown = unknown + 1
    end
  end
end
assert_eq(unknown, 0, "observed data only references known materials")

if failures > 0 then
  print(string.format("\n%d test(s) failed", failures))
  os.exit(1)
end
print("\nAll observed tests passed")
