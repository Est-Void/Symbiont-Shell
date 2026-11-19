# AGENTS.md

Symbiont Shell — a desktop shell written in QML (Qt 6), styled after **Nothing OS**.

## Before any UI work

1. Read `docs/DESIGN.md`. It is the single source of truth for color, type,
   shape, spacing, motion and components.
2. Check `assets/` for visual reference. Do not copy files from `assets/` into the
   app; they are inspiration only.
3. Reuse existing components in `ui/components/` before creating new ones.

## Hard rules

- **Monochrome + one accent.** Black/white/greys carry ~90% of a screen.
  Only accent is Nothing Red `#D71921`, max ~2% of the viewport.
- **Primary action = white pill with black text** (dark mode), not red.
- **Shapes:** pills, circles, and squircles (superellipse, n≈4) for cards.
  Never a large card with a small radius.
- **Type:** Inter/Archivo for UI, Space Mono for uppercase labels with wide
  tracking, Doto for dot-matrix numerals (≥24px, numbers only).
  No serif, no italics, no emoji.
- **No gradients, glows, colored icons, or decorative drop shadows.**
  Elevation = surface lightness + 1px hairline + optional blur/glass.
- **No hardcoded design values.** Use the `Theme` singleton
  (`Theme.color.*`, `Theme.radius.*`, `Theme.space.*`, `Theme.motion.*`).
- Spacing on a 4pt scale; radii from the token scale; 1px hairlines.
- Desktop is first-class: implement hover, pressed, keyboard focus ring,
  44px hit targets, and both dark/light themes.
- Honor reduced motion. Motion is 80–320ms, no bouncing/looping decoration.

## QML conventions

- Qt 6.5+, `QtQuick` + `QtQuick.Controls` with the **Basic** style.
- Custom backgrounds only; no platform default Controls styling.
- One component per file, PascalCase (`NButton.qml`, `NCard.qml`, `Squircle.qml`).
- Use `MultiEffect` for blur/shadow, not decorative `DropShadow` stacking.
- Bundle fonts via Qt resources; never load fonts from the network.
- Proprietary Nothing fonts (Ndot, NType82) must not be committed unless a license
  is added to the repo.

## Project state

- No build system yet (only `README.md`, `docs/`, `assets/`).
- If a build/lint command is added, record it here and run it after changes.

## Definition of done

Run the review checklist at the end of `docs/DESIGN.md` (§13) before reporting
a UI task complete.
