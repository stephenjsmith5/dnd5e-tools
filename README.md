# D&D 5e Tools

A self-contained, browser-based companion suite for Dungeons & Dragons 5th Edition. No installation, no backend, no account required — just open and play.

## Apps

### 📜 Character Builder
A guided 8-step character creation tool covering the full Player's Handbook ruleset.

- **Races:** 11 races with 20+ subraces (Human, Dwarf, Elf, Halfling, Dragonborn, Gnome, Half-Orc, Half-Elf, Tiefling, Tabaxi, Goliath)
- **Classes:** All 12 PHB classes with hit dice, saving throws, proficiencies, and spellcasting type
- **Backgrounds:** 13 backgrounds with skill grant logic
- **Ability Scores:** 5 methods — Free Assign, Standard Array, Balanced Array, Dice Roll, and Point Buy (27-point PHB budget)
- **Equipment:** 14 armors and 30+ weapons with class proficiency enforcement
- **Feats:** 51 PHB feats with full descriptions (Variant Human and Half-Elf support)
- **Export:** Saves a versioned `{name}_dnd5e.json` file ready to import into the tracker

### 🎲 Session Tracker
A live session management tool for players. Imports your builder JSON and tracks everything from session to session.

| Tab | What it tracks |
|-----|----------------|
| Combat & Stats | Current/max HP, temp HP, AC, death saves, conditions, exhaustion |
| Encounter | Initiative order, multi-combatant turns, damage/healing, defeated status |
| Resources | Class-specific pools — spell slots, ki, rage, bardic inspiration, sorcery points, etc. |
| Spells | 500+ spell database; supports prepared, known, spellbook, and warlock casting modes |
| Actions | Class combat features, bonus actions, reactions |
| Attacks | Auto-generated weapon attacks, custom attacks, Divine Smite, Battle Master maneuvers |
| Skills & Saves | All 18 skills with proficiency/expertise, all saving throws, inline roll results |
| Level Up | ASI choices, feat selection, subclass unlocks, HP gain history, class feature log |
| Inventory | Item list with quantities |
| Session Log | Timestamped campaign notes |

**Persistence:** Auto-saves to `localStorage` on every change. Manual export/import for backups and session portability.

## How to Use

1. Open `index.html` in any modern browser
2. Click **Character Builder** and complete the 8 steps
3. On the final Sheet step, click **Export JSON**
4. Open the **Session Tracker**, click **Load Character**, and import the JSON
5. Track your game — everything auto-saves locally

## Tech Stack

- Vanilla HTML, CSS, JavaScript — zero dependencies, zero build step
- Single-file apps (`builder.html`, `tracker.html`) for maximum portability
- `localStorage` for persistence; JSON files for portability and backups
- PHB 5e (2014) ruleset data embedded directly in source

## Data & Schema

Builder exports use `version: 1`. The tracker internally tracks `_schemaVersion` for migrations. The two version fields are intentionally separate so builder refactors don't force tracker migrations.

See [ROADMAP.md](ROADMAP.md) for planned features and phases.

## Project Status

Currently in **Phase 1** — focused on making the builder-to-tracker transition seamless, adding ruleset flexibility, and UX polish. See the roadmap for details.
