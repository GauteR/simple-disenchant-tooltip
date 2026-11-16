-- Append disenchant source / outcome lines to item tooltips.
SimpleDisenchantTooltip = SimpleDisenchantTooltip or {}
SimpleDisenchantTooltip.Tooltip = SimpleDisenchantTooltip.Tooltip or {}

local Tooltip = SimpleDisenchantTooltip.Tooltip

-- Classic / comparison tooltips beyond GameTooltip + ItemRef.
local CLASSIC_TOOLTIP_NAMES = {
  "GameTooltip",
  "ItemRefTooltip",
  "ShoppingTooltip1",
  "ShoppingTooltip2",
  "EmbeddedItemTooltip",
}

local APPENDED_FLAG = "_SimpleDisenchantTooltipAppended"

local function QualityLabel(quality)
  if quality == "UNCOMMON" then
    return SimpleDisenchantTooltip:T("QUALITY_UNCOMMON")
  elseif quality == "RARE" then
    return SimpleDisenchantTooltip:T("QUALITY_RARE")
  elseif quality == "EPIC" then
    return SimpleDisenchantTooltip:T("QUALITY_EPIC")
  end
  return quality
end

local function TypeLabel(itemType)
  if itemType == "ARMOR" then
    return SimpleDisenchantTooltip:T("TYPE_ARMOR")
  elseif itemType == "WEAPON" then
    return SimpleDisenchantTooltip:T("TYPE_WEAPON")
  elseif itemType == "ANY" then
    return SimpleDisenchantTooltip:T("TYPE_ANY")
  end
  return itemType
end

local function QtyText(minQty, maxQty)
  if not minQty then
    return ""
  end
  if not maxQty or maxQty == minQty then
    return tostring(minQty)
  end
  return string.format("%d–%d", minQty, maxQty)
end

local function FormatSourceLine(source)
  return SimpleDisenchantTooltip:T(
    "SOURCE_LINE_FMT",
    QualityLabel(source.quality),
    TypeLabel(source.itemType),
    source.minLevel,
    source.maxLevel
  )
end

local function FormatOutcomeLine(outcome)
  local name = SimpleDisenchantTooltip.Materials:GetMaterialName(outcome.id) or ("#" .. tostring(outcome.id))
  local qty = QtyText(outcome.min, outcome.max)
  return SimpleDisenchantTooltip:T("OUTCOME_LINE_FMT", name, qty)
end

-- Resolve item id from a tooltip frame (Retail-style data or classic GetItem).
local function ResolveItemId(tooltip, data)
  if data and data.id then
    return data.id
  end
  if tooltip and tooltip.GetItem then
    local _, link = tooltip:GetItem()
    if link and SimpleDisenchantTooltip.Materials then
      return SimpleDisenchantTooltip.Materials:ParseItemId(link)
    end
  end
  return nil
end

-- Reset after Auctionator / client rebuild so the next show can append once.
function Tooltip:ClearAppendState(tooltip)
  if tooltip then
    tooltip[APPENDED_FLAG] = nil
  end
end

-- True when this frame already got DE lines for the same itemId this show.
local function HasAppended(tooltip, itemId)
  return tooltip and itemId and tooltip[APPENDED_FLAG] == itemId
end

local function MarkAppended(tooltip, itemId)
  if tooltip and itemId then
    tooltip[APPENDED_FLAG] = itemId
  end
end

function Tooltip:AppendSources(tooltip, itemId)
  if not tooltip or not tooltip.AddLine then
    return false
  end
  local Config = SimpleDisenchantTooltip.Config
  if not Config or Config.MATERIAL_SOURCES ~= true then
    return false
  end
  local Materials = SimpleDisenchantTooltip.Materials
  if not Materials then
    return false
  end
  -- Top two farm lines (highest + second); color by chance tier.
  local sources = Materials:GetTopSources(itemId, 2)
  if not sources then
    return false
  end

  tooltip:AddLine(" ")
  for i = 1, #sources do
    local source = sources[i]
    local r, g, b = Materials:ChanceColor(source.chance)
    tooltip:AddLine(FormatSourceLine(source), r, g, b)
  end
  return true
end

function Tooltip:AppendOutcomes(tooltip, itemId)
  if not tooltip or not tooltip.AddLine then
    return false
  end
  local Config = SimpleDisenchantTooltip.Config
  if not Config or Config.ITEM_OUTCOMES ~= true then
    return false
  end
  local Materials = SimpleDisenchantTooltip.Materials
  if not Materials then
    return false
  end
  local outcomes = Materials:SortOutcomesByChance(Materials:GetOutcomesForItem(itemId))
  if not outcomes then
    return false
  end

  tooltip:AddLine(" ")
  for i = 1, #outcomes do
    local outcome = outcomes[i]
    local r, g, b = Materials:ChanceColor(outcome.chance)
    tooltip:AddLine(FormatOutcomeLine(outcome), r, g, b)
  end

  -- Yellow label + white money: most likely outcome EV (not sum of all).
  if Config.OUTCOME_PRICES == true and SimpleDisenchantTooltip.Pricing and tooltip.AddDoubleLine then
    local money = SimpleDisenchantTooltip.Pricing:FormatLikelyExpected(outcomes)
    if money then
      local yr, yg, yb = 1, 0.82, 0
      tooltip:AddDoubleLine(SimpleDisenchantTooltip:T("DISENCHANT_TOTAL"), money, yr, yg, yb, 1, 1, 1)
    end
  end
  return true
end

function Tooltip:AppendForItem(tooltip, itemId)
  if not SimpleDisenchantTooltip:IsEnabled() then
    return
  end
  if not itemId then
    return
  end
  -- Skip re-entry for the same item this show (e.g. Auctionator price refresh).
  if HasAppended(tooltip, itemId) then
    return
  end
  -- Materials: top two sources; gear: all expected DE results.
  local appended = self:AppendSources(tooltip, itemId)
  if not appended then
    appended = self:AppendOutcomes(tooltip, itemId)
  end
  if appended then
    MarkAppended(tooltip, itemId)
  end
end

local function OnItemTooltip(tooltip, data)
  local itemId = ResolveItemId(tooltip, data)
  if itemId then
    Tooltip:AppendForItem(tooltip, itemId)
  end
end

local function HookClassicTooltip(frame)
  if not frame or frame._SimpleDisenchantTooltipHooked then
    return
  end
  -- OnTooltipSetItem may be absent on some Forever builds; avoid hard error.
  local ok = pcall(function()
    frame:HookScript("OnTooltipSetItem", function(self)
      OnItemTooltip(self, nil)
    end)
  end)
  if ok then
    frame._SimpleDisenchantTooltipHooked = true
  end
end

-- Allow a fresh append after the tooltip is cleared or hidden.
local function HookTooltipLifecycle(frame)
  if not frame or frame._SimpleDisenchantTooltipClearHooked then
    return
  end
  local function clear()
    Tooltip:ClearAppendState(frame)
  end
  local clearedOk = pcall(function()
    frame:HookScript("OnTooltipCleared", clear)
  end)
  local hideOk = pcall(function()
    frame:HookScript("OnHide", clear)
  end)
  if clearedOk or hideOk then
    frame._SimpleDisenchantTooltipClearHooked = true
  end
end

function Tooltip:Initialize()
  if self.initialized then
    return
  end

  -- Prefer TooltipDataProcessor (covers GameTooltip, ItemRef, shopping, etc.).
  -- Fall back to classic OnTooltipSetItem on all known item tooltip frames.
  if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall and Enum and Enum.TooltipDataType and Enum.TooltipDataType.Item then
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, OnItemTooltip)
  else
    for i = 1, #CLASSIC_TOOLTIP_NAMES do
      local frame = _G[CLASSIC_TOOLTIP_NAMES[i]]
      if frame then
        HookClassicTooltip(frame)
      end
    end
  end

  -- Clear hooks on both paths so rebuilds can append exactly once again.
  for i = 1, #CLASSIC_TOOLTIP_NAMES do
    local frame = _G[CLASSIC_TOOLTIP_NAMES[i]]
    if frame then
      HookTooltipLifecycle(frame)
    end
  end

  self.initialized = true
end
