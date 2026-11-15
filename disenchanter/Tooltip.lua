-- Append Vanilla Classic disenchant source lines to item tooltips.
Disenchanter = Disenchanter or {}
Disenchanter.Tooltip = Disenchanter.Tooltip or {}

local Tooltip = Disenchanter.Tooltip

local HEADER_COLOR = { r = 0.2, g = 0.8, b = 1.0 }
local LINE_COLOR = { r = 0.85, g = 0.85, b = 0.85 }
local SECONDARY_COLOR = { r = 0.65, g = 0.65, b = 0.65 }

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

local function FormatSourceLine(source)
  local line = Disenchanter:T(
    "SOURCE_LINE_FMT",
    QualityLabel(source.quality),
    TypeLabel(source.itemType),
    source.minLevel,
    source.maxLevel
  )
  if source.secondary then
    line = line .. Disenchanter:T("SOURCE_SECONDARY_SUFFIX")
  end
  return line
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
    return
  end
  if not Disenchanter:IsEnabled() then
    return
  end
  local Materials = Disenchanter.Materials
  if not Materials then
    return
  end
  local entry = Materials:GetEntry(itemId)
  if not entry or not entry.sources then
    return
  end

  tooltip:AddLine(" ")
  tooltip:AddLine(Disenchanter:T("TOOLTIP_HEADER"), HEADER_COLOR.r, HEADER_COLOR.g, HEADER_COLOR.b)
  for i = 1, #entry.sources do
    local source = entry.sources[i]
    local color = source.secondary and SECONDARY_COLOR or LINE_COLOR
    tooltip:AddLine(FormatSourceLine(source), color.r, color.g, color.b)
  end
end

local function OnItemTooltip(tooltip, data)
  local itemId = ResolveItemId(tooltip, data)
  if itemId then
    Tooltip:AppendSources(tooltip, itemId)
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

  -- Forever may expose Retail tooltip processors; fall back to classic hooks.
  if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall and Enum and Enum.TooltipDataType and Enum.TooltipDataType.Item then
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, OnItemTooltip)
  else
    if GameTooltip then
      HookClassicTooltip(GameTooltip)
    end
    if ItemRefTooltip then
      HookClassicTooltip(ItemRefTooltip)
    end
  end

  self.initialized = true
end
