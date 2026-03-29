# Changelog

## [1.1.0] - 2026-03-29

### Added
- Roll type column (MS/OS) in the roll display, ordered as Player | Type | Roll * Mod | Result
- Sorting by roll type priority (MS before OS), then by adjusted roll within each type
- Green highlight for top roller per type group
- Raid/party chat announcement when a roll is intercepted, showing the modifier and adjusted result

### Changed
- UI restyled to match Gargul's dark dialog theme (BACKDROP_DARK_DIALOG_32_32)
- Import window now uses Gargul-style backdrop, close button, gold title, and dark text area
- Roll display uses Gargul-style backdrop and close button positioning
- Buttons changed from GameMenuButtonTemplate to UIPanelButtonTemplate
- Top roller highlight updated to Gargul's success green (0x92FF00)

## [1.0.0] - 2026-03-19

### Added
- Initial release of Balanced Rolls as a Gargul plugin
- Minimap icon with custom dice icon
- Import window for pasting JSON player data (name + roll modifier)
- Data persistence via SavedVariables (clears previous data on re-import)
- Success popup on import completion
- Roll tracking window that hooks into Gargul's roll-off events
- Adjusted roll display showing `roll * modifier = result`, sorted by result
- Class-colored player names and green highlight for top roller
- Automatic anchoring to Gargul's MasterLooterUI loot window
- Positions below GargulGearDisplay when that addon is present
- Matches GargulGearDisplay visual style (tooltip backdrop, close button, draggable title)
- Auto-hides when Gargul's loot window closes
- Slash commands: `/br` and `/balancedrolls`
