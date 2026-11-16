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

local top = Materials:GetTopSources(10940, 2)
assert_true(top ~= nil, "Strange Dust top sources")
assert_eq(#top, 2, "Strange Dust returns two source lines")
assert_eq(top[1].quality, "UNCOMMON", "Strange Dust #1 quality")
assert_eq(top[1].itemType, "ARMOR", "Strange Dust #1 armor (highest)")
assert_eq(top[1].minLevel, 5, "Strange Dust armor merged min")
assert_eq(top[1].maxLevel, 25, "Strange Dust armor merged max")
assert_eq(top[1].chance, 80, "Strange Dust armor chance")
assert_eq(top[2].itemType, "WEAPON", "Strange Dust #2 weapon")
assert_eq(top[2].chance, 20, "Strange Dust weapon chance")
assert_true(top[1].chance >= top[2].chance, "sources sorted by chance")

local shardTop = Materials:GetTopSources(10978, 2)
assert_eq(shardTop[1].quality, "RARE", "Small Glimmering #1 rare")
assert_eq(shardTop[1].chance, 100, "Small Glimmering rare chance")
assert_eq(shardTop[2].quality, "UNCOMMON", "Small Glimmering #2 uncommon")
assert_eq(shardTop[2].chance, 10, "Small Glimmering uncommon max chance")

local armorOut = Materials:GetOutcomesForStats("UNCOMMON", "ARMOR", 18)
local sorted = Materials:SortOutcomesByChance(armorOut)
assert_eq(#sorted, 3, "Armor 18 has three outcomes")
assert_eq(sorted[1].id, 10940, "Armor 18 first Strange Dust")
assert_eq(sorted[1].chance, 75, "Armor 18 dust 75%")
assert_eq(sorted[2].chance, 20, "Armor 18 essence 20%")
assert_eq(sorted[3].chance, 5, "Armor 18 shard 5%")

local r1, g1 = Materials:ChanceColor(80)
assert_true(g1 > 0.9 and r1 < 0.3, "80% is green")
local r2, g2 = Materials:ChanceColor(50)
assert_true(r2 > 0.9 and g2 > 0.7, "50% is yellow")
local r3, g3, b3 = Materials:ChanceColor(10)
assert_true(r3 < 0.7 and g3 < 0.7 and b3 < 0.7, "10% is gray")

assert_eq(Materials:ClassifyItemType("Armor", "INVTYPE_SHIELD"), "WEAPON", "shield as weapon")
assert_eq(Tables:GetMaterialName(16204), "Illusion Dust", "material name")

local line = Disenchanter:T("SOURCE_LINE_FMT", "Uncommon", "Armor", 5, 25)
assert_eq(line, "Uncommon Armor, item level 5–25", "SOURCE_LINE_FMT")
local outLine = Disenchanter:T("OUTCOME_LINE_FMT", "Strange Dust", "2–3")
assert_eq(outLine, "Strange Dust 2–3", "OUTCOME_LINE_FMT")
assert_eq(Disenchanter:T("DISENCHANT_TOTAL"), "Disenchant", "DISENCHANT_TOTAL label")
assert_eq(Disenchanter.Config.OUTCOME_PRICES, true, "OUTCOME_PRICES defaults true")

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
