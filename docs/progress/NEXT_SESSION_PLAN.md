# Next Session Plan - The Final Exam Run

## Immediate Priority

The next Claude Code session should begin with:

```text
Re-plan Formal Level 1 Stage 1B with a manual-first / design-map-first workflow
```

This is a strategy and planning step only. Do not implement immediately, split floors automatically, add FallZones, add gameplay objects, or redesign the building.

---

## Current Project Status

Rounds 1-15 are implemented and manually tested.

Formal Level 1 layout work has started.

The current `scenes/levels/Level1_ApartmentPanic.tscn` architecture was manually adjusted by the user in Godot and is now considered the source of truth for the formal Level 1 building base.

Important:

- Do not redesign the building.
- Do not regenerate the structure from scratch.
- Do not replace the manual architecture with automatically generated coordinates.
- Future work should build on top of the current manually stabilized architecture.
- The final Level 1 must still follow `docs/design/level1_apartment_panic_design.png` as closely as possible.

---

## Workflow Direction

The project now uses a hybrid layout workflow:

- The user manually arranges architecture and object positions in Godot.
- Claude Code handles technical integration, collision fixes, script connections, mechanism placement support, and bug fixes.
- Claude Code should not freely redesign the map.
- All tested mechanism files must be preserved.

Do not delete any tested mechanism scenes or scripts.

---

## Completed Through Round 15

Implemented and tested mechanisms:

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

These mechanisms are preserved for later placement on the formal architecture.

---

## Formal Layout History

An earlier automatic Formal Level 1 Stage 1A attempt was rejected.

Reasons:

- It did not match the intended design feel.
- Spatial readability was poor.
- Floor spacing was unsuitable.
- The result did not match the user's desired hands-on level design workflow.

Current corrected status:

- The user manually stabilized the formal four-floor building architecture in Godot.
- Current architecture is accepted as the active formal Level 1 base.
- Future Claude Code work should support this base rather than replace it.

---

## Current Formal Layout Stage

```text
Stage 1A - Building Architecture Base
```

Status:

- Large four-floor building frame has been manually adjusted.
- Floor spacing and overall building proportions are accepted as the current base.
- Collision recovery was performed after manual layout edits.
- The architecture is ready to be used as the foundation for later Level 1 layout work.
- The project should not return to fully automatic map generation.

---

## Next Stage: Stage 1B Re-Plan

```text
Re-plan Formal Level 1 Stage 1B with a manual-first / design-map-first workflow
```

Current Stage 1B status:

- Stage 1B is not completed.
- A coordinate-based implementation attempt split the manually stabilized continuous floors into segment nodes and added landing platforms.
- That attempt was rejected because it looked like generic platform bars instead of the apartment design map.
- The failed implementation was reverted successfully.
- The current manually stabilized four-floor architecture is again the active source of truth.

Before any implementation, create a safer Stage 1B strategy that:

- Uses `docs/design/level1_apartment_panic_design.png` as the authority.
- Focuses on visually reproducing the design image, not generating generic platformer openings.
- Treats the user's Godot-edited architecture as the base to preserve.
- Lets the user adjust or confirm the route visually in Godot first.
- Limits Claude Code to small technical fixes, collision support, and scene cleanup after the route is visually confirmed.

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
- Add hazards.
- Add Security Guard.
- Add IDBarrier.
- Add SwitchButton.
- Add LockedDoor.
- Add traffic.
- Add Bus Stop.
- Add side quests.

---

## Stage 1B Testing Focus

After Stage 1B changes, test:

- Player can move on top floor.
- Player can descend floor by floor.
- Openings feel intentional and readable.
- No softlocks.
- No impossible jumps.
- Camera remains overview-style.
- Architecture remains readable.
- Player cannot accidentally leave the building early.
- R restart still works.

---

## Stage 1C Preview

After Stage 1B is stable:

```text
Stage 1C - FallZones Below Failed Fall Areas
```

Stage 1C should add FallZones only below failed fall areas / gaps / dark pits.

Important:

- FallZone must not be placed on normal walkable floors.
- The player should fall into FallZone, not walk into it.
- FallZones should be added only after the safe descent route is validated.

---

## Stage 2 Preview

After Stage 1C is stable, Stage 2 should gradually place tested gameplay mechanisms according to the design map:

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

Place these gradually and test after each group.

---

## Postponed Side Quests

Do not implement yet:

- Roommate Keys
- Security Guard Baton
- Opening Key
- Key used in second level
- Formal NPC reward exchange
- Traffic push-back

---

## Files To Avoid Modifying Unless Needed

- `.godot/`
- `project.godot`
- gameplay scripts
- reusable object scenes
- reusable object scripts
- Level 0 / Prologue files
- Level 2 files
- Level 3 files
- final UI/result screen
- art/audio/font assets

Stage 1B should mostly modify:

- `scenes/levels/Level1_ApartmentPanic.tscn`

Only modify other files if there is a clear technical blocker.

---

## Required First Read Next Session

Read:

- `docs/progress/HANDOFF_SUMMARY.md`
- `docs/progress/PROGRESS_LOG.md`
- `docs/progress/NEXT_SESSION_PLAN.md`
- `docs/design/LEVEL1_DESIGN_BRIEF.md`
- `docs/design/level1_apartment_panic_design.png`
- `scenes/levels/Level1_ApartmentPanic.tscn`

Then inspect the current architecture in the scene before changing anything.
