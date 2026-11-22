-- Regenerate Data/ObservedLevels.lua from a saved BootyBayBroker disenchant page.
-- BootyBayBroker blocks scripted requests (HTTP 403), so save the page in a browser first:
--   https://bootybaybroker.com/forever/crafting/disenchant  ->  "Save as" HTML
-- Usage:
--   lua scripts/update_observed_levels.lua <saved-page.html> [--dry-run] [--no-bump]
--       [--out simple-disenchant-tooltip/Data/ObservedLevels.lua] [--config simple-disenchant-tooltip/Config.lua]
--
-- Writes the data file only when it changed, and then bumps Config.VERSION by a patch
-- (data-only release) unless --no-bump. Does not commit or tag; release.sh does that.

local input
local out_path = "simple-disenchant-tooltip/Data/ObservedLevels.lua"
local config_path = "simple-disenchant-tooltip/Config.lua"
local dry_run, bump = false, true

local i = 1
while i <= #arg do
  local a = arg[i]
  if a == "--dry-run" then
    dry_run = true
    i = i + 1
  elseif a == "--no-bump" then
    bump = false
    i = i + 1
  elseif a == "--out" or a == "--config" then
    if not arg[i + 1] then
      io.stderr:write(a .. " requires a path\n")
      os.exit(1)
    end
    if a == "--out" then out_path = arg[i + 1] else config_path = arg[i + 1] end
    i = i + 2
  elseif not input then
    input = a
    i = i + 1
  else
    input = nil
    break
  end
end

if not input then
  io.stderr:write("Usage: lua scripts/update_observed_levels.lua <saved-page.html> [--dry-run] [--no-bump] [--out path] [--config path]\n")
  os.exit(1)
end

local script_dir = arg[0]:match("^(.*)[/\\]") or "."
package.path = script_dir .. "/?.lua;" .. package.path
local Observed = require("observed_levels")
local Meta = require("release_meta")

local function read_file(path)
  local fh = io.open(path, "rb")
  if not fh then
    return nil
  end
  local text = fh:read("*a")
  fh:close()
  return text
end

local function fail(msg)
  io.stderr:write("error: " .. msg .. "\n")
  os.exit(1)
end

local html = read_file(input) or fail("cannot read " .. input)
local levels, err = Observed.from_html(html)
if not levels then
  fail(err)
end

local rendered = Observed.render(levels)
local existing = read_file(out_path)
if existing == rendered then
  print("ObservedLevels.lua is up to date; nothing written, no version bump.")
  os.exit(0)
end

local changes = Observed.diff(existing and Observed.load(existing), levels)
print(string.format("%d band change(s):", #changes))
for _, line in ipairs(changes) do
  print(line)
end

local new_version
if #changes == 0 then
  print("Only the file header/formatting differs; not bumping the version.")
elseif bump then
  local config = read_file(config_path) or fail("cannot read " .. config_path)
  local current = Meta.parse_version(config)
  new_version = current and Meta.bump_patch(current) or fail("cannot parse VERSION in " .. config_path)
  print(string.format("Version: %s -> %s", current, new_version))
  if not dry_run then
    local fh = assert(io.open(config_path, "wb"))
    fh:write(Meta.set_version(config, new_version))
    fh:close()
  end
end

if dry_run then
  print("Dry run: no files written.")
  os.exit(0)
end

local fh = assert(io.open(out_path, "wb"))
fh:write(rendered)
fh:close()
print("Wrote " .. out_path)
