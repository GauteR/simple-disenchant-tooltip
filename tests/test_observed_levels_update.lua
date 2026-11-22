-- Pure Lua tests for scripts/observed_levels.lua and the version helpers.
-- Run: lua tests/test_observed_levels_update.lua

local root = arg[0]:match("^(.*)[/\\]") or "."
package.path = root .. "/../scripts/?.lua;" .. package.path
local Observed = require("observed_levels")
local Meta = require("release_meta")

local failures = 0

local function assert_eq(actual, expected, message)
  if actual ~= expected then
    failures = failures + 1
    print(string.format("FAIL: %s\n  expected: %s\n  actual:   %s", message, tostring(expected), tostring(actual)))
  else
    print("PASS: " .. message)
  end
end

local function row(label, quality, range, items)
  local lis = {}
  for _, it in ipairs(items) do
    lis[#lis + 1] = string.format(
      '<li data-evidence="observed"><span data-slot="chance">50%%</span><span>%s, 1 to 2 (average 1.5)</span><span data-slot="evidence">observed</span></li>',
      it
    )
  end
  return string.format(
    '<tr role="row"><th scope="row" role="rowheader"><span data-quality="%s" class="quality-%s">%s</span></th>'
      .. '<td role="cell" data-numeric="true">%s</td><td role="cell"><ul>%s</ul></td></tr>',
    quality, quality, label, range, table.concat(lis)
  )
end

local function material(id, name)
  return string.format(
    '<tr role="row"><th><a data-slot="item-link" href="https://example.invalid/forever/item/%d/slug"><span data-slot="item-name" data-quality-state="unknown">%s</span></a></th></tr>',
    id, name
  )
end

local function page(odds_rows)
  return '<table role="table"><caption>Items that disenchant on this market, 3 in all</caption></table>'
    .. '<table role="table"><caption>Disenchant materials on this market, each with its own scan age</caption><tbody>'
    .. material(10940, "Strange Dust") .. material(10938, "Lesser Magic Essence") .. material(10978, "Small Glimmering Shard")
    .. '</tbody></table>'
    .. '<table role="table"><caption>What each quality, item class and item level disenchants into</caption><tbody>'
    .. odds_rows .. '</tbody></table>'
end

local html = page(
  row("uncommon armor", "uncommon", "5 to 15", { "Strange Dust", "Lesser Magic Essence" })
    .. row("uncommon armor", "uncommon", "16 to 20", { "Strange Dust", "Small Glimmering Shard" })
    .. row("uncommon weapon", "uncommon", "5 to 15", { "Lesser Magic Essence" })
    .. row("rare armor", "rare", "5 to 15", { "Small Glimmering Shard" })
    .. row("rare weapon", "rare", "21 to 25", { "Small Glimmering Shard" })
)

local levels, err = Observed.from_html(html)
assert_eq(err, nil, "parse without error")
assert_eq(levels[10940].UNCOMMON.ARMOR[1] .. "-" .. levels[10940].UNCOMMON.ARMOR[2], "5-20", "union of armor bands")
assert_eq(levels[10940].UNCOMMON.WEAPON, nil, "no weapon band when none observed")
assert_eq(levels[10938].UNCOMMON.WEAPON[2], 15, "weapon band")
assert_eq(levels[10978].RARE.ANY[1] .. "-" .. levels[10978].RARE.ANY[2], "5-25", "rare merges armor+weapon into ANY")
assert_eq(levels[10978].UNCOMMON.ARMOR[1], 16, "uncommon shard band")

-- render -> load roundtrip is stable and sorted
local text = Observed.render(levels)
assert_eq(Observed.render(Observed.load(text)), text, "render/load roundtrip")
assert_eq(#Observed.diff(Observed.load(text), levels), 0, "no diff against itself")
assert_eq(text:find("[10938]", 1, true) < text:find("[10940]", 1, true), true, "ids sorted ascending")
local changed = Observed.load(text)
changed[10940].UNCOMMON.ARMOR[2] = 25
assert_eq(#Observed.diff(changed, levels), 1, "diff reports one changed band")

-- failures on layout drift
assert_eq(select(2, Observed.from_html("<html></html>")) ~= nil, true, "missing tables -> error")
local _, unknown = Observed.from_html(page(row("uncommon armor", "uncommon", "5 to 15", { "Mystery Dust" })))
assert_eq(unknown ~= nil and unknown:find("Mystery Dust", 1, true) ~= nil, true, "unknown material -> error")

-- version helpers
assert_eq(Meta.bump_patch("1.2.0"), "1.2.1", "bump patch")
assert_eq(Meta.bump_patch("1.2.9"), "1.2.10", "bump patch past 9")
assert_eq(Meta.bump_patch("1.2"), nil, "non-semver -> nil")
assert_eq(Meta.set_version('  VERSION = "1.2.0",\n', "1.2.1"), '  VERSION = "1.2.1",\n', "set_version")

if failures > 0 then
  print(string.format("\n%d test(s) failed", failures))
  os.exit(1)
end
print("\nAll tests passed")
