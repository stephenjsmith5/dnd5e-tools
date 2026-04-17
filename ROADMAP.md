# Roadmap

Long-term vision: a full-featured D&D platform supporting entire campaigns end-to-end — from world creation and character building to AI-assisted live play, visual combat arenas, and both player and DM roles.

---

## Phase 0 — Foundation ✅ (complete)

**Character Builder v2**
- 8-step PHB character creation (races, classes, backgrounds, ability scores, equipment, feats)
- 5 ability score distribution methods including proper Point Buy
- Versioned JSON export (`version: 1`)

**Session Tracker v15**
- 10-tab live session tracking
- 500+ spell database with 4 casting modes
- Class-specific resource pools for all 12 classes
- Encounter/initiative tracker
- Battle Master maneuvers, Divine Smite
- Schema versioning and migration (`_schemaVersion`)
- localStorage auto-save + JSON export/import

---

## Phase 1 — Seamless Player Experience (current focus)

Goal: Make the tool feel like one cohesive app, not two separate files. Add polish, flexibility, and persistence that a regular player would actually rely on.

### 1a · Builder ↔ Tracker Integration
- [ ] Inline "Open in Tracker" button on builder export — no manual file handling
- [ ] Live preview panel on the builder Sheet step mirroring tracker layout
- [ ] Edit character in builder and re-sync to tracker without losing session data (merge, not overwrite)
- [ ] Tracker "Edit Character" link that opens builder with current state pre-loaded

### 1b · UX Polish
- [ ] Dice roll animations for skill checks, attacks, and death saves
- [ ] Loading/spinner animations on short rest and long rest actions
- [ ] Confirmation dialogs for destructive actions (delete character, end encounter, reset resources)
- [ ] Success/feedback toasts for save, export, level-up, and rest actions
- [ ] Smooth tab transition animations
- [ ] HP bar animated transitions (not instant jumps)

### 1c · Ruleset Support
- [ ] Ruleset selector on first launch: PHB 2014, PHB 2024 (One D&D), homebrew
- [ ] 2024 ruleset changes: updated class features, weapon mastery, revised spell lists
- [ ] Homebrew mode: allow custom races, classes, and subclasses via JSON definition files
- [ ] Per-character ruleset locking so mixed-ruleset parties work correctly

### 1d · Accounts & Cloud Storage
- [ ] Account creation and authentication (email/password + OAuth)
- [ ] Cloud save for all characters — accessible from any device
- [ ] Multiple character slots per account
- [ ] Campaign grouping — associate characters with a campaign
- [ ] Session snapshots — restore any prior state of a character (full history, not just current)
- [ ] Share character sheet via link (read-only public view)

---

## Phase 2 — Campaign & DM Tools

Goal: Expand beyond single-player character management into full campaign support.

### 2a · DM Dashboard
- [ ] Campaign creation with name, setting, and session log
- [ ] NPC roster with stat blocks and notes
- [ ] Monster stat block importer (SRD monsters)
- [ ] Encounter builder — drag monsters into an initiative tracker
- [ ] Loot/treasure generator with CR-appropriate tables

### 2b · Multi-Character Support
- [ ] Party view — see all player character stats at a glance (HP, conditions, resources)
- [ ] Shared encounter — DM controls initiative, players see their turn highlighted
- [ ] Shared session log visible to all party members
- [ ] Party currency and shared inventory

### 2c · Campaign Management
- [ ] Session notes with tagging (NPCs, locations, plot threads)
- [ ] Quest tracker with status (active, complete, failed)
- [ ] World lore wiki — linked notes by tag
- [ ] Timeline of campaign events

---

## Phase 3 — Visual Play & AI Integration

Goal: Bring the table to the screen with a visual combat arena and AI-powered session assistance.

### 3a · Visual Combat Arena
- [ ] Grid-based tactical map (configurable size)
- [ ] Player and enemy tokens with HP overlays and condition icons
- [ ] Token movement with range and speed indicators
- [ ] Area of effect overlays (cone, sphere, line, cube)
- [ ] Fog of war for DM-controlled reveal
- [ ] Custom map image upload (use your own map art)

### 3b · World & Map Generation
- [ ] Procedural world map generation (continents, biomes, regions)
- [ ] Town/dungeon layout generation with encounter seeding
- [ ] Map annotation tools (labels, pins, connections)
- [ ] Export map as image

### 3c · AI-Powered Live Play
- [ ] Audio transcription of live session audio
- [ ] Automatic event extraction — rolls, attacks, ability checks, damage parsed from speech
- [ ] Narrative summarization — auto-generated session recap at end of play
- [ ] DM assistant — rules lookups, encounter suggestions, lore generation
- [ ] AI NPC dialogue — context-aware responses for DM-designated NPCs

---

## Guiding Principles

- **Player-first:** everything should reduce friction at the table, not add it
- **Offline-capable:** core features work without an internet connection
- **Portable:** JSON-based data means nothing is locked in; players own their data
- **Ruleset-agnostic long-term:** architecture should accommodate multiple editions and homebrew
- **No required accounts for core use:** cloud sync is additive, not a gate
