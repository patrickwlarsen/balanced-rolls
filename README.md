# Balanced Rolls

A [Gargul](https://github.com/papa-sern/Gargul) plugin for World of Warcraft TBC Anniversary that adjusts roll results based on attendance-weighted modifiers, ensuring fair loot distribution for raiders with good attendance.

## How it works

1. **Import player data** — Click the minimap icon (dice) or type `/br` to open the import window. Paste JSON data containing player names and roll modifiers.
2. **Roll on loot** — When the master looter starts a roll via Gargul, Balanced Rolls automatically displays a window showing each roller's result multiplied by their modifier.
3. **Review adjusted results** — The window shows the calculation (`roll * modifier`) and the final adjusted result, sorted highest to lowest.

### Example

```
| Player       | Type | Roll * Mod   | Result |
|--------------|------|--------------|--------|
| Nerfdruids   | MS   | 70 * 1.2     | 84     |
| Fitzchiv     | MS   | 100 * 1      | 100    |
| Mehndi       | OS   | 52 * 0.9     | 46.8   |
```

Rolls are sorted by type priority (MS before OS), then by adjusted result within each type. The top roller in each type group is highlighted in green. Each roll is also announced in raid chat with the modifier and adjusted result.

## Import data format

The import expects a JSON array of player objects:

```json
[
  {
    "name": "PlayerName",
    "rollModifier": "1.2"
  }
]
```

- `name` — The character name as it appears in-game
- `rollModifier` — A multiplier applied to the player's roll (e.g. `1.2` = 120%, `0.9` = 90%)

## Installation

Copy the `Gargul_BalancedRolls` folder into your WoW AddOns directory:

```
World of Warcraft/_anniversary_/Interface/AddOns/Gargul_BalancedRolls/
```

Requires [Gargul](https://github.com/papa-sern/Gargul) to be installed.

## UI Positioning

The Balanced Rolls window attaches to Gargul's loot distribution window. If [GargulGearDisplay](https://github.com/patrickwlarsen/balanced-rolls) is also installed, it positions itself below it.

## Commands

- `/br` or `/balancedrolls` — Open the import window
- Minimap icon left-click — Open the import window
