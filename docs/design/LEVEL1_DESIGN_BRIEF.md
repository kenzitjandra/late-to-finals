# Level 1: Apartment Panic — Design Brief

## Overview

Level 1 is a multi-layer apartment/hostel escape level. The player, a University of Malaya student who overslept before the final exam, must rush from their apartment room to the bus stop at the bottom-right of the level.

## Level Theme

Apartment / hostel building. Indoor to outdoor transition. The level represents the first leg of the journey: getting out of the apartment area and catching the bus to campus.

## Level Flow

```
Player spawn (upper-right apartment room)
       │
       ▼
Navigate apartment platforms downward
       │
       ▼
Avoid obstacles (wet floor, boxes, fridge, exposed wiring)
       │
       ▼
Reach bottom layer (street level)
       │
       ▼
Pass Security Guard, Locked Door, Traffic area
       │
       ▼
Reach Bus Stop (bottom-right) → Level Complete
```

## Spatial Layout

The level is a 2D side-scrolling space, approximately 3200×900 pixels. The camera follows the player horizontally with smooth drag margins.

- **Upper Area (Y: 100–350):** Apartment rooms and corridors. Player spawns at the upper-right. Platforms represent floors, ledges, and furniture.
- **Middle Area (Y: 350–600):** Transition platforms — balcony edges, stairwells, exterior ledges. The player descends through gaps between platforms.
- **Bottom Area (Y: 600–800):** Street level. Long ground surface. Bus Stop is at the bottom-right.
- **Boundaries:** Left and right walls prevent the player from leaving the level bounds.

## Player Spawn

- Position: upper-right area of the level, approximately (2500, 100).
- The player starts on a stable platform so they can immediately practice movement.

## Player Mechanics (First Round)

- Left/right movement (A/D or arrow keys)
- Jump (W/Up/Space)
- Gravity applies when not on floor
- Single jump only (no double jump)
- Camera2D follows player with smooth drag margins
- Speed: ~400 px/s, Jump velocity: ~-500 px/s

## Bus Stop / Level Exit

- Located at bottom-right, approximately (2900, 720).
- Represented as a green-tinted platform area.
- An Area2D trigger detects when the player enters.
- On trigger: prints "Level 1 Complete!" to console (placeholder behavior).

## Obstacles (Future Rounds)

These exist in the design but are NOT implemented in the first round:

- Wet floor (slippery surface)
- Boxes (blocking obstacles)
- Fridge (large blocking obstacle)
- Exposed wiring (damage / focus penalty)
- Traffic / Cars (timing hazard near the bottom-right)

## NPCs (Future Rounds)

- **Roommate:** Located near the player spawn. Provides tutorial hints.
- **Security Guard:** Located at the bottom layer. Checks if the player has their Student ID before allowing passage.

## Collectibles (Future Rounds)

- **Student ID:** Near the main path, easy to collect. Required to pass the Security Guard.
- **Study Notes:** Optional collectible. Contributes to exam readiness score.
- **Coffee:** Optional collectible. Provides a brief focus boost.

## Interactive Objects (Future Rounds)

- **Switch / Button:** Opens the Locked Door.
- **Locked Door:** Blocks the path to the Bus Stop until the switch is activated.

## Systems (Future Rounds)

- **Focus Bar:** Replaces stamina/panic meter. Decreases on obstacle collision. Affects ending calculation.
- **Timer:** Countdown to exam start. Creates urgency.
- **HUD:** Displays timer, focus bar, and collectible status.
- **Result Screen:** Calculated from remaining time, focus level, and items collected.

## Design Decisions

- Focus Bar only — no separate stamina or panic meter.
- NPCs are short and functional — no complex dialogue trees.
- Student ID is easy to collect near the main path.
- Wrong classroom signs and complex maze logic are NOT part of Level 1.
- Clear playable mechanics take priority over visual polish.
- The prototype should be small but complete — do not overbuild.

## First Round Scope

Only the playable skeleton:
- Player movement, jumping, gravity
- Camera follow
- Rough multi-layer platforms (colored placeholder rectangles via Polygon2D)
- Upper-right player spawn
- Bottom-right Bus Stop / Level Exit trigger
- Simple "Level 1 Complete" console output
