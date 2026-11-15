-- Addon bootstrap: slash command and tooltip/options init.
Disenchanter = Disenchanter or {}

local function Print(message)
  if DEFAULT_CHAT_FRAME then
    local prefix = (Disenchanter.L and Disenchanter.L.CHAT_PREFIX) or "|cff33ff99Disenchanter|r: "
    DEFAULT_CHAT_FRAME:AddMessage(prefix .. message)
  end
end

function Disenchanter:IsEnabled()
  return self.Config and self.Config.ENABLED == true
end

function Disenchanter:PrintStatus()
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
  if not Disenchanter:IsEnabled() then
    Print(Disenchanter:T("CHAT_DISABLED"))
    return
  end

  SLASH_DISENCHANTER1 = (Disenchanter.Config and Disenchanter.Config.SLASH_COMMAND) or "/disenchanter"
  SlashCmdList["DISENCHANTER"] = function()
    Disenchanter:PrintStatus()
  end

  if Disenchanter.Tooltip and Disenchanter.Tooltip.Initialize then
    Disenchanter.Tooltip:Initialize()
  end

  if Disenchanter.Options and Disenchanter.Options.Initialize then
    Disenchanter.Options:Initialize()
  end

  Print(Disenchanter:T("CHAT_LOADED"))
end)
