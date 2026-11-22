-- Pure helpers for release tag / zip naming (shared contract for scripts + tests).
local M = {}

function M.parse_version(config_text)
  if type(config_text) ~= "string" then
    return nil
  end
  return config_text:match("VERSION%s*=%s*\"([^\"]+)\"")
end

--- "1.2.0" -> "1.2.1" (patch bump for data-only updates); nil for non MAJOR.MINOR.PATCH input.
function M.bump_patch(version)
  if type(version) ~= "string" then
    return nil
  end
  local major, minor, patch = version:match("^(%d+)%.(%d+)%.(%d+)$")
  if not major then
    return nil
  end
  return string.format("%s.%s.%d", major, minor, tonumber(patch) + 1)
end

--- Replace the VERSION = "x" literal in Config.lua text; returns new text or nil.
function M.set_version(config_text, version)
  if type(config_text) ~= "string" or not M.parse_version(config_text) then
    return nil
  end
  local replaced = config_text:gsub('(VERSION%s*=%s*")[^"]+(")', "%1" .. version .. "%2", 1)
  return replaced
end

function M.version_tag(version)
  if type(version) ~= "string" or version == "" then
    return nil
  end
  return "v" .. version
end

function M.forever_zip_name(package_name, version)
  if type(package_name) ~= "string" or package_name == "" then
    return nil
  end
  if type(version) ~= "string" or version == "" then
    return nil
  end
  -- Packager names archives from the git tag (v1.2.3), not bare Config.VERSION.
  local labeled = version
  if not labeled:match("^[vV]") then
    labeled = "v" .. labeled
  end
  return string.format("%s-%s-forever.zip", package_name, labeled)
end

return M
