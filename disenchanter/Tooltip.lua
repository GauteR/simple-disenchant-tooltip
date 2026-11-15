-- Append disenchant source / outcome lines to item tooltips.
Disenchanter = Disenchanter or {}
Disenchanter.Tooltip = Disenchanter.Tooltip or {}

local Tooltip = Disenchanter.Tooltip

local HEADER_COLOR = { r = 0.2, g = 0.8, b = 1.0 }
local LINE_COLOR = { r = 0.85, g = 0.85, b = 0.85 }

-- Classic / comparison tooltips beyond GameTooltip + ItemRef.
local CLASSIC_TOOLTIP_NAMES = {
  "GameTooltip",
  "ItemRefTooltip",
  "ShoppingTooltip1",
  "ShoppingTooltip2",
  "EmbeddedItemTooltip",
}

local function QualityLabel(quality)
  if quality == "UNCOMMON" then
    return Disenchanter:T("QUALITY_UNCOMMON")
  elseif quality == "RARE" then
    return Disenchanter:T("QUALITY_RARE")
  elseif quality == "EPIC" then
    return Disenchanter:T("QUALITY_EPIC")
  end
  return quality
end

local function TypeLabel(itemType)
  if itemType == "ARMOR" then
    return Disenchanter:T("TYPE_ARMOR")
  elseif itemType == "WEAPON" then
    return Disenchanter:T("TYPE_WEAPON")
  elseif itemType == "ANY" then
    return Disenchanter:T("TYPE_ANY")
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
  return Disenchanter:T(
    "SOURCE_LINE_FMT",
    QualityLabel(source.quality),
    TypeLabel(source.itemType),
    source.minLevel,
    source.maxLevel,
    source.chance
  )
end

local function FormatOutcomeLine(outcome)
  local name = Disenchanter.Materials:GetMaterialName(outcome.id) or ("#" .. tostring(outcome.id))
  return Disenchanter:T(
    "OUTCOME_LINE_FMT",
    name,
    QtyText(outcome.min, outcome.max),
    outcome.chance
  )
end

-- Resolve item id from a tooltip frame (Retail-style data or classic GetItem).
local function ResolveItemId(tooltip, data)
  if data and data.id then
    return data.id
  end
  if tooltip and tooltip.GetItem then
    local _, link = tooltip:GetItem()
    if link and Disenchanter.Materials then
      return Disenchanter.Materials:ParseItemId(link)
    end
  end
  return nil
end

function Tooltip:AppendSources(tooltip, itemId)
  if not tooltip or not tooltip.AddLine then
    return false
  end
  local Config = Disenchanter.Config
  if not Config or Config.MATERIAL_SOURCES ~= true then
    return false
  end
  local Materials = Disenchanter.Materials
  if not Materials then
    return false
  end
  local entry = Materials:GetEntry(itemId)
  if not entry or not entry.sources then
    return false
  end

  tooltip:AddLine(" ")
  tooltip:AddLine(Disenchanter:T("TOOLTIP_HEADER_SOURCES"), HEADER_COLOR.r, HEADER_COLOR.g, HEADER_COLOR.b)
  for i = 1, #entry.sources do
    tooltip:AddLine(FormatSourceLine(entry.sources[i]), LINE_COLOR.r, LINE_COLOR.g, LINE_COLOR.b)
  end
  return true
end

function Tooltip:AppendOutcomes(tooltip, itemId)
  if not tooltip or not tooltip.AddLine then
    return false
  end
  local Config = Disenchanter.Config
  if not Config or Config.ITEM_OUTCOMES ~= true then
    return false
  end
  local Materials = Disenchanter.Materials
  if not Materials then
    return false
  end
  local outcomes = Materials:GetOutcomesForItem(itemId)
  if not outcomes or #outcomes == 0 then
    return false
  end

  tooltip:AddLine(" ")
  tooltip:AddLine(Disenchanter:T("TOOLTIP_HEADER_OUTCOMES"), HEADER_COLOR.r, HEADER_COLOR.g, HEADER_COLOR.b)
  for i = 1, #outcomes do
    tooltip:AddLine(FormatOutcomeLine(outcomes[i]), LINE_COLOR.r, LINE_COLOR.g, LINE_COLOR.b)
  end
  return true
end

function Tooltip:AppendForItem(tooltip, itemId)
  if not Disenchanter:IsEnabled() then
    return
  end
  if not itemId then
    return
  end
  -- Materials show farm sources; gear shows expected DE results.
  if not self:AppendSources(tooltip, itemId) then
    self:AppendOutcomes(tooltip, itemId)
  end
end

local function OnItemTooltip(tooltip, data)
  local itemId = ResolveItemId(tooltip, data)
  if itemId then
    Tooltip:AppendForItem(tooltip, itemId)
  end
end

local function HookClassicTooltip(frame)
  if not frame or frame._DisenchanterHooked then
    return
  end
  -- OnTooltipSetItem may be absent on some Forever builds; avoid hard error.
  local ok = pcall(function()
    frame:HookScript("OnTooltipSetItem", function(self)
      OnItemTooltip(self, nil)
    end)
  end)
  if ok then
    frame._DisenchanterHooked = true
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

  self.initialized = true
end
