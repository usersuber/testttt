# RottenFoodFuelB42

Build 42 Project Zomboid mod that lets rotten food be used as fuel in fuel-accepting heat sources such as fireplaces, campfires, wood stoves, and charcoal BBQs.

## Installation

1. Copy the `RottenFoodFuelB42` folder into your local `Zomboid/mods/` directory.
2. Start Project Zomboid Build 42.
3. Enable **RottenFoodFuelB42** from the in-game Mods menu before loading a save.

## Burn-time calculation

- Only rotten food items are treated as extra fuel.
- Burn time is based on the item's current weight.
- Formula: `minutes = clamp(weight * 15, 5, 90)`
- Examples:
  - `0.2` weight -> `5` minutes
  - `1.0` weight -> `15` minutes
  - `3.0` weight -> `45` minutes
  - `6.0+` weight -> `90` minutes max

The item is still consumed by the normal add-fuel action, so regular gameplay flow is preserved.
