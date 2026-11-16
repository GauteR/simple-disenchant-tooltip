-- Pure Lua tests for TSM / Auctionator pricing helpers.
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

local Pricing = SimpleDisenchantTooltip.Pricing
local G = Pricing.GOLD_ICON
local S = Pricing.SILVER_ICON
local C = Pricing.COPPER_ICON

assert_eq(SimpleDisenchantTooltip.Config.OUTCOME_PRICES, true, "OUTCOME_PRICES defaults true")
assert_eq(SimpleDisenchantTooltip.Config.TSM_PRICE_SOURCE, "DBMarket", "TSM_PRICE_SOURCE defaults DBMarket")

-- FormatMoney: omit zero denominations; pad only below highest shown unit.
assert_eq(Pricing:FormatMoney(0), nil, "0 copper -> nil")
assert_eq(Pricing:FormatMoney(-1), nil, "negative -> nil")
assert_eq(Pricing:FormatMoney(nil), nil, "nil -> nil")
assert_eq(Pricing:FormatMoney(1), "1 " .. C, "1c only (no pad)")
assert_eq(Pricing:FormatMoney(3), "3 " .. C, "3c only (no pad)")
assert_eq(Pricing:FormatMoney(200), "2 " .. S, "2s only (0c omitted, no pad)")
assert_eq(Pricing:FormatMoney(101), "1 " .. S .. " 01 " .. C, "1s 01c")
assert_eq(Pricing:FormatMoney(10000), "1 " .. G, "1g only")
assert_eq(
  Pricing:FormatMoney(10101),
  "1 " .. G .. " 01 " .. S .. " 01 " .. C,
  "1g 01s 01c"
)
assert_eq(
  Pricing:FormatMoney(10203),
  "1 " .. G .. " 02 " .. S .. " 03 " .. C,
  "1g 02s 03c"
)
assert_eq(Pricing:FormatMoney(10003), "1 " .. G .. " 03 " .. C, "1g 03c (0s omitted)")
assert_eq(Pricing:FormatMoney(10200), "1 " .. G .. " 02 " .. S, "1g 02s (0c omitted)")
assert_eq(Pricing:FormatMoney(1.4), "1 " .. C, "round down-ish 1.4 -> 1c")
assert_eq(Pricing:FormatMoney(1.5), "2 " .. C, "round 1.5 -> 2c")
assert_eq(Pricing:FormatMoney(69), "69 " .. C, "69c alone unpadded")
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

-- Soft dep without TSM / Auctionator -> nil price.
TSM_API = nil
Auctionator = nil
assert_eq(Pricing:GetTSMPrice(10940), nil, "no TSM -> nil")
assert_eq(Pricing:GetAuctionPrice(10940), nil, "no Auctionator -> nil")
assert_eq(Pricing:GetUnitPrice(10940), nil, "no price sources -> nil")

-- Mock Auctionator API only.
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
assert_eq(Pricing:GetUnitPrice(10940), 250, "unit price falls back to Auctionator")

local money = Pricing:FormatOutcomeExpected(dust)
-- expected = 0.75 * 2.5 * 250 = 468.75 -> 469c = 4s 69c
assert_eq(money, "4 " .. S .. " 69 " .. C, "FormatOutcomeExpected dust via Auctionator")

-- Mock TSM: preferred over Auctionator when both exist.
TSM_API = {
  ToItemString = function(link)
    local id = tostring(link):match("item:(%d+)")
    if id then
      return "i:" .. id
    end
    return nil
  end,
  GetCustomPriceValue = function(source, itemString)
    assert_eq(source, "DBMarket", "uses Config TSM_PRICE_SOURCE")
    if itemString == "i:10940" then
      return 400
    end
    if itemString == "i:10938" then
      return 50
    end
    return nil
  end,
}
assert_eq(Pricing:GetTSMPrice(10940), 400, "mock TSM DBMarket")
assert_eq(Pricing:GetUnitPrice(10940), 400, "TSM preferred over Auctionator")
assert_eq(
  Pricing:FormatOutcomeExpected(dust),
  "7 " .. S .. " 50 " .. C,
  "FormatOutcomeExpected dust via TSM (0.75*2.5*400=750)"
)

-- Most likely outcome value (not sum of all); TSM prices.
local essence = { id = 10938, chance = 20, min = 1, max = 2 }
-- dust chance 75 > essence 20 -> dust EV 750
assert_eq(Pricing:MostLikelyOutcome({ essence, dust }).id, 10940, "most likely is dust")
assert_eq(Pricing:LikelyExpectedCopper({ essence, dust, shard }), 750, "likely expected copper via TSM")
assert_eq(Pricing:LikelyExpectedCopper({ shard }), nil, "unpriced most-likely -> nil")
assert_eq(Pricing:LikelyExpectedCopper(nil), nil, "nil outcomes -> nil")
assert_eq(
  Pricing:FormatLikelyExpected({ essence, dust }),
  "7 " .. S .. " 50 " .. C,
  "FormatLikelyExpected uses dust not sum"
)

-- TSM missing price falls back to Auctionator for that item.
TSM_API.GetCustomPriceValue = function(source, itemString)
  return nil
end
assert_eq(Pricing:GetUnitPrice(10940), 250, "TSM nil -> Auctionator fallback")

-- Price source from Config is passed through.
SimpleDisenchantTooltip.Config.TSM_PRICE_SOURCE = "DBMinBuyout"
local seenSource = nil
TSM_API.GetCustomPriceValue = function(source, itemString)
  seenSource = source
  if itemString == "i:10940" then
    return 111
  end
  return nil
end
assert_eq(Pricing:GetTSMPrice(10940), 111, "custom source returns price")
assert_eq(seenSource, "DBMinBuyout", "honors Config.TSM_PRICE_SOURCE")
SimpleDisenchantTooltip.Config.TSM_PRICE_SOURCE = "DBMarket"

if failures > 0 then
  print(string.format("%d failure(s)", failures))
  os.exit(1)
end
print("All pricing tests passed.")
