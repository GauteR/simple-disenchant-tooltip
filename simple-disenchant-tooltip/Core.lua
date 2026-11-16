-- Addon bootstrap: slash command and tooltip/options init.
SimpleDisenchantTooltip = SimpleDisenchantTooltip or {}

local function Print(message)
  if DEFAULT_CHAT_FRAME then
    local prefix = (SimpleDisenchantTooltip.L and SimpleDisenchantTooltip.L.CHAT_PREFIX) or "|cff33ff99Simple Disenchant Tooltip|r: "
    DEFAULT_CHAT_FRAME:AddMessage(prefix .. message)
  end
end

function SimpleDisenchantTooltip:IsEnabled()
  return self.Config and self.Config.ENABLED == true
end

function SimpleDisenchantTooltip:PrintStatus()
  if self:IsEnabled() then
    Print(self:T("CHAT_STATUS_ON"))
  else
    Print(self:T("CHAT_STATUS_OFF"))
  end
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:SetScript("OnEvent", function(_, event)
  if event ~= "PLAYER_LOGIN" then
    return
  end
  if not SimpleDisenchantTooltip:IsEnabled() then
    Print(SimpleDisenchantTooltip:T("CHAT_DISABLED"))
    return
  end

  SLASH_SIMPLEDISENCHANTTOOLTIP1 = (SimpleDisenchantTooltip.Config and SimpleDisenchantTooltip.Config.SLASH_COMMAND) or "/sdt"
  SlashCmdList["SIMPLEDISENCHANTTOOLTIP"] = function()
    SimpleDisenchantTooltip:PrintStatus()
  end

  if SimpleDisenchantTooltip.Tooltip and SimpleDisenchantTooltip.Tooltip.Initialize then
    SimpleDisenchantTooltip.Tooltip:Initialize()
  end

  if SimpleDisenchantTooltip.Options and SimpleDisenchantTooltip.Options.Initialize then
    SimpleDisenchantTooltip.Options:Initialize()
  end

  --Print(SimpleDisenchantTooltip:T("CHAT_LOADED"))
end)
