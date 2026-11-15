-- Options → AddOns → Disenchanter: about panel.
Disenchanter = Disenchanter or {}
Disenchanter.Options = Disenchanter.Options or {}

local Options = Disenchanter.Options
local ADDON_FOLDER = "disenchanter"

local function GetMeta(field, fallback)
  local value
  if C_AddOns and C_AddOns.GetAddOnMetadata then
    value = C_AddOns.GetAddOnMetadata(ADDON_FOLDER, field)
  elseif GetAddOnMetadata then
    value = GetAddOnMetadata(ADDON_FOLDER, field)
  end
  if value == nil or value == "" then
    return fallback
  end
  return value
end

-- TOC keeps ## Version: @project-version@ for packager; show Config.VERSION until substituted.
local function GetDisplayVersion()
  local meta = GetMeta("Version", nil)
  if meta and not string.find(meta, "@", 1, true) then
    return meta
  end
  if Disenchanter.Config and Disenchanter.Config.VERSION then
    return Disenchanter.Config.VERSION
  end
  return "?"
end

function Options:Initialize()
  if self.registered then
    return
  end
  if not Settings or not Settings.RegisterCanvasLayoutCategory then
    return
  end

  local panel = CreateFrame("Frame", "DisenchanterOptionsPanel")
  panel.name = GetMeta("Title", Disenchanter:T("ADDON_NAME"))
  panel:Hide()

  -- Required by the Settings canvas layout even when unused.
  function panel:OnCommit()
  end
  function panel:OnDefault()
  end
  function panel:OnRefresh()
  end

  local icon = panel:CreateTexture(nil, "ARTWORK")
  icon:SetSize(48, 48)
  icon:SetPoint("TOPLEFT", 16, -16)
  icon:SetTexture("Interface\\Icons\\INV_Enchant_DustStrange")

  local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  title:SetPoint("LEFT", icon, "RIGHT", 12, 8)
  title:SetText(panel.name)

  local version = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
  version:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -4)
  version:SetText(Disenchanter:T("OPTIONS_VERSION_FMT", GetDisplayVersion()))

  local help = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
  help:SetPoint("TOPLEFT", icon, "BOTTOMLEFT", 0, -20)
  help:SetWidth(520)
  help:SetJustifyH("LEFT")
  help:SetJustifyV("TOP")
  help:SetWordWrap(true)
  help:SetText(Disenchanter:T("OPTIONS_HELP"))

  local ok, category = pcall(Settings.RegisterCanvasLayoutCategory, panel, panel.name)
  if not ok or not category then
    return
  end
  category.ID = panel.name
  local registeredOk = pcall(Settings.RegisterAddOnCategory, category)
  if not registeredOk then
    return
  end

  self.panel = panel
  self.category = category
  self.registered = true
end
