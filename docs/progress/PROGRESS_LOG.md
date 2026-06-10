# Progress Log - The Final Exam Run

## Project

- **Name:** The Final Exam Run
- **Engine:** Godot 4.6
- **Type:** 2D side-scrolling campus rush serious game
- **Setting:** University of Malaya
- **Current focus:** Level 1 - Apartment Panic

---

## Current Milestone

**Rounds 1-15 are implemented and manually tested.**

Formal Level 1 layout work has started. The current `Level1_ApartmentPanic.tscn` architecture has been manually stabilized in Godot and is now the source of truth for future layout work.

Next major task:

```text
Re-plan Formal Level 1 Stage 1B with a manual-first / design-map-first workflow
```

The final layout is not complete yet. Stage 1B is not complete, and gameplay objects have not been placed back onto the formal architecture.

---

## Current Development Stage

The project is still a prototype, but formal Level 1 architecture work has begun. The current `Level1_ApartmentPanic.tscn` has a manually adjusted four-floor building architecture and should now be treated as the active formal architecture base.

The final Level 1 must still follow the provided design map as closely as possible. Do not invent a different Level 1 layout.

Workflow direction:

- The user manually arranges level architecture and object positions in Godot.
- Claude Code supports with technical integration, collision repair, scene cleanup, mechanism placement support, and bug fixes.
- Do not replace the current manual architecture with automatically generated coordinates.
- Do not delete tested mechanism files.

---

## Completed Rounds

### Round 1 - First playable Level 1 technical skeleton

Implemented:

- Player movement
- Jump
- Gravity
- Collision
- Camera follow
- Placeholder platforms
- Bus Stop trigger
- `Level 1 Complete!` output

Purpose:

- Establish a stable first playable skeleton.
- Confirm movement, platforming, camera, scene loading, and end trigger.

### Round 2 - GameManager Autoload + temporary debug HUD

Implemented:

- `GameManager` Autoload singleton
- `main_bootstrap.gd`
- Temporary debug HUD
- Timer display and countdown
- Focus display
- Notes counter display
- Coffee counter display
- Student ID state display
- Objective display

Purpose:

- Centralize gameplay state.
- Provide temporary HUD feedback for mechanic testing.

### Round 3 - Collectibles

Implemented placeholder Area2D collectibles:

- Study Note
- Coffee
- Student ID

Behavior:

- Study Note increases `notes_collected`.
- Coffee increases `coffee_collected`.
- Student ID sets `has_student_id = true`.
- Pickups disappear after collection.
- HUD updates through GameManager state.

### Round 4 - Exposed Wiring hazard

Implemented:

- Placeholder Exposed Wiring Area2D hazard
- Focus damage
- Damage cooldown
- Focus clamp between 0 and 100

Behavior:

- Exposed Wiring reduces Focus by 10.
- Damage uses cooldown and does not drain Focus every frame.
- Focus reaching 0 does not cause death, reload, game-over, result screen, movement lock, or knockback.

### Round 5 - Simple interaction system

Implemented:

- Reusable `interactable.gd`
- Press E prompt
- Interaction message behavior
- Temporary `TestInteractable`

Behavior:

- Player enters area -> prompt appears.
- Player presses E -> message appears.
- Player exits area -> prompt/message hide.

### Round 6 - Roommate tutorial NPC-like interactable

Implemented:

- Placeholder Roommate scene using existing interaction system
- Short tutorial message

Message:

```text
Wake up! Your final exam starts soon! Don't forget your Student ID!
```

Purpose:

- Prove NPC-like tutorial interactions can reuse the simple interaction system.

### Round 7 - Security Guard + Student ID check + IDBarrier

Implemented:

- Placeholder Security Guard interactable
- Student ID check
- Placeholder IDBarrier blocker

Behavior:

- Without Student ID:
  - Security Guard shows `Student ID Required!`
  - IDBarrier remains closed
- With Student ID:
  - Security Guard shows `You may pass.`
  - IDBarrier opens by hiding visual and disabling collision

Testing status:

- Security Guard + Student ID check works.
- IDBarrier blocks before pass and opens after valid check.
- No red runtime errors observed during testing.

### Round 8 - SwitchButton + LockedDoor + Door Status Label

Implemented:

- Placeholder SwitchButton interactable
- Placeholder LockedDoor blocker
- Door Status Label

Behavior:

- LockedDoor starts closed and blocks player.
- Door Status Label starts as `Door Status: Locked`.
- Pressing E near SwitchButton shows `Door Unlocked!`.
- LockedDoor opens by hiding visual and disabling collision.
- Door Status Label changes to `Door Status: Open`.
- Repeated interaction does not cause errors.

Testing status:

- SwitchButton interaction works.
- LockedDoor opens correctly.
- Door Status Label updates correctly.
- No red runtime errors observed during testing.

### Round 9 - Traffic / Moving Car Hazard

Implemented:

- Placeholder moving car hazard
- Revised into a two-road traffic crossing prototype

Current traffic crossing layout:

```text
LockedDoor -> Road 1 -> Safe Island -> Road 2 -> Bus Stop
```

Behavior:

- Cars move vertically through road areas.
- Player crosses horizontally on the ground by timing movement.
- Player can wait before Road 1.
- Player can pause safely on Safe Island.
- Player can cross Road 2 and continue to Bus Stop.
- Traffic car damage: Focus -15.
- Damage cooldown remains active.
- No death, reload, game-over, result screen, movement lock, or knockback from car damage.

Testing status:

- Traffic crossing mechanic works.
- Player can cross without jumping if timing movement correctly.
- Safe Island is safe.

### Round 10 - Focus System Improvement

Implemented:

- Coffee restores Focus by +10
- Coffee still increases Coffee count by 1
- Focus restore uses `GameManager.change_focus(10)`
- Focus does not exceed 100
- Low Focus warning when Focus <= 40
- Low Focus warning hides when Focus > 40
- Temporary Focus feedback message for about 1 second

Feedback examples:

```text
Focus -10
Focus -15
Focus +10
```

Important behavior:

- Feedback uses actual Focus change.
- If Focus is 95 and Coffee restores +10, actual change is +5, so feedback shows `Focus +5`.
- Exposed Wiring and Traffic Cars still use `GameManager.change_focus()`.

Testing status:

- Coffee restore works normally.
- Low Focus warning works.
- Focus feedback works.

### Round 11 - Level 1 Win / Lose / Result Flow

Implemented:

- `level_state` in GameManager:
  - `playing`
  - `completed`
  - `failed`
- Timer counts down only while `playing`.
- Timer reaching 0 triggers failed state once.
- Bus Stop triggers completed state only while `playing`.
- Completion and failure cannot happen together.
- Temporary result/fail panel in HUD.
- Restart input action:
  - `R = restart`
- Pressing R during gameplay does nothing.
- Pressing R after completion/failure reloads Level 1.
- GameManager state resets on restart.
- Player movement lock after completion/failure.

Result panel shows:

- `Level 1 Complete` or `Time's Up!`
- Time Remaining
- Focus
- Notes Collected
- Coffee Collected
- Student ID: Yes/No
- Rank
- `Press R to Restart`

Rank values:

- Missed Exam
- Excellent
- Good
- Barely Ready
- Needs Improvement

Testing status:

- Round 11 verification passed.
- Completion flow works.
- Failure flow works.
- Result panel works.
- R restart works.
- State reset works.
- Movement lock works after completion/failure.

### Round 12 - Objective Flow + Pre-Layout Cleanup

Implemented:

- `GameManager.current_objective` starts as `Get your Student ID`.
- `GameManager.set_objective(text)` helper.
- `Level1Manager` owns a simple forward-only Level 1 objective stage tracker.
- Objective flow for the current testing lane:

```text
Get your Student ID
-> Collect a Study Note
-> Talk to the Security Guard
-> Unlock the Door
-> Cross the Traffic
-> Reach the Bus Stop
```

Behavior:

- Student ID pickup advances objective.
- Study Note pickup advances objective.
- Successful Security Guard pass advances objective.
- SwitchButton / door unlock advances objective.
- Traffic crossing uses temporary current-lane position logic to advance objective.
- Objectives are guidance only, not hard gates.
- Objective advancement is forward-only and cannot regress.

Testing status:

- Objective flow works.
- Restart resets the objective to `Get your Student ID`.
- Existing Round 11 win/fail/result/restart flow still works.

### Round 13 - Wet Floor movement-control hazard

Implemented:

- New `WetFloor.tscn` placeholder scene.
- New `wet_floor.gd` script.
- Player controller slippery movement support.
- One temporary `WetFloor_Test` placement in the current ground testing lane.

Files created:

- `scripts/objects/hazards/wet_floor.gd`
- `scenes/objects/hazards/WetFloor.tscn`

Files modified:

- `scripts/player/player_controller.gd`
- `scenes/levels/Level1_ApartmentPanic.tscn`

Behavior:

- Player enters Wet Floor area.
- Player becomes slippery.
- Player loses Focus -5.
- Focus loss has cooldown.
- Player leaves Wet Floor area.
- Player movement returns to normal.
- Wet Floor does not kill, reload, block, or knock back the player.

Tuning:

- Initial slippery deceleration was `speed * 0.05`.
- It was later tuned to `speed * 0.03` because testing showed the slippery feeling was not strong enough.
- Normal movement remains `speed * 0.2`.

Testing status:

- Wet Floor mechanism passed manual testing.
- Wet Floor tuning passed manual testing.
- Coffee, Exposed Wiring, Traffic car Focus logic still work.

Current limitations:

- `WetFloor_Test` is only a temporary test placement.
- Final Wet Floor placement must follow the design map.
- Wet Floor should be placed where the design map shows Wet Floor, not randomly.

### Round 14 - FallZone / Dark Pit Respawn

Implemented:

- New `FallZone.tscn` placeholder scene.
- New `fall_zone.gd` script.
- Player controller `last_safe_position` support.
- Player controller `respawn_to_last_safe_position()` helper.
- One temporary `FallZone_Test` placement in the current testing lane.

Files created:

- `scripts/objects/hazards/fall_zone.gd`
- `scenes/objects/hazards/FallZone.tscn`

Files modified:

- `scripts/player/player_controller.gd`
- `scenes/levels/Level1_ApartmentPanic.tscn`

Behavior:

- Player enters FallZone.
- Player loses Focus -10.
- Player respawns to last safe position.
- Player velocity resets to `Vector2.ZERO`.
- Slippery movement state is cleared.
- Scene does not reload.
- Timer continues.
- Notes, Coffee, Student ID, objective, and level state do not reset.
- FallZone ignores the player when the level is completed or failed.

Testing status:

- FallZone respawn passed manual testing.
- Timer continued after respawn.
- Collectibles/objective/state did not reset.
- Player did not softlock during testing.

Important design warning:

`FallZone_Test` was placed on/near the current testing lane only for mechanism testing. In the real Level 1 layout, FallZone must **not** be placed on walkable ground.

Final FallZone placement rules:

- Place FallZone below openings, pits, dark gaps, or fall areas.
- The player should fall into it, not walk into it.
- Do not place FallZone on normal floor.
- Otherwise `last_safe_position` could update too close to or inside the FallZone, causing respawn loops or softlock.

### Round 15 - Ceiling Fan / Temporary Platform

Implemented:

- New `CeilingFanPlatform.tscn` placeholder scene.
- New `ceiling_fan_platform.gd` script.
- One temporary `CeilingFanPlatform_Test` placement in the current testing scene.

Files created:

- `scripts/objects/platforms/ceiling_fan_platform.gd`
- `scenes/objects/platforms/CeilingFanPlatform.tscn`

Files modified:

- `scenes/levels/Level1_ApartmentPanic.tscn`

Behavior:

- Ceiling Fan acts as a temporary platform.
- Player can stand on it.
- After player steps on it, collapse sequence starts once.
- After `collapse_delay`, collision disables and visual hides.
- After `respawn_delay`, collision re-enables and visual reappears.
- Platform is reusable.
- Platform does not damage, kill, reload, or reset the player.

Testing status:

- Ceiling Fan temporary platform passed manual testing.
- Platform disappeared and respawned correctly.
- R restart reset platform state.

Current limitations:

- `CeilingFanPlatform_Test` is only temporary.
- Final Ceiling Fan temporary platform placement must follow the design map labels.
- Ceiling Fan platforms should support vertical movement and opening-crossing, not be placed randomly.

### Formal Level 1 Layout Stage 1A - Manual Architecture Stabilization

Status:

- Formal layout work has started.
- An earlier automatic Stage 1A generation attempt was rejected because it did not match the intended design feel.
- Problems included poor spatial readability, unsuitable floor spacing, and an implementation style that did not match the user's desired hands-on level design workflow.
- The user manually adjusted the formal four-floor Level 1 architecture directly in Godot.
- The current `Level1_ApartmentPanic.tscn` architecture is now treated as stable enough to be the source of truth for future formal layout work.

### 2026-06-10 - Failed Stage 1B Attempt Reverted

Status:

- A Formal Level 1 Stage 1B implementation attempt split the long manually stabilized floor nodes into separate segment nodes and added landing platforms.
- The attempt was rejected because it made the scene look like abstract platform bars instead of visually reproducing the apartment design map.
- It replaced the original continuous floor nodes with split segment nodes and moved the workflow away from design-map reproduction.
- The attempt showed that automatic coordinate-based floor splitting is too risky for this stage.
- The failed Stage 1B implementation was reverted successfully.
- The project is back to the manually stabilized four-floor apartment architecture.
- The current `Level1_ApartmentPanic.tscn` manual architecture remains the source of truth.
- Stage 1B is not completed.
- No FallZones should be added yet.
- No gameplay objects should be added yet.
- No Student ID, Coffee, Study Notes, NPCs, hazards, doors, traffic, or Bus Stop should be placed yet.

Next direction:

- Re-plan Stage 1B before any implementation.
- Use the design map as the authority.
- Do not let Claude Code automatically split floors, regenerate the route, normalize the building, or redesign the whole architecture.
- Prefer a manual-first workflow where the user adjusts or confirms the route visually in Godot and Claude Code assists only with small technical fixes.

Current workflow:

- User manually arranges level architecture and object positions in Godot.
- Claude Code should support by adding technical setup, fixing collisions, connecting mechanisms, placing tested mechanisms when asked, and cleaning scene structure when needed.
- Claude Code should not freely redesign the map or regenerate the building from scratch.

Important preservation rule:

- All tested mechanisms from Rounds 1-15 remain preserved.
- Do not delete tested mechanism scenes or scripts.
- Do not remove implemented mechanics from the project.
- Future gameplay objects should be placed back gradually on top of the stable architecture.

Current limitations:

- No side quests are implemented yet.
- Gameplay objects are not fully placed on the formal architecture yet.
- The current formal architecture still needs openings and a validated safe descent route.

Next stage:

```text
Formal Level 1 Layout Stage 1B - Openings and Safe Descent Route
```

Stage 1B should add openings and safe descent route only, without FallZones or gameplay objects.

---

## Current Confirmed Working Systems

Manual testing has passed for:

- Wet Floor tuning
- FallZone respawn
- Ceiling Fan temporary platform
- Round 12 objective flow
- Player movement
- Jump
- Camera follow
- HUD
- Timer display and countdown
- Focus display
- Focus feedback
- Low Focus warning
- Study Note collection
- Coffee collection
- Coffee Focus restore
- Student ID collection
- Exposed Wiring Focus damage
- Traffic / Moving Car Focus damage
- Roommate interaction
- Security Guard + IDBarrier
- SwitchButton + LockedDoor
- Bus Stop completion
- Result panel
- R restart
- Movement lock after completion/failure

---

## Formal Level 1 Layout Principles

The next major work is formal Level 1 layout planning. The final Level 1 must be driven by `docs/design/level1_apartment_panic_design.png`.

Required principles:

1. The outer lines in the design map represent a four-floor apartment/building frame. They are not empty decoration. They should become solid building structure / walls / floors. The player should not pass through them.
2. Before the Locked Door, the player is inside a closed four-floor building. The player should move through the building using floors, openings, platforms, obstacles, and temporary platforms.
3. The player can only leave the building after unlocking and passing through the bottom-right Locked Door.
4. The Locked Door must be a real exit gate. It must not be jumpable or bypassable. It should block the route until SwitchButton opens it.
5. Traffic and Bus Stop must be outside the building, after the Locked Door.
6. FallZone must not be placed on normal walkable floor. It belongs below gaps/openings/dark pits. The player should fall into it.
7. Ceiling Fan temporary platforms should be used where the design map labels Ceiling Fan / temp platform. They should support vertical movement and opening-crossing, not be placed randomly.
8. Wet Floor should be placed where the design map shows Wet Floor. It should be used as a floor hazard, not as a random obstacle.
9. `bk` objects are likely background / blocked / building-context objects. Some may become static obstacles if they affect the path. Do not turn every `bk` object into an interactive mechanism.
10. Side quests are postponed until after the first formal layout version.
11. First formal layout version should use only already-tested mainline mechanisms.
12. Formal layout implementation should not be done in one uncontrolled step.

Postponed side quests / future extensions:

- Roommate Keys
- Security Guard Baton
- Opening Key
- Key used in second level
- Formal NPC reward exchange
- Traffic push-back

Mainline mechanisms available for first formal layout version:

- Player
- Student ID
- Study Notes / SN
- Coffee
- Roommate hint
- Security Guard
- IDBarrier
- Exposed Wiring
- Wet Floor
- FallZone
- Ceiling Fan temporary platform
- SwitchButton
- LockedDoor
- Traffic cars
- Bus Stop
- Objective flow
- Result / restart flow

Recommended formal layout process:

1. First do read-only formal layout planning.
2. Then implement building frame + floors + walls + openings.
3. Test route and softlock issues.
4. Then place gameplay mechanisms and collectibles.
5. Test full Level 1 route.

---

## Important Current Files

### Project / startup

- `project.godot` - input actions, main scene, GameManager Autoload
- `scripts/systems/game_manager.gd` - global Level 1 state, timer, Focus, collectibles, rank/result state, restart
- `scripts/systems/main_bootstrap.gd` - resets Level 1 state and defers Level 1 scene loading

### Player / HUD / level flow

- `scripts/player/player_controller.gd` - movement, jump, slippery movement, last safe position, respawn helper, movement lock after finish/fail
- `scripts/ui/hud.gd` - HUD state display, Focus warning/feedback, result panel
- `scenes/ui/HUD.tscn` - temporary debug HUD and result panel
- `scripts/levels/bus_stop_trigger.gd` - Bus Stop completion trigger
- `scripts/levels/level1_manager.gd` - Level 1 objective flow owner
- `scenes/levels/Level1_ApartmentPanic.tscn` - current technical ground testing lane plus temporary mechanism test nodes
- `scenes/player/Player.tscn` - player scene

### Collectibles

- `scripts/objects/collectibles/collectible.gd`
- `scenes/objects/collectibles/StudyNote.tscn`
- `scenes/objects/collectibles/Coffee.tscn`
- `scenes/objects/collectibles/StudentID.tscn`

### Hazards

- `scripts/objects/hazards/hazard.gd` - static Focus damage hazard logic
- `scripts/objects/hazards/moving_car_hazard.gd` - vertical traffic car Focus damage logic
- `scripts/objects/hazards/wet_floor.gd` - Wet Floor slippery movement + Focus damage logic
- `scripts/objects/hazards/fall_zone.gd` - FallZone respawn + Focus damage logic
- `scenes/objects/hazards/ExposedWiring.tscn`
- `scenes/objects/hazards/MovingCarHazard.tscn`
- `scenes/objects/hazards/WetFloor.tscn`
- `scenes/objects/hazards/FallZone.tscn`

### Platforms

- `scripts/objects/platforms/ceiling_fan_platform.gd` - temporary platform collapse/respawn logic
- `scenes/objects/platforms/CeilingFanPlatform.tscn`

### Interactables / blockers

- `scripts/objects/interactive/interactable.gd` - reusable simple interactable
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

## Known Limitations

- This is still not the final Level 1 Apartment Panic layout.
- Current scene is a technical ground testing lane plus mechanism preparation prototype.
- Formal design-map-based Level 1 layout has not started.
- Visual layout is rough.
- HUD/result panel are temporary prototype UI.
- Temporary test nodes are not final placement:
  - `WetFloor_Test`
  - `FallZone_Test`
  - `CeilingFanPlatform_Test`
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

## Recommended Next Step

Next session should begin with:

```text
Formal Level 1 Layout Read-Only Planning
```

Do not implement the formal layout immediately. First produce a design-map-driven plan that identifies what to keep, delete, relocate, and build.
