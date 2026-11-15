-- Pure Lua tests for material lookup, outcomes, and link parsing.
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
assert_eq(Disenchanter.Config.ITEM_OUTCOMES, true, "Config.ITEM_OUTCOMES defaults true")
assert_eq(Disenchanter.Config.MATERIAL_SOURCES, true, "Config.MATERIAL_SOURCES defaults true")
assert_eq(Disenchanter.Config.SLASH_COMMAND, "/disenchanter", "slash command")

assert_true(Materials:IsTracked(10940), "Strange Dust tracked")
assert_true(Materials:IsTracked(20725), "Nexus Crystal tracked")
assert_true(not Materials:IsTracked(2589), "Linen Cloth not tracked")

local strange = Materials:GetEntry(10940)
assert_true(strange ~= nil, "Strange Dust entry exists")
assert_true(#strange.sources >= 2, "Strange Dust has multiple source bands")
assert_eq(strange.sources[1].chance, 80, "Strange Dust first band chance 80")
assert_eq(strange.sources[1].quality, "UNCOMMON", "Strange Dust quality")
assert_eq(strange.sources[1].itemType, "ARMOR", "Strange Dust first type armor")

local armorOut = Materials:GetOutcomesForStats("UNCOMMON", "ARMOR", 18)
assert_true(armorOut ~= nil, "Uncommon armor ilvl 18 has outcomes")
assert_eq(armorOut[1].id, 10940, "Armor 18 primary Strange Dust")
assert_eq(armorOut[1].chance, 75, "Armor 18 Strange Dust 75%")
assert_eq(armorOut[2].id, 10939, "Armor 18 Greater Magic")
assert_eq(armorOut[3].chance, 5, "Armor 18 shard 5%")

local weaponOut = Materials:GetOutcomesForStats("UNCOMMON", "WEAPON", 18)
assert_eq(weaponOut[1].id, 10939, "Weapon 18 primary Greater Magic")
assert_eq(weaponOut[1].chance, 75, "Weapon 18 essence 75%")

local rareOut = Materials:GetOutcomesForStats("RARE", "ARMOR", 52)
assert_eq(rareOut[1].id, 14343, "Rare 52 Small Brilliant Shard")
assert_eq(rareOut[1].chance, 100, "Rare shard 100%")

local epicOut = Materials:GetOutcomesForStats("EPIC", "WEAPON", 60)
assert_eq(epicOut[1].id, 20725, "Epic 60 Nexus Crystal")
assert_eq(epicOut[1].chance, 100, "Epic crystal 100%")

assert_eq(Materials:GetOutcomesForStats("UNCOMMON", "ARMOR", 1), nil, "ilvl 1 no outcomes")
assert_eq(Tables:GetMaterialName(16204), "Illusion Dust", "material name")

assert_eq(Materials:ClassifyItemType("Armor", "INVTYPE_CHEST"), "ARMOR", "chest armor")
assert_eq(Materials:ClassifyItemType("Armor", "INVTYPE_SHIELD"), "WEAPON", "shield as weapon")
assert_eq(Materials:ClassifyItemType("Weapon", "INVTYPE_2HWEAPON"), "WEAPON", "2H weapon")
assert_eq(Materials:QualityKey(2), "UNCOMMON", "quality 2")
assert_eq(Materials:QualityKey(4), "EPIC", "quality 4")

assert_eq(Materials:ParseItemId("|cffffffff|Hitem:10940::::::::|h[Strange Dust]|h|r"), 10940, "parse colored link")
assert_eq(Materials:ParseItemId("item:16204:0:0:0"), 16204, "parse raw item string")
assert_eq(Materials:ParseItemId(nil), nil, "parse nil")
assert_eq(Materials:ParseItemId("not-an-item"), nil, "parse invalid")

local line = Disenchanter:T("SOURCE_LINE_FMT", "Uncommon", "Armor", 5, 15, 80)
assert_eq(line, "• Uncommon Armor, item level 5–15 — 80%", "SOURCE_LINE_FMT")
local outLine = Disenchanter:T("OUTCOME_LINE_FMT", "Strange Dust", "1–2", 80)
assert_eq(outLine, "• Strange Dust 1–2 — 80%", "OUTCOME_LINE_FMT")

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
