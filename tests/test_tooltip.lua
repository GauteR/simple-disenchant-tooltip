-- Pure Lua tests for tooltip append dedupe (Auctionator refresh double-lines).
-- Run: lua tests/test_tooltip.lua

local root = arg[0]:match("^(.*)[/\\]") or "."
local addonRoot = root .. "/../simple-disenchant-tooltip"

dofile(addonRoot .. "/Config.lua")
dofile(addonRoot .. "/Locale/enUS.lua")
dofile(addonRoot .. "/Data/Tables.lua")
dofile(addonRoot .. "/Data/Materials.lua")
dofile(addonRoot .. "/Tooltip.lua")

function SimpleDisenchantTooltip:IsEnabled()
  return self.Config and self.Config.ENABLED == true
end

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

local Tooltip = SimpleDisenchantTooltip.Tooltip

local function NewMockTooltip()
  local lines = {}
  return {
    lines = lines,
    AddLine = function(self, text)
      self.lines[#self.lines + 1] = text
    end,
    AddDoubleLine = function(self, left, right)
      self.lines[#self.lines + 1] = left .. "|" .. tostring(right)
    end,
  }
end

-- Greater Magic Essence: two source lines + blank spacer.
local tip = NewMockTooltip()
Tooltip:AppendForItem(tip, 10939)
assert_eq(#tip.lines, 3, "first material append adds blank + two sources")
assert_true(tip.lines[2]:find("Weapons", 1, true) ~= nil, "first source is Weapons")
assert_true(tip.lines[3]:find("Armor", 1, true) ~= nil, "second source is Armor")

local afterFirst = #tip.lines
Tooltip:AppendForItem(tip, 10939)
assert_eq(#tip.lines, afterFirst, "second append for same show is a no-op")

Tooltip:ClearAppendState(tip)
Tooltip:AppendForItem(tip, 10939)
assert_eq(#tip.lines, afterFirst + 3, "after clear, material lines append again")

-- Different material without clear still appends (itemId-keyed flag).
local tipSwitch = NewMockTooltip()
Tooltip:AppendForItem(tipSwitch, 10939)
local switchCount = #tipSwitch.lines
Tooltip:AppendForItem(tipSwitch, 10940)
assert_true(#tipSwitch.lines > switchCount, "different itemId appends without clear")

-- Outcomes path also dedupes (stub GetOutcomesForItem for pure Lua).
local Materials = SimpleDisenchantTooltip.Materials
local realGetOutcomes = Materials.GetOutcomesForItem
function Materials:GetOutcomesForItem(itemId)
  if itemId == 999001 then
    return {
      { id = 10940, chance = 75, min = 1, max = 2 },
      { id = 10939, chance = 20, min = 1, max = 1 },
    }
  end
  return realGetOutcomes(self, itemId)
end

local gear = NewMockTooltip()
Tooltip:AppendForItem(gear, 999001)
assert_eq(#gear.lines, 3, "first gear append adds blank + two outcomes")
local gearCount = #gear.lines
Tooltip:AppendForItem(gear, 999001)
assert_eq(#gear.lines, gearCount, "second gear append is a no-op")
Tooltip:ClearAppendState(gear)
Tooltip:AppendForItem(gear, 999001)
assert_eq(#gear.lines, gearCount + 3, "after clear, gear lines append again")

Materials.GetOutcomesForItem = realGetOutcomes

-- Given an Enchanting wand, when tooltip is built, then only a grey notice is shown.
local wand = NewMockTooltip()
Tooltip:AppendForItem(wand, 11287)
assert_eq(#wand.lines, 2, "non-DE wand adds blank + notice")
assert_eq(wand.lines[2], "Cannot be disenchanted", "wand shows cannot-disenchant text")
Tooltip:AppendForItem(wand, 11287)
assert_eq(#wand.lines, 2, "non-DE notice dedupes")

if failures > 0 then
  print(string.format("%d failure(s)", failures))
  os.exit(1)
end
print("All tooltip tests passed.")
