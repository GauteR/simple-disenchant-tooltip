-- Auctionator soft-dep: market prices and expected DE copper values.
Disenchanter = Disenchanter or {}
Disenchanter.Pricing = Disenchanter.Pricing or {}

local Pricing = Disenchanter.Pricing

-- Classic MoneyFrame coin textures (texture escape sequences).
local GOLD_ICON = "|TInterface\\MoneyFrame\\UI-GoldIcon:0:0:2:0|t"
local SILVER_ICON = "|TInterface\\MoneyFrame\\UI-SilverIcon:0:0:2:0|t"
local COPPER_ICON = "|TInterface\\MoneyFrame\\UI-CopperIcon:0:0:2:0|t"

Pricing.GOLD_ICON = GOLD_ICON
Pricing.SILVER_ICON = SILVER_ICON
Pricing.COPPER_ICON = COPPER_ICON

-- Format copper as "Ng Ns Nc" with icons; omit denominations that are 0.
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

  local parts = {}
  if gold > 0 then
    parts[#parts + 1] = tostring(gold) .. " " .. GOLD_ICON
  end
  if silver > 0 then
    parts[#parts + 1] = tostring(silver) .. " " .. SILVER_ICON
  end
  if copperPart > 0 then
    parts[#parts + 1] = tostring(copperPart) .. " " .. COPPER_ICON
  end
  if #parts == 0 then
    return nil
  end
  return table.concat(parts, " ")
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
  local callerId = (Disenchanter.Config and Disenchanter.Config.ADDON_NAME) or "Disenchanter"
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
