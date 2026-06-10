# Handoff Summary - The Final Exam Run

## Why this file exists

This file summarizes the current project state so the next Claude Code session can continue without relying on chat history.

---

## Current status in one sentence

Rounds 1-15 mechanisms are complete and tested, and formal Level 1 is back to the manually stabilized four-floor architecture after a rejected Stage 1B floor-splitting attempt was reverted successfully.

---

## Current milestone

```text
Formal Level 1 Layout Stage 1B Re-Plan After Recovery
```

Status:

- Automatic Stage 1A generation was rejected.
- The user manually adjusted and stabilized the four-floor Level 1 building architecture in Godot.
- A Stage 1B attempt split the long continuous floor nodes into segment nodes and added landing platforms.
- That Stage 1B attempt was rejected because it made the level look like abstract platform bars instead of the apartment design map.
- The failed Stage 1B implementation was reverted successfully.
- The current `Level1_ApartmentPanic.tscn` architecture is back to the manually stabilized source of truth.
- Stage 1B is not completed.
- Future work should change strategy and preserve this architecture, not continue the failed coordinate-splitting approach.

Next step:

```text
Re-plan Formal Level 1 Stage 1B with a manual-first / design-map-first workflow
```

---

## Critical project direction

The final Level 1 must be based on:

```text
docs/design/level1_apartment_panic_design.png
```

Do not invent a different Level 1 layout. Do not freely redesign the map.

Important workflow update:

- The user manually places architecture and visual layout in Godot.
- Claude Code handles technical integration, collision fixes, script connections, mechanism placement support, scene cleanup, and bug fixes.
- Claude Code should not replace the current architecture with automatically generated coordinates.
- The current manual architecture should be treated as the active formal Level 1 base.

---

## Preservation rule

Do not delete tested mechanism scenes or scripts.

Do not remove implemented mechanics from the project.

All tested mechanisms must be preserved for gradual placement on the formal architecture.

---

## Completed and tested mechanisms

Rounds 1-15 implemented and tested:

- Player movement / jump / camera
- HUD / Timer / Focus
- Objective Flow
- Result / Restart flow
- Student ID
- Study Note / SN
- Coffee
- Roommate interaction
- Security Guard
- IDBarrier
- SwitchButton
- LockedDoor
- Exposed Wiring
- Wet Floor
- FallZone / Dark Pit Respawn
- Ceiling Fan / Temporary Platform
- Traffic / Moving Cars
- Bus Stop

---

## Formal layout history

An earlier automatic Formal Level 1 Stage 1A attempt failed / was rejected.

Reason:

- It did not match the intended design feel.
- The spatial readability was poor.
- Floor spacing and proportions were not suitable.
- It did not match the user's desired hands-on level design workflow.

Correction:

- The user manually adjusted the four-floor building architecture directly in Godot.
- Collision recovery was performed after manual edits.
- The current architecture is now considered stable enough to be the foundation for future layout work.

---

## Current formal layout stage

```text
Stage 1A - Building Architecture Base
```

Current status:

- Large four-floor building frame has been manually adjusted.
- Floor spacing and overall building proportions are accepted as the current base.
- The architecture is ready to be used as the foundation for later Level 1 layout work.
- The project should not return to fully automatic map generation.

Important:

- Treat the current `Level1_ApartmentPanic.tscn` architecture as source of truth.
- Do not redesign the overall structure from scratch.
- Do not replace it with generated coordinates.
- Build future work on top of the current manually stabilized architecture.

---

## Next stage

```text
Re-plan Formal Level 1 Stage 1B with a manual-first / design-map-first workflow
```

Stage 1B remains incomplete. Before any implementation, create a safer workflow that:

- Uses `docs/design/level1_apartment_panic_design.png` as the authority.
- Focuses on reproducing the design image, not generating generic platformer openings.
- Keeps the current manually stabilized architecture as the source of truth.
- Lets the user adjust or confirm route changes visually in Godot first.
- Limits Claude Code to small technical fixes after the route is visually confirmed.

Do not:

- Implement immediately.
- Split floors automatically.
- Use large coordinate-based scene edits.
- Redesign the building.
- Regenerate, replace, or normalize the whole architecture.
- Add FallZones yet.
- Add gameplay objects yet.
- Add Student ID.
- Add Study Notes / SN.
- Add Coffee.
- Add Roommate.
- Add Wet Floor.
- Add Exposed Wiring.
- Add Ceiling Fan platforms.
- Add Security Guard.
- Add IDBarrier.
- Add SwitchButton.
- Add LockedDoor.
- Add traffic cars.
- Add Bus Stop.
- Add side quests.

---

## Later stages

### Stage 1C - FallZones

After Stage 1B safe descent is validated, Stage 1C should add FallZones only below failed fall areas / gaps / dark pits.

Critical FallZone rule:

- FallZone must not be placed on normal walkable floors.
- The player should fall into FallZone, not walk into it.
- FallZone placement must come after safe descent route validation.

### Stage 2 - Gameplay mechanism placement

After Stage 1C, gradually place tested mechanisms according to the design map:

- Student ID
- Study Notes / SN
- Coffee
- Roommate
- Wet Floor
- Exposed Wiring
- Ceiling Fan temporary platforms
- Security Guard
- IDBarrier
- SwitchButton
- LockedDoor
- Traffic cars
- Bus Stop

Test after each placement group.

---

## Side quests postponed

Do not implement these yet:

- Roommate Keys
- Security Guard Baton
- Opening Key
- Key used in second level
- Formal NPC reward exchange
- Traffic push-back

---

## Key files

### Main scene

- `scenes/levels/Level1_ApartmentPanic.tscn` - current manually stabilized formal architecture base

### Global / startup

- `project.godot`
- `scripts/systems/game_manager.gd`
- `scripts/systems/main_bootstrap.gd`

### Player / level flow / HUD

- `scripts/player/player_controller.gd`
- `scenes/player/Player.tscn`
- `scripts/ui/hud.gd`
- `scenes/ui/HUD.tscn`
- `scripts/levels/bus_stop_trigger.gd`
- `scripts/levels/level1_manager.gd`

### Collectibles

- `scripts/objects/collectibles/collectible.gd`
- `scenes/objects/collectibles/StudyNote.tscn`
- `scenes/objects/collectibles/Coffee.tscn`
- `scenes/objects/collectibles/StudentID.tscn`

### Hazards

- `scripts/objects/hazards/hazard.gd`
- `scripts/objects/hazards/moving_car_hazard.gd`
- `scripts/objects/hazards/wet_floor.gd`
- `scripts/objects/hazards/fall_zone.gd`
- `scenes/objects/hazards/ExposedWiring.tscn`
- `scenes/objects/hazards/MovingCarHazard.tscn`
- `scenes/objects/hazards/WetFloor.tscn`
- `scenes/objects/hazards/FallZone.tscn`

### Platforms

- `scripts/objects/platforms/ceiling_fan_platform.gd`
- `scenes/objects/platforms/CeilingFanPlatform.tscn`

### Interactables / blockers

- `scripts/objects/interactive/interactable.gd`
- `scripts/objects/interactive/security_guard.gd`
- `scripts/objects/interactive/id_barrier.gd`
- `scripts/objects/interactive/switch_button.gd`
- `scripts/objects/interactive/locked_door.gd`
- `scenes/objects/interactive/Roommate.tscn`
- `scenes/objects/interactive/SecurityGuard.tscn`
- `scenes/objects/interactive/IDBarrier.tscn`
- `scenes/objects/interactive/SwitchButton.tscn`
- `scenes/objects/interactive/LockedDoor.tscn`

---

## Known limitations

- Formal Level 1 is not complete yet.
- Current architecture is a stable base, but openings / descent route still need to be added.
- Gameplay objects have not been fully placed back onto the formal architecture.
- FallZones should come only after safe descent route validation.
- HUD/result panel are temporary prototype UI.
- No formal art.
- No sound effects.
- No animations.
- No formal multi-level flow.
- No Level 0 Prologue.
- No Level 2.
- No Level 3.
- No final polished result screen.
- No final ending system.

---

## Recommended next work

1. Start Stage 1B: Openings and Safe Descent Route.
2. Use current manually stabilized architecture as source of truth.
3. Add openings based on the design map.
4. Create safe descent floor by floor.
5. Do not add FallZones yet.
6. Do not add gameplay objects yet.
7. Test movement, jumps, softlocks, and overview camera.
