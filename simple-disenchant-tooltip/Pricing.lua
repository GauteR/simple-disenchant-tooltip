-- Auctionator soft-dep: market prices and expected DE copper values.
SimpleDisenchantTooltip = SimpleDisenchantTooltip or {}
SimpleDisenchantTooltip.Pricing = SimpleDisenchantTooltip.Pricing or {}

local Pricing = SimpleDisenchantTooltip.Pricing

-- Classic MoneyFrame coin textures (texture escape sequences).
-- Size/offset match Auctionator padded money so icon↔digit spacing stays readable.
local GOLD_ICON = "|TInterface\\MoneyFrame\\UI-GoldIcon:12:12:0:0|t"
local SILVER_ICON = "|TInterface\\MoneyFrame\\UI-SilverIcon:12:12:0:0|t"
local COPPER_ICON = "|TInterface\\MoneyFrame\\UI-CopperIcon:12:12:0:0|t"
local LEFT_PAD = " "
local RIGHT_PAD = " "

Pricing.GOLD_ICON = GOLD_ICON
Pricing.SILVER_ICON = SILVER_ICON
Pricing.COPPER_ICON = COPPER_ICON

-- Format copper as "Ng Ns Nc" with icons; omit denominations that are 0.
-- Only denominations below the highest shown unit get a leading zero (two digits).
-- Spacing: "N|icon| N|icon|" (space after icon before next amount), like Auctionator.
-- Examples: 1c; 1s 01c; 1g 01s 01c.
function Pricing:FormatMoney(copper)
  if type(copper) ~= "number" or copper ~= copper then
    return nil
  end
  copper = math.floor(copper + 0.5)
  if copper <= 0 then
    return nil
  end

  local gold = math.floor(copper / 10000)
  local silver = math.floor((copper % 10000) / 100)
  local copperPart = copper % 100
  local showGold = gold > 0
  local showSilver = silver > 0
  local showCopper = copperPart > 0

  local parts = {}
  if showGold then
    local trail = (showSilver or showCopper) and RIGHT_PAD or ""
    parts[#parts + 1] = tostring(gold) .. LEFT_PAD .. GOLD_ICON .. trail
  end
  if showSilver then
    local silverText = showGold and string.format("%02d", silver) or tostring(silver)
    local trail = showCopper and RIGHT_PAD or ""
    parts[#parts + 1] = silverText .. LEFT_PAD .. SILVER_ICON .. trail
  end
  if showCopper then
    local copperText = (showGold or showSilver) and string.format("%02d", copperPart) or tostring(copperPart)
    parts[#parts + 1] = copperText .. LEFT_PAD .. COPPER_ICON
  end
  if #parts == 0 then
    return nil
  end
  return table.concat(parts, "")
end

-- Expected copper for one outcome: (chance/100) * avgQty * unitPrice.
function Pricing:ExpectedCopper(outcome, unitPrice)
  if type(outcome) ~= "table" then
    return nil
  end
  if type(unitPrice) ~= "number" or unitPrice <= 0 or unitPrice ~= unitPrice then
    return nil
  end
  local minQty = outcome.min or 1
  local maxQty = outcome.max or minQty
  if type(minQty) ~= "number" or type(maxQty) ~= "number" then
    return nil
  end
  local chance = outcome.chance or 0
  if type(chance) ~= "number" then
    return nil
  end
  local avgQty = (minQty + maxQty) / 2
  return (chance / 100) * avgQty * unitPrice
end

-- Soft dependency: last scanned Auctionator AH price in copper, or nil.
function Pricing:GetAuctionPrice(itemId)
  if type(itemId) ~= "number" then
    return nil
  end
  local api = Auctionator and Auctionator.API and Auctionator.API.v1
  local fn = api and api.GetAuctionPriceByItemID
  if type(fn) ~= "function" then
    return nil
  end
  local callerId = (SimpleDisenchantTooltip.Config and SimpleDisenchantTooltip.Config.ADDON_NAME) or "Simple Disenchant Tooltip"
  local ok, price = pcall(fn, callerId, itemId)
  if not ok or type(price) ~= "number" or price <= 0 then
    return nil
  end
  return price
end

-- Expected money string for an outcome line, or nil when price/API missing.
function Pricing:FormatOutcomeExpected(outcome)
  if not outcome then
    return nil
  end
  local unitPrice = self:GetAuctionPrice(outcome.id)
  local expected = self:ExpectedCopper(outcome, unitPrice)
  if not expected then
    return nil
  end
  return self:FormatMoney(expected)
end

-- Highest-chance outcome (ties keep first). Assumes caller may pre-sort.
function Pricing:MostLikelyOutcome(outcomes)
  if type(outcomes) ~= "table" or #outcomes == 0 then
    return nil
  end
  local best = outcomes[1]
  local bestChance = (best and best.chance) or -1
  for i = 2, #outcomes do
    local outcome = outcomes[i]
    local chance = (outcome and outcome.chance) or -1
    if chance > bestChance then
      best = outcome
      bestChance = chance
    end
  end
  return best
end

-- Expected copper for the most likely outcome, or nil when unpriced.
function Pricing:LikelyExpectedCopper(outcomes)
  local outcome = self:MostLikelyOutcome(outcomes)
  if not outcome then
    return nil
  end
  return self:ExpectedCopper(outcome, self:GetAuctionPrice(outcome.id))
end

-- Money string for the most likely outcome (Vendor/Auction Disenchant line).
function Pricing:FormatLikelyExpected(outcomes)
  return self:FormatOutcomeExpected(self:MostLikelyOutcome(outcomes))
end
