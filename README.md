# Dodger — One-Screen Challenge

**Dodger** is a small one-screen HaxeFlixel game: move left/right to avoid falling obstacles for **60 seconds**.  
This project was built as a compact micro-project to practice design, debugging, and publishing — part of my personal mission to build & share small creative projects.

---

## Demo
- Play (hosted): `[https://detectivez5.github.io/Dodger/index.html](https://detectivez5.github.io/Dodger/index.html)`

---

## Quickstart (run locally)

### Requirements
- Haxe (4.x)  
- haxelib & Lime (installed via Haxe)  
- HaxeFlixel (installed via `haxelib`)  
- `lime` CLI available (`haxelib run lime setup`)

### Run in browser for development
```bash
# Run locally (fast test)
lime test html5
```

Folder / Asset layout
---------------------

This project expects assets in the `assets/` folder called by `Paths.hx`:

```
assets/
images/
player.png
obstacle1.png
obstacle2.png
background.png
platform.png
sounds/
bread.ogg # background track (or bread.mp3 for web)
game-win.ogg
game-over.ogg
```

Usage in code: `Paths.image("player")` → `assets/images/player.png`  
Sound via `Paths.sound("game-win")` → `assets/sounds/game-win.{ogg|mp3}` depending on target.

---

Controls
--------

* Move left: ← or `A`
* Move right: → or `D`
* Restart after game end: `R`
* Debug toggles (only in debug builds):
  * `K` — toggle debug overlay output (console logging)
  * `L` — increase debug time scale
  * `O` — decrease debug time scale
  * `H` — toggle hitbox rendering (`FlxG.debugger.drawDebug`)

---

Gameplay
--------

* Goal: survive for **60 seconds**.
* Obstacles spawn randomly; speed increases every **10 seconds** (stepped difficulty).
* If you collide with any obstacle → **Game Over**.
* If you survive 60s → **You Survived!** (win screen).

---

Development notes (useful functions & files)
--------------------------------------------

* `Paths.hx` — minimal asset helper used to load images/sounds and clear cache.
* `PlayState.hx` — main gameplay: spawn logic, step-based difficulty, player movement.
  * `spawnObstacle()` computes obstacle speed using stepped increases every 10s.
  * Player visuals driven by `Player.setMovementDirection(dir)`; call after movement updates to avoid animation twitching.
* `Hud.hx` — shows timer, help text, overlay for Game Over / Win.
* Restart: `FlxG.resetState()` is used to restart cleanly.

---

### Useful commands

```bash
# Run the project in debug mode (enables debugger)
lime test html5 -debug

# Clear HaxeFlixel caches or rebuild if assets changed
lime clean
lime rebuild
```
