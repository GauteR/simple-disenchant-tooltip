# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.1.3] - 2026-11-16

### Changed

- Prefer TSM DBMarket for Disenchant unit prices with Auctionator fallback. (#18)
- Pad only lower denominations in Disenchant money (#17)
- Pad silver and copper with leading zeros in Disenchant money. (#15)
- Prevent duplicate DE tooltip lines on Auctionator refresh. (#16)
- Push release version tags to origin after ensuring them. (#14)

## [1.1.0] - 2026-11-16

### Changed

- Clamp DE outcomes for Forever gear outside Vanilla item levels (#13)
- Create annotated version tag on real releases when missing. (#12)
- Fix release zip fallback for CurseForge uploads (#11)

## [1.0.0] - 2026-11-16

### Changed

- update toc
- Update README.md
- Rename addon to simple-disenchant-tooltip and add MIT license (#10)
- Bump Config.VERSION to 1.0.0
- Update README.md
- Update README.md
- Update README.md
- Add project README and CurseForge description (#9)
- Show most-likely Disenchant value with white money. (#8)
- Add Disenchant total line on gear tooltips. (#7)
- forventet AH-verdi på DE-outcomes via Auctionator (#5)
- topp 2 kilder og alle item-utfall med farge (#4)
- Substitute Config.VERSION into TOC on publish-local (#3)
- prosentvise DE-utfall på gear og materialer (#2)
- disable loading text
- updated texts
- add BigWigs release scripts and docs
- add publish-local.sh for Git Bash
- Merge pull request #1 from GauteR/feature/tooltip-sources
- initial repository

### Fixed

- avoid nil global outcome before AppendOutcomes loop (#6)
