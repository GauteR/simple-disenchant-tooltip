-- Pure Lua tests for material lookup, outcomes, and display helpers.
-- Run: lua tests/test_materials.lua

local root = arg[0]:match("^(.*)[/\\]") or "."
local addonRoot = root .. "/../disenchanter"

dofile(addonRoot .. "/Config.lua")
dofile(addonRoot .. "/Locale/enUS.lua")
dofile(addonRoot .. "/Data/Tables.lua")
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

local function assert_true(condition, message)
  if not condition then
    failures = failures + 1
    print("FAIL: " .. message)
  else
    print("PASS: " .. message)
  end
end

local Materials = Disenchanter.Materials
local Tables = Disenchanter.Tables

assert_eq(Disenchanter.Config.ENABLED, true, "Config.ENABLED defaults true")
assert_eq(Disenchanter.Config.CHANCE_GREEN, 75, "CHANCE_GREEN")
assert_eq(Disenchanter.Config.CHANCE_YELLOW, 35, "CHANCE_YELLOW")

assert_true(Materials:IsTracked(10940), "Strange Dust tracked")
assert_true(not Materials:IsTracked(2589), "Linen Cloth not tracked")

local primary = Materials:GetPrimarySource(10940)
assert_true(primary ~= nil, "Strange Dust primary source")
assert_eq(primary.quality, "UNCOMMON", "Strange Dust primary quality")
assert_eq(primary.itemType, "ARMOR", "Strange Dust primary type")
assert_eq(primary.minLevel, 5, "Strange Dust merged minLevel")
assert_eq(primary.maxLevel, 25, "Strange Dust merged maxLevel")
assert_eq(primary.chance, 80, "Strange Dust primary chance")

local shardPrimary = Materials:GetPrimarySource(10978)
assert_eq(shardPrimary.quality, "RARE", "Small Glimmering prefers rare")
assert_eq(shardPrimary.chance, 100, "Small Glimmering rare chance")
assert_eq(shardPrimary.minLevel, 16, "Small Glimmering min")
assert_eq(shardPrimary.maxLevel, 25, "Small Glimmering max")

local armorOut = Materials:GetOutcomesForStats("UNCOMMON", "ARMOR", 18)
local armorPrimary = Materials:GetPrimaryOutcome(armorOut)
assert_eq(armorPrimary.id, 10940, "Armor 18 primary Strange Dust")
assert_eq(armorPrimary.chance, 75, "Armor 18 primary 75%")

local r1, g1, b1 = Materials:ChanceColor(80)
assert_true(g1 > 0.9 and r1 < 0.3, "80% is green")
local r2, g2, b2 = Materials:ChanceColor(50)
assert_true(r2 > 0.9 and g2 > 0.7, "50% is yellow")
local r3, g3, b3 = Materials:ChanceColor(10)
assert_true(r3 < 0.7 and g3 < 0.7 and b3 < 0.7, "10% is gray")

assert_eq(Materials:ClassifyItemType("Armor", "INVTYPE_SHIELD"), "WEAPON", "shield as weapon")
assert_eq(Tables:GetMaterialName(16204), "Illusion Dust", "material name")

local line = Disenchanter:T("SOURCE_LINE_FMT", "Uncommon", "Armor", 5, 25)
assert_eq(line, "Disenchant: Uncommon Armor, item level 5–25", "SOURCE_LINE_FMT")
local outLine = Disenchanter:T("OUTCOME_LINE_FMT", "Strange Dust", "2–3")
assert_eq(outLine, "Disenchant: Strange Dust 2–3", "OUTCOME_LINE_FMT")

local count = 0
for _ in pairs(Materials.BY_ID) do
  count = count + 1
end
assert_eq(count, 24, "24 Vanilla enchanting materials tracked")

if failures > 0 then
  print(string.format("%d failure(s)", failures))
  os.exit(1)
end
print("All tests passed.")
