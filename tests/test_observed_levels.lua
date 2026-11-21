-- Pure Lua tests for observed item-level ranges on the material (reverse) lookup.
-- Run: lua tests/test_observed_levels.lua

local root = arg[0]:match("^(.*)[/\\]") or "."
local addonRoot = root .. "/../simple-disenchant-tooltip"

dofile(addonRoot .. "/Config.lua")
dofile(addonRoot .. "/Locale/enUS.lua")
dofile(addonRoot .. "/Data/Tables.lua")
dofile(addonRoot .. "/Data/ObservedLevels.lua")
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

local function find(sources, quality, itemType)
  for i = 1, #sources do
    if sources[i].quality == quality and sources[i].itemType == itemType then
      return sources[i]
    end
  end
end

-- Without observed data the Vanilla bands are used (Strange Dust armor 5-25, 80%).
SimpleDisenchantTooltip.ObservedLevels = {}
local vanilla = Materials:GetTopSources(10940, 2)
assert_eq(vanilla[1].minLevel, 5, "no observations: vanilla min level")
assert_eq(vanilla[1].maxLevel, 25, "no observations: vanilla max level")
assert_eq(vanilla[1].chance, 80, "no observations: vanilla chance")

-- Observed ranges (outliers already removed).
SimpleDisenchantTooltip.ObservedLevels = {
  [10940] = { UNCOMMON = { ARMOR = { 5, 26 }, WEAPON = { 10, 27 } } },
  [10939] = { UNCOMMON = { WEAPON = { 16, 24 } } },
}

local dust = Materials:GetTopSources(10940, 2)
assert_eq(dust[1].itemType, "ARMOR", "Strange Dust top source is armor")
assert_eq(dust[1].minLevel, 5, "observed armor min")
assert_eq(dust[1].maxLevel, 26, "observed armor max")
assert_eq(dust[1].chance, 75, "armor: dust is primary -> 75")
assert_eq(dust[2].itemType, "WEAPON", "Strange Dust second source is weapons")
assert_eq(dust[2].minLevel, 10, "observed weapon min")
assert_eq(dust[2].maxLevel, 27, "observed weapon max")
assert_eq(dust[2].chance, 35, "weapon: dust is secondary -> 35")

-- Essence is primary on weapons (75) and secondary on armor; only weapons were observed.
local essence = Materials:GetTopSources(10939, 2)
local weapon = find(essence, "UNCOMMON", "WEAPON")
assert_eq(weapon.minLevel, 16, "Greater Magic weapon observed min")
assert_eq(weapon.maxLevel, 24, "Greater Magic weapon observed max")
assert_eq(weapon.chance, 75, "weapon: essence is primary -> 75")
local armor = find(essence, "UNCOMMON", "ARMOR")
assert_eq(armor.minLevel, 16, "unobserved type keeps vanilla min")
assert_eq(armor.maxLevel, 20, "unobserved type keeps vanilla max")
assert_eq(armor.chance, 20, "unobserved type keeps vanilla chance")

-- Materials with no entry are untouched.
local shard = Materials:GetTopSources(10978, 2)
assert_eq(shard[1].quality, "RARE", "unobserved shard keeps rare 100% source")
assert_eq(shard[1].chance, 100, "unobserved shard chance")

-- Feature flag off -> vanilla again.
Config.OBSERVED_LEVELS = false
assert_eq(Materials:GetTopSources(10940, 2)[1].maxLevel, 25, "OBSERVED_LEVELS=false uses vanilla ranges")
Config.OBSERVED_LEVELS = true

if failures > 0 then
  print(string.format("\n%d test(s) failed", failures))
  os.exit(1)
end
print("\nAll observed level tests passed")
