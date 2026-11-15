-- Pure Lua tests for material lookup and link parsing.
-- Run: lua tests/test_materials.lua

local root = arg[0]:match("^(.*)[/\\]") or "."
local addonRoot = root .. "/../disenchanter"

dofile(addonRoot .. "/Config.lua")
dofile(addonRoot .. "/Locale/enUS.lua")
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

assert_eq(Disenchanter.Config.ENABLED, true, "Config.ENABLED defaults true")
assert_eq(Disenchanter.Config.SLASH_COMMAND, "/disenchanter", "slash command")

assert_true(Materials:IsTracked(10940), "Strange Dust tracked")
assert_true(Materials:IsTracked(20725), "Nexus Crystal tracked")
assert_true(not Materials:IsTracked(2589), "Linen Cloth not tracked")

local strange = Materials:GetEntry(10940)
assert_true(strange ~= nil, "Strange Dust entry exists")
assert_eq(strange.sources[1].quality, "UNCOMMON", "Strange Dust primary quality")
assert_eq(strange.sources[1].itemType, "ARMOR", "Strange Dust primary type")
assert_eq(strange.sources[1].minLevel, 5, "Strange Dust minLevel")
assert_eq(strange.sources[1].maxLevel, 25, "Strange Dust maxLevel")
assert_true(strange.sources[2].secondary == true, "Strange Dust weapon source secondary")

local essence = Materials:GetEntry(10939)
assert_eq(essence.sources[1].itemType, "WEAPON", "Greater Magic primary weapon")
assert_eq(essence.sources[1].minLevel, 16, "Greater Magic minLevel")
assert_eq(essence.sources[1].maxLevel, 20, "Greater Magic maxLevel")

local shard = Materials:GetEntry(14344)
assert_eq(shard.sources[1].quality, "RARE", "Large Brilliant primary rare")
assert_eq(shard.sources[1].itemType, "ANY", "Large Brilliant any gear")
assert_eq(shard.sources[1].minLevel, 56, "Large Brilliant minLevel")
assert_eq(shard.sources[1].maxLevel, 65, "Large Brilliant maxLevel")

local crystal = Materials:GetEntry(20725)
assert_eq(crystal.sources[1].quality, "EPIC", "Nexus Crystal epic")
assert_eq(#crystal.sources, 1, "Nexus Crystal single primary source")

assert_eq(Materials:ParseItemId("|cffffffff|Hitem:10940::::::::|h[Strange Dust]|h|r"), 10940, "parse colored link")
assert_eq(Materials:ParseItemId("item:16204:0:0:0"), 16204, "parse raw item string")
assert_eq(Materials:ParseItemId(nil), nil, "parse nil")
assert_eq(Materials:ParseItemId("not-an-item"), nil, "parse invalid")

-- Locale formatting used by tooltip lines
local line = Disenchanter:T("SOURCE_LINE_FMT", "Uncommon", "Armor", 5, 25)
assert_eq(line, "• Uncommon Armor, item level 5–25", "SOURCE_LINE_FMT")

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
