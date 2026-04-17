# CLAUDE.md — D&D 5e Tools

Context for Claude Code sessions working on this project.

## What This Is

Two single-file HTML apps that form a D&D 5e companion suite:

| File | Purpose | Size |
|------|---------|------|
| `index.html` | Landing hub | tiny |
| `builder.html` | 8-step PHB character creator | ~97KB |
| `tracker.html` | Live session tracker | ~288KB |

No build step. No framework. No dependencies. Vanilla HTML/CSS/JS only. Open in browser and it works.

## Architecture

Both apps follow the same pattern:

```
Constants / Data (top of file)
  → Utility functions
    → State object (single source of truth)
      → render() (re-renders full UI from state)
        → saveAndRender() (persist to localStorage, then render)
          → Event handlers (mutate state, call saveAndRender)
```

**Builder state:** `state` object — ephemeral, not persisted (session only, user exports when done)  
**Tracker state:** `char` object — persisted to `localStorage` key `dnd5e_tracker_char`

## Data Flow Between Apps

```
builder.html  →  {name}_dnd5e.json  →  tracker.html
              export (version: 1)      import + migrateChar()
```

The builder exports a versioned JSON. The tracker imports it, runs migration, seeds tracker fields, syncs resources and spells, and saves to localStorage. The two apps don't share code — the JSON is the contract.

## Schema Versioning

- Builder export: `version` (top-level integer, user-facing)
- Tracker internal: `tracker._schemaVersion` (underscore-prefixed, internal)
- These are intentionally separate — builder version bumps shouldn't force tracker migrations
- Migration function: `migrateChar(char)` in tracker.html — add new `if (v < N)` blocks, never rewrite old ones

## Key Data Structures

**Builder export shape (version 1):**
```js
{
  version: 1,
  meta: { exportedAt },
  identity: { name, alignment, appearance, personalityTrait, ideals, bonds, flaws },
  race: { id, subraceId, name, raceName },
  class: { id, name, hitDie, spellcasting, spellAbility, saves },
  level,
  baseAbilities, racialBonuses, effectiveAbilities,  // all {str,dex,con,int,wis,cha}
  skillProficiencies: [],
  feats: [{ id, name, desc }],
  hp: { max, current, override },
  ac,
  equipment: { armorId, armorName, hasShield, weapons, weaponDetails },
  tracker: {}  // initialized empty
}
```

**Tracker `char` object:** see tracker.html — `char.tracker` holds all mutable session state (HP, resources, spells, conditions, log, encounter, etc.)

## Code Conventions

- **No framework, no modules** — everything in one `<script>` tag per file
- **Template literals for HTML** — render functions return HTML strings, set via `innerHTML`
- **`saveAndRender()`** is the standard mutation cycle — don't call `render()` alone if state changed
- **Constants are immutable lookup tables** — `RACES`, `CLASSES`, `BACKGROUNDS`, `SPELL_DB`, etc. — never mutate them
- **`SPELL_IDX`** is a pre-built index of `SPELL_DB` for O(1) spell lookup by name
- **`pipTracker(current, max, id, field)`** — reusable pip UI component used for spell slots, ki, rage, etc.
- **`migrateChar()`** must be idempotent — safe to run on already-migrated data

## Ruleset Scope (Current)

PHB 2014 only. All race/class/feat/spell data reflects the 2014 Player's Handbook. Ruleset flexibility (2024 PHB, homebrew) is a Phase 1 goal — don't introduce 2024 changes without a ruleset selector in place.

## What Not To Do

- Don't add npm, build tools, or external libraries — this is intentionally dependency-free
- Don't split the files into modules unless the user explicitly asks for it — portability is a feature
- Don't add TypeScript — plain JS is intentional
- Don't add a backend — Phase 1 cloud storage will be additive, not a refactor of the core
- Don't modify `migrateChar()` old migration blocks — only append new ones
- Don't bump `version` or `_schemaVersion` without a corresponding migration block
- Don't add 2024 PHB data until a ruleset selector exists to gate it

## Current Focus (Phase 1)

See [ROADMAP.md](ROADMAP.md) for full detail. Near-term priorities:

1. **Builder ↔ Tracker integration** — seamless handoff without manual file export/import
2. **UX polish** — dice animations, rest animations, toast feedback, confirmation dialogs
3. **Ruleset selector** — groundwork for supporting PHB 2014, PHB 2024, and homebrew
4. **Accounts + cloud storage** — multi-character, multi-device, session history

## File Map

```
index.html          Landing page
builder.html        Character builder (8-step wizard)
tracker.html        Session tracker (10-tab SPA)
README.md           Public project overview
ROADMAP.md          Phased feature plan
CLAUDE.md           This file
```
