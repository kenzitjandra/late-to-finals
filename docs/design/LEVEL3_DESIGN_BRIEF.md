# Level 3: Final Hall Sprint — Design Brief

## Overview

Level 3 is the final challenge. The player sprints through the faculty building hallway in a high-pressure sprint to reach the exam hall before the timer ends.

## Level Theme

Faculty building hallway / corridor. Final exam atmosphere. High urgency, visual distractions, last-minute obstacles.

## Level Flow

```
Player spawn (hallway entrance)
	   │
	   ▼
Sprint through corridor
	   │
	   ▼
Avoid obstacles (wet floor, exposed wiring, dropped books)
	   │
	   ▼
See wrong classroom signs (visual distractions - no maze)
	   │
	   ▼
Jump over gap / stairs or avoid moving obstacle
	   │
	   ▼
Meet lecturer near exam hall
	   │
	   ▼
Enter exam hall door (bottom-right) → Result Screen
```

## Spatial Layout

The level is a 2D side-scrolling corridor, approximately **1200-1500 pixels wide × 720 pixels tall**. Compact and linear to support a quick sprint.

- **Left Area (X: 0–400):** Hallway entrance. Player spawns here on a solid floor.
- **Middle Area (X: 400–900):** Main corridor with obstacles. Wet floor, exposed wiring, dropped books. Visual distractions (wrong door signs).
- **Right Area (X: 900–1500):** Final section with lecturer NPC. Exam hall entrance at far right (≈X: 1450, Y: 600).
- **Vertical Layout:** Single ground level (Y: 600). One raised section (stairs or platform jump, Y: 500–550) in the middle.
- **Boundaries:** Left and right walls prevent leaving the hallway.

## Player Spawn

- Position: left side of hallway, approximately (100, 600).
- The player starts on solid ground, ready to sprint.

## Player Mechanics

- Left/right movement (A/D or arrow keys)
- Jump (W/Up/Space)
- Single jump only (no double jump)
- Camera2D follows player with smooth drag
- Speed: ~400 px/s (same as Level 1)
- Jump velocity: ~-500 px/s (same as Level 1)

## Exam Hall Exit

- Located at far right, approximately (1450, 600).
- Represented as a green-tinted door or platform.
- An Area2D trigger detects when the player enters.
- On trigger: Display Result Screen (ending calculation).

## Obstacles

### Primary Obstacles

**Wet Floor (Focus penalty)**
- Located in middle area, approximately X: 500–700.
- Slippery surface. Player bounces or loses control on contact.
- Reduces focus by 20-30%.
- **Visual:** Light blue polygon or tile.

**Exposed Wiring (Focus penalty)**
- Located in middle area, approximately X: 750–850.
- Danger area. Reduces focus by 20-30% on contact.
- **Visual:** Yellow/red highlighted danger zone.

**Dropped Books / Boxes (Jump obstacle)**
- Located at Y: 580 (near floor).
- Small obstacle clusters. Player must jump over or around.
- Approximately X: 600–650 and X: 1000–1050.
- **Visual:** Brown/tan colored rectangles.

**Stairs or Platform Gap (Jump gap)**
- Located in middle-right area, approximately X: 1100–1300.
- A staircase or simple jump gap. Player must jump up to Y: 550 and traverse the raised section.
- After clearing, player returns to ground level.
- **Visual:** Simple geometric stairs or gap.

**Moving Lecturer (Collision avoidance)**
- Located near exam hall, approximately X: 1350–1400.
- An NPC sprite that walks slowly left-right. Player can collide but doesn't get blocked.
- Collision reduces focus by 10%.
- **Visual:** Simple character sprite or placeholder rectangle.

### Visual Distractions (No Actual Barriers)

**Wrong Classroom Signs**
- Placed at X: 550 and X: 900, pointing in random directions (up/down/left).
- **NOT actual obstacles.** Just visual clutter for atmosphere.
- Do not create real blocking doors. Signs are background elements only.
- **Visual:** Text labels or door graphics pointing wrong direction.

## NPCs

### Lecturer (Final NPC)

**Role:** Confirms the player is entering the exam hall.

**Function:**
- Positioned near the exam hall entrance (X: 1400–1450).
- On interaction: Plays a short line, e.g., "Enter quickly! The exam is starting!"
- Can be passively walked into without blocking the player.

**Dialogue (Optional):**
- "Hurry! The exam starts now!"
- "Good luck!"

## Collectibles

**Study Notes (Optional)**
- 1-2 placed in the main corridor (X: 600, 1050).
- Easy to collect while moving.
- Contributes to final ending calculation.

**Coffee (Optional)**
- 1 placed in middle area (X: 800).
- Restores focus if needed.
- Trade-off: Takes 1-2 seconds to collect.

## Systems

**Timer**
- Continues from previous level.
- Player must enter exam hall before timer reaches zero.
- If timer ends: Missed Exam ending.

**Focus Bar**
- Decreases on obstacle contact.
- Affected by hazards (wet floor, exposed wiring, moving lecturer).
- Influences final ending.

**Objective Display**
- "Enter the Exam Hall"
- Simple and clear.

## Design Decisions

- **Linear layout only.** No branching paths or shortcuts. Supports rushed development.
- **Reuse existing mechanics.** Wet Floor, Exposed Wiring, collectibles, focus bar, timer.
- **Minimal new assets.** Wrong door signs are visual only. No complex dialogue system.
- **Short duration.** Level should be completable in ~60–90 seconds at normal speed.
- **High stress atmosphere.** Close to the goal, tight timer, final push.
- **Fair and clear.** Obstacles are visible. Player does not feel tricked.

## First Round Scope

**Skeleton only:**
- Player movement and jumping
- Camera follow
- Placeholder floor and walls (colored rectangles via Polygon2D)
- Left-side player spawn
- Right-side exam hall entrance trigger
- "Result Screen" console output
- Basic timer display (inherited from GameManager)

## Must-Have Features

- Player can move and jump
- Obstacles (wet floor, exposed wiring, dropped books, stairs/gap)
- One optional collectible (study note or coffee)
- Lecturer NPC (visual presence, simple interaction)
- Exam hall entrance trigger
- Result screen transition

## Nice-to-Have Features (If Time Allows)

- Wrong door sign visuals
- Moving lecturer animation
- Collectible collection feedback
- Screen shake on obstacle impact
- Sound effects

## Should Be Avoided

- Complex elevator or multi-floor navigation
- Long NPC dialogues
- Branching paths
- Maze-like design
- Multiple shortcuts

## End Goal

- Reach exam hall and trigger result screen
- Result screen shows ending based on: timer remaining, focus level, notes collected, student ID status

---

**Development Timeline:** Keep this level short and focused. Manual architecture in Godot. Reuse all tested mechanisms from Rounds 1–15. Build fast, test early, iterate if time permits.
