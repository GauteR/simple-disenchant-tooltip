-- Pure Lua tests for Auctionator pricing helpers.
-- Run: lua tests/test_pricing.lua

local root = arg[0]:match("^(.*)[/\\]") or "."
local addonRoot = root .. "/../simple-disenchant-tooltip"

dofile(addonRoot .. "/Config.lua")
dofile(addonRoot .. "/Pricing.lua")

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

local Pricing = SimpleDisenchantTooltip.Pricing
local G = Pricing.GOLD_ICON
local S = Pricing.SILVER_ICON
local C = Pricing.COPPER_ICON

assert_eq(SimpleDisenchantTooltip.Config.OUTCOME_PRICES, true, "OUTCOME_PRICES defaults true")

-- FormatMoney: omit zero denominations; pad silver/copper to two digits.
assert_eq(Pricing:FormatMoney(0), nil, "0 copper -> nil")
assert_eq(Pricing:FormatMoney(-1), nil, "negative -> nil")
assert_eq(Pricing:FormatMoney(nil), nil, "nil -> nil")
assert_eq(Pricing:FormatMoney(3), "03 " .. C, "3c only (padded)")
assert_eq(Pricing:FormatMoney(200), "02 " .. S, "2s only (0c omitted, padded)")
assert_eq(Pricing:FormatMoney(10000), "1 " .. G, "1g only")
assert_eq(
  Pricing:FormatMoney(10203),
  "1 " .. G .. " 02 " .. S .. " 03 " .. C,
  "1g 02s 03c"
)
assert_eq(Pricing:FormatMoney(10003), "1 " .. G .. " 03 " .. C, "1g 03c (0s omitted)")
assert_eq(Pricing:FormatMoney(1.4), "01 " .. C, "round down-ish 1.4 -> 01c")
assert_eq(Pricing:FormatMoney(1.5), "02 " .. C, "round 1.5 -> 02c")
assert_eq(Pricing:FormatMoney(69), "69 " .. C, "69c no leading zero needed")
assert_eq(Pricing:FormatMoney(1069), "10 " .. S .. " 69 " .. C, "10s 69c")

-- ExpectedCopper: chance * avgQty * unitPrice.
local dust = { id = 10940, chance = 75, min = 2, max = 3 }
-- avgQty = 2.5, chance = 0.75, price = 100 -> 187.5
assert_eq(Pricing:ExpectedCopper(dust, 100), 187.5, "dust expected copper")
assert_eq(Pricing:ExpectedCopper(dust, nil), nil, "nil unit price")
assert_eq(Pricing:ExpectedCopper(dust, 0), nil, "zero unit price")
assert_eq(Pricing:ExpectedCopper(nil, 100), nil, "nil outcome")

local shard = { id = 10978, chance = 5, min = 1, max = 1 }
assert_eq(Pricing:ExpectedCopper(shard, 10000), 500, "5% of 1g shard")

-- Soft dep without Auctionator -> nil price.
Auctionator = nil
assert_eq(Pricing:GetAuctionPrice(10940), nil, "no Auctionator -> nil")

-- Mock Auctionator API.
Auctionator = {
  API = {
    v1 = {
      GetAuctionPriceByItemID = function(caller, itemId)
        assert_eq(caller, "Simple Disenchant Tooltip", "callerID is Simple Disenchant Tooltip")
        if itemId == 10940 then
          return 250
        end
        return nil
      end,
    },
  },
}
assert_eq(Pricing:GetAuctionPrice(10940), 250, "mock AH price")
assert_eq(Pricing:GetAuctionPrice(99999), nil, "unknown item nil")

local money = Pricing:FormatOutcomeExpected(dust)
-- expected = 0.75 * 2.5 * 250 = 468.75 -> 469c = 4s 69c
assert_eq(money, "04 " .. S .. " 69 " .. C, "FormatOutcomeExpected dust")

-- Most likely outcome value (not sum of all).
local essence = { id = 10938, chance = 20, min = 1, max = 2 }
Auctionator.API.v1.GetAuctionPriceByItemID = function(caller, itemId)
  assert_eq(caller, "Simple Disenchant Tooltip", "callerID is Simple Disenchant Tooltip (likely)")
  if itemId == 10940 then
    return 250
  end
  if itemId == 10938 then
    return 100
  end
  return nil
end
-- dust chance 75 > essence 20 -> dust EV 468.75 (ignore essence 30)
assert_eq(Pricing:MostLikelyOutcome({ essence, dust }).id, 10940, "most likely is dust")
assert_eq(Pricing:LikelyExpectedCopper({ essence, dust, shard }), 468.75, "likely expected copper")
assert_eq(Pricing:LikelyExpectedCopper({ shard }), nil, "unpriced most-likely -> nil")
assert_eq(Pricing:LikelyExpectedCopper(nil), nil, "nil outcomes -> nil")
assert_eq(
  Pricing:FormatLikelyExpected({ essence, dust }),
  "04 " .. S .. " 69 " .. C,
  "FormatLikelyExpected uses dust not sum"
)

if failures > 0 then
  print(string.format("%d failure(s)", failures))
  os.exit(1)
end
print("All pricing tests passed.")
