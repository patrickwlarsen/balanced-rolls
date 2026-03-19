# Changelog

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
