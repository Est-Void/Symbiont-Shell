# Symbiont Shell — Design Identity

Design system for the Symbiont Shell desktop environment (QML / Qt 6).
Visual language: **Nothing OS** — monochrome, technical, confident, slightly brutalist.
This document is normative. If a value is not in here, do not invent one.

Inspiration assets live in `assets/` (Nothing OS 3.x / OS 4, Nothing widgets, Nothing
print/brand material). Treat them as reference, not as files to copy.

---

## 0. Non-negotiable rules (read first)

1. **Monochrome first.** Black, white and neutral greys carry ~90% of every screen.
   Exactly **one** accent: Nothing Red. Red covers **≤ 2%** of the viewport.
2. **No gradients, no glows, no colored icons, no emoji, no serif fonts.**
   Exceptions: OS 4-style translucent "glass" surfaces (§6) and the red mascot
   sphere (§7.3) — a hero graphic, not a colored icon.
3. **Shape is the identity.** Pills (full radius), circles, and superellipse
   (squircle) cards. Never a large card with a small radius.
4. **Typography does the work.** Uppercase mono labels with wide tracking +
   dot-matrix numerals for time/counters. Never dot-matrix for sentences.
5. **Flat by default.** Elevation comes from surface lightness + 1px hairline
   border + blur, not from drop shadows.
6. **Every token comes from `Theme`.** No hardcoded hex, radius, spacing or
   duration in component code (§12).
7. **Hover, focus and keyboard navigation are mandatory on desktop.** The phone
   references have no pointer states — this shell does (§11).
8. When in doubt: remove color, remove shadow, remove rounding, add space.

---

## 1. Principles

| Principle | Meaning in practice |
|---|---|
| **Transparent, not decorative** | Show the system state plainly. No ornamental chrome. |
| **Technical honesty** | Mono metadata, IDs, units, registration marks. UI looks like an instrument. |
| **Monochrome contrast** | Pure black canvas, pure white content. Greys only separate layers. |
| **One loud moment** | A screen gets one red highlight or one oversized dot-matrix number. Not both competing. The mascot sphere (§7.3) is that highlight and hides while the OSD is visible. |
| **Soft hardware** | Pills and squircles soften an otherwise strict, industrial layout. |
| **Density with air** | Dense information inside cards, generous negative space between groups. |
| **Motion as signal** | Short, mechanical, purposeful. Never playful bouncing. The mascot (§7.3) uses the same restrained vocabulary to report state. |

---

## 2. Color

### 2.1 Rules

- Base canvas is **pure black** `#000000` (OS 3.x) or near-black `#0A0A0A` (OS 4 glass).
- Layers are separated by **surface lightness steps**, not shadows.
- Text is white on dark, near-black on light. Greys are for secondary metadata only.
- **Primary action = inverse fill**: white pill, black label (dark mode). Red is
  *not* the default button color.
- **Red is a signal, not a theme**: destructive action, recording/live, selected
  special toggle, status dot, or one hero graphic (the mascot sphere, §7.3).
- Never introduce green/yellow/blue for success/warning. Success is a white dot or
  a neutral label. Error is red. Warning is white text on a grey chip.
- Text on red must be white. Red text on black is allowed only at ≥ 18px / bold or
  for icons (contrast ≈ 4.0:1).

### 2.2 Dark theme tokens (default)

| Token | Hex / value | Use |
|---|---|---|
| `bgBase` | `#000000` | Window / canvas |
| `bgRaised` | `#0A0A0A` | Full-screen panels |
| `surface1` | `#141414` | Widget / card background |
| `surface2` | `#1C1C1C` | Inputs, nested cards, hovered cards |
| `surface3` | `#262626` | Pressed card, well, inactive track |
| `surfaceInverse` | `#F2F2F2` | Inverted card, primary pill |
| `textPrimary` | `#FFFFFF` | Headings, values, labels |
| `textSecondary` | `#A6A6A6` | Supporting text (8.6:1) |
| `textTertiary` | `#6B6B6B` | Micro-metadata only (3.9:1, non-essential) |
| `textInverse` | `#0A0A0A` | Text on white surfaces |
| `borderSubtle` | `#14FFFFFF` | Card hairline (8% white, ARGB) |
| `borderDefault` | `#24FFFFFF` | Inputs, dividers (14%) |
| `borderStrong` | `#3DFFFFFF` | Focused / glass edge (24%) |
| `accent` | `#D71921` | Nothing Red |
| `accentHover` | `#E8353B` | Hover on red |
| `accentPressed` | `#A81218` | Pressed red |
| `onAccent` | `#FFFFFF` | Text/icon on red |
| `accentMuted` | `#26D71921` | Red tint fill (15%) |
| `scrim` | `#B3000000` | Modal backdrop (70%) |
| `disabled` | 38% opacity | Applied to any disabled content |

### 2.3 Light theme tokens

| Token | Hex | Use |
|---|---|---|
| `bgBase` | `#F2F2F2` | Window / canvas |
| `bgRaised` | `#FAFAFA` | Panels |
| `surface1` | `#FFFFFF` | Cards |
| `surface2` | `#E9E9E9` | Inputs, nested cards |
| `surface3` | `#DEDEDE` | Pressed / track |
| `surfaceInverse` | `#0A0A0A` | Inverted card, primary pill |
| `textPrimary` | `#0A0A0A` | Headings, values |
| `textSecondary` | `#5A5A5A` | Supporting text (6.2:1) |
| `textTertiary` | `#8C8C8C` | Micro-metadata only |
| `textInverse` | `#F5F5F5` | Text on black surfaces |
| `borderSubtle` | `#14000000` | Card hairline (8% black) |
| `borderDefault` | `#24000000` | Inputs, dividers |
| `borderStrong` | `#3D000000` | Focused / glass edge |
| `accent` / `accentHover` / `accentPressed` | same as dark | `#D71921` / `#E8353B` / `#A81218` |

### 2.4 Opacity ladder

Use only these overlay opacities for states and hairlines:
`4% · 8% · 12% · 16% · 24% · 40% · 64% · 88%`.

| State | Dark | Light |
|---|---|---|
| Hover overlay | white 6–8% | black 6–8% |
| Pressed overlay | white 12% | black 12% |
| Selected overlay | white 16% | black 12% |
| Disabled | 38% content opacity | 38% content opacity |

### 2.5 Color ratio budget

- ~88% black / near-black / neutral surface
- ~8% white / light-grey content
- ~2% red maximum
- One accent hue only. A second hue is a bug.

---

## 3. Typography

### 3.1 Families

Nothing's real typefaces (Ndot-55/57, NType82) are proprietary. **Do not ship or
redistribute them** unless a license is present in the repo. Use open substitutes:

| Role | Nothing reference | Default open substitute | Fallback |
|---|---|---|---|
| UI / body | NType82 | **Inter** (400/500/600) | system sans |
| Display / headlines | NType82 Bold | **Archivo** (600/700) | Inter |
| Labels / metadata | Nothing technical mono | **Space Mono** (400/700) | IBM Plex Mono, monospace |
| Dot-matrix numerals | Ndot 57 | **Doto** (variable) | Handjet |
| Optional pixel glyphs | Nothing Font 5×7 | **Departure Mono** | Doto |

Rules:
- Maximum **three** families per screen (UI + mono + one of dot/pixel).
- Font weights: 400, 500, 600, 700 only.
- If the licensed Nothing fonts are added later, put them in `assets/fonts/` and
  swap them in `Theme.font`; do not change sizes or tracking.

### 3.2 Type scale (desktop, logical px at 1×)

| Token | Family | Size | Weight | Line height | Tracking | Case |
|---|---|---|---|---|---|---|
| `display.hero` | Dot | 96 | 400 | 1.0 | +0.04em | numerals only |
| `display.xl` | Display | 48 | 700 | 1.05 | −0.02em | Sentence |
| `display.lg` | Display | 32 | 700 | 1.10 | −0.01em | Sentence |
| `title` | Display | 24 | 600 | 1.20 | −0.01em | Sentence |
| `heading` | UI | 20 | 600 | 1.25 | 0 | Sentence |
| `body` | UI | 16 | 400 | 1.50 | 0 | Sentence |
| `body.sm` | UI | 14 | 400 | 1.45 | 0 | Sentence |
| `label` | Mono | 12 | 400 | 1.20 | +0.08em | UPPERCASE |
| `label.sm` | Mono | 10 | 400 | 1.20 | +0.12em | UPPERCASE |
| `mono.value` | Mono | 13 | 400 | 1.40 | +0.02em | Mixed |
| `numeric.dot` | Dot | 32–64 | 400 | 1.0 | +0.04em | Numerals |
| `numeric.mono` | Mono | 20–32 | 400 | 1.0 | +0.04em | Tabular |

### 3.3 Typography rules

- **Uppercase mono labels with wide tracking are the signature.** Use them for
  section headers, metadata, units, widget captions (`SCREEN TIME`, `BATTERY`,
  `TUE 30 DEC`, `REG A/02`).
- **Dot-matrix is for numbers and single glyphs only**, minimum 24px so dots stay
  legible. Never set labels, sentences or long values in dot-matrix.
- Dot-matrix numerals should be **tabular** (fixed advance); use `font.features`
  or pad values so digits do not jump.
- Headlines are sentence case. Do not set whole sentences in uppercase.
- Negative tracking only on display sizes; never negative-track mono labels.
- Metadata may be set in `textTertiary` — never essential copy.
- No italics. No underlines except inline links (underline 1px, offset 3px).
- Line length: 45–75 characters for body text.

### 3.4 QML font loading

```qml
FontLoader { source: "qrc:/fonts/Inter-Regular.ttf";  id: inter }
FontLoader { source: "qrc:/fonts/SpaceMono-Regular.ttf"; id: mono }
FontLoader { source: "qrc:/fonts/Doto-Variable.ttf";  id: doto }

Text {
    text: "SCREEN TIME"
    font.families: Theme.font.mono      // list for fallback (Qt 6)
    font.pixelSize: Theme.type.label.size
    font.letterSpacing: Theme.type.label.tracking
    font.capitalization: Font.AllUppercase
}
```

---

## 4. Shape

### 4.1 Radius tokens

| Token | Value | Use |
|---|---|---|
| `radius.xs` | 8 | Tiny chips, tags, progress ends |
| `radius.sm` | 12 | Small icon tiles, inner elements |
| `radius.md` | 16 | Inputs, small cards |
| `radius.lg` | 24 | Standard cards, popovers |
| `radius.xl` | 32 | Widgets, panels, sheets |
| `radius.2xl` | 40 | Hero cards, large dialogs |
| `radius.pill` | 9999 | Buttons, chips, toggles, docks |
| `radius.circle` | 50% | Icon buttons, dots, avatars |

### 4.2 Squircle (superellipse) — the signature card shape

Nothing cards and app tiles are **squircles**, not rounded rectangles.
Approximation: superellipse with exponent **n ≈ 4** for cards, **n ≈ 3.5** for icons.

- Widgets / cards: squircle, padding 20, `surface1`, 1px `borderSubtle`.
- Icon tiles / app icons: squircle, n ≈ 3.5.
- Never mix a squircle card with a plain rounded rectangle of similar size in the
  same group.

QML recipe (sampled polyline — accurate, cheap, no shader):

```qml
Shape {
    preferredRendererType: Shape.CurveRenderer
    ShapePath {
        fillColor: Theme.color.surface1
        strokeWidth: 1
        strokeColor: Theme.color.borderSubtle
        PathPolyline {
            property real n: 4
            path: {
                const pts = [], N = 72, cx = width / 2, cy = height / 2
                for (let i = 0; i <= N; ++i) {
                    const t = i / N * Math.PI * 2
                    const c = Math.cos(t), s = Math.sin(t)
                    const x = Math.sign(c) * Math.pow(Math.abs(c), 2 / n)
                    const y = Math.sign(s) * Math.pow(Math.abs(s), 2 / n)
                    pts.push(Qt.point(cx + cx * x, cy + cy * y))
                }
                return pts
            }
        }
    }
}
```

Encapsulate in `Squircle.qml`. Do not copy this block into every component.

### 4.3 Pills and circles

- Pill: radius = height / 2 (`radius.pill`). Used for all buttons, chips,
  switches, toggles, sliders, docks, notification banners.
- Circle: icon buttons, status dots, bottom-dock app icons.
- Diameters: icon button **40** (compact) / **44** (default) / **56** (hero/touch).
- Status dot: **4–6px**; optional 1px ring at 24% white.

### 4.4 Borders and strokes

- Hairline = **1px**, never 2px for static borders.
- Icons = 1.5px stroke, rounded caps and joins.
- Focus ring = 2px accent, 2px offset (outside the element).
- Dividers: 1px `borderDefault`, or a **dotted/dashed** 1px line for technical blocks.
- Inner borders and engraved lines use white 8% on dark, black 8% on light.

---

## 5. Spacing and layout

### 5.1 Spacing scale (4pt base)

`2 · 4 · 8 · 12 · 16 · 24 · 32 · 48 · 64 · 96`

| Context | Value |
|---|---|
| Icon ↔ label | 8 |
| Inside button (horizontal) | 16 (sm 12, lg 20) |
| Card padding | 20 (small 16, hero 24) |
| Gap between widgets | 16 |
| Gap between sections | 32 |
| Page margin (window) | 24 (compact) / 32 |
| Panel inner gap | 24 |
| Dock padding | 12 |

Use only values from the scale. Odd values are a bug.

### 5.2 Desktop layout

| Item | Value |
|---|---|
| Min window | 960 × 640 |
| Default window | 1280 × 800 |
| Side panel width | 320 / 360 |
| Command palette max width | 640 |
| Notification width | 360 |
| Dock height | 64 (pill radius 32) |
| Dock icon | 44 circle, gap 12 |
| Top bar height | 44 |
| Widget unit (1×1) | 168 × 168 |
| Widget 2×1 / 1×2 | 352 × 168 / 168 × 352 |
| 12-col grid, gutter | 16 |
| Scrollbar | 4px, pill, white 24%, auto-hide, no arrows |

Rules:
- Content is left-aligned by default; hero/clock blocks may be centered.
- Anchor micro-metadata to card corners (top-left label, top-right value/unit).
- Keep one dominant element per screen (usually the clock or one large widget).
- Do not rotate functional UI. The tilted/overlapping widgets in the references
  are marketing compositions, not runtime layouts.
- Photo/album tiles may use a 2px white frame and `radius.xl`; use sparingly.

---

## 6. Surface, elevation, glass

### 6.1 Flat mode (Nothing OS 3.x) — default

| Level | Composition | Example |
|---|---|---|
| 0 | `bgBase` | window |
| 1 | `surface1` + 1px `borderSubtle` | widget, card |
| 2 | `surface2` + 1px `borderDefault` | nested card, input |
| 3 | `surfaceInverse` (white) | inverted callout, primary pill |
| 4 | `scrim` + `surface1` | modal, command palette |

No drop shadows. If a floating element (dock, popover) needs separation, one soft
shadow only: `y=12, blur=40, color #59000000` — nothing stronger.

### 6.2 Glass mode (OS 4) — optional, desktop panels only

- Fill: black 64% (dark) / white 72% (light).
- Blur: 32–48px. Border: 1px `borderStrong`.
- Never glass-on-glass. Never glass for body text surfaces.
- Performance: blur the wallpaper **once** into a cached layer; do not run a
  live backdrop blur per frame.

### 6.3 Texture

- Fine monochrome noise/grain at **2–4% opacity** is allowed on hero surfaces.
- No images behind body text. No colored photography except media/album art.

---

## 7. Iconography and graphic motifs

### 7.1 Icons

- 24×24 grid, 1.5px stroke, geometric, rounded line caps, no filled detail.
- Monochrome only (white on dark, black on light). Never multicolor.
- App glyphs sit inside **circles**: white circle + black glyph, or black circle +
  white glyph. Red glyph only for a "live/record/camera" state.
- Do not mix icon families. Use one line set (e.g. Lucide/Phosphor regularly sized)
  and adjust stroke to 1.5.

### 7.2 Signature motifs

Use these sparingly to make the UI feel like Nothing (2–4 per screen, not all):

- **Dot-matrix numerals**: time, percentage, timers, step counts, temperatures.
- **Red status dot** (4–6px) with an optional 1px ring.
- **Registration/crosshair marks**: 1px plus or cross at card corners, 40% white.
- **Dotted dividers**: 1px dotted `borderDefault`.
- **Mono metadata**: tiny uppercase registration/ID strings (`REG A/02`,
  `UNITED FLIGHT`, `DMP-01`, units, firmware).
- **Long-stem arrow** (`→`) as a directional glyph.
- **Dotted/dithered circle**: 7×7 dot cluster used as an abstract glyph.
- **Barcode strip**: monochrome, only in technical/info cards.
- **Inverted white pill** inside a dark layout for one label (e.g. `TUESDAY`).
- **Oversized numeral bleeding to the card edge** (clipped by the squircle).
- **Companion glyph**: the mascot (§7.3), one per screen, in the top bar only.

Never: emoji, colored illustrations, 3D renders, skeuomorphic hardware, glossy
highlights, rainbow gradients.

### 7.3 Mascot (companion glyph)

One animated companion is allowed in the top bar: a broken **ring** in
`textPrimary` plus a single red **sphere** (`accent`) as its eye. It is the one
hero graphic on screen (§1) and is hidden whenever an OSD is visible, so red
never appears twice at once.

- Geometry: 24px ring (`Theme.size.mascotRingRadius` = 12), hosted in the top
  bar box. Sphere diameter = `2 × ringRadius × mascotSphereRatio` (0.55).
  Ring gap `40°`, narrowing while asleep.
- Stroke: `Theme.size.mascotArcWidth` = 2px, round caps/joins. No fill, no glow,
  no second hue, no gradient, no shadow.
- States: idle gaze (pointer / compositor), blink, sleep, roll, volume morph.
  These report pointer or system state — never a loop for its own sake.
- Ambient intervals (§9) may loop. Transitions stay inside the 80–320ms scale,
  translation ≤ 8px, scale ≤ 1.02, no bounce and no rotation of functional UI.
- Under `reducedMotion`, every ambient timer stops and the mascot snaps to its
  neutral open-eye, centred-gaze state.
- Set `Accessible.role: Graphic` and a stable `Accessible.name`. State must never
  be carried by the mascot alone — pair it with the OSD label.

---

## 8. Components

All sizes are logical px. All colors/radii/spacings reference `Theme`.

### 8.1 Button

| Variant | Background | Label | Border | Use |
|---|---|---|---|---|
| Primary | `surfaceInverse` | `textInverse` | none | main action |
| Secondary | `surface2` | `textPrimary` | 1px `borderDefault` | normal action |
| Ghost | transparent | `textPrimary` | none | toolbars, low emphasis |
| Danger | `accent` | `onAccent` | none | destructive/record only |

- Height: 32 (sm) / 40 (md) / 48 (lg). Radius: pill.
- Horizontal padding 12 / 16 / 20. Gap 8. Label: `body` or `body.sm` (600).
- States: hover overlay, pressed overlay, disabled 38%, focus ring 2px accent.
- Never put a red button next to another red button.
- Icon-only buttons are circles (40/44), never squares.

### 8.2 Chip / filter

- Pill, height 32, padding 12, bg `surface2`, label `label` (mono uppercase).
- Selected: `surfaceInverse` + `textInverse`. Optional red dot for live items.
- Gap 8, wrap allowed.

### 8.3 Toggle

- Track 48×28 pill; knob 22 circle; 3px inset.
- Off: track `surface3`, knob `textSecondary`.
- On: track white, knob black (or track red with white knob for special/live).
- Animate knob with a spring, 1 frame of overshoot max.

### 8.4 Icon button

- Circle 40/44/56, bg `surface1` (or `surfaceInverse` for featured).
- Glyph 20/24, 1.5px stroke.
- Active/pressed: bg `surface3`; live: red dot badge at top-right (6px, 1px
  `bgBase` ring).

### 8.5 Slider

- Track 4px pill (`surface3`), fill `textPrimary` (or `accent` for volume/record).
- Knob 16px circle, white, 1px `borderStrong`.
- Height 44 hit area. No ticks, no gradient.

### 8.6 Widget / card

- Squircle (§4.2), `surface1`, 1px `borderSubtle`, padding 20.
- Header row: mono `label` left, value/units right in `mono.value`.
- One value hierarchy: big numeric (dot-matrix if possible) + small mono caption.
- Optional corner marks, dotted divider, red dot.
- Allowed variants: flat dark, inverted white, single red card (max one per view),
  photo tile (2px white frame).
- Cards never scroll internally unless the content is a list; pages scroll instead.

### 8.7 Dock

- Floating pill, height 64, padding 12, gap 12.
- Default: `surface1` + `borderSubtle`. Glass mode: blur + 64% fill.
- App icons: 44 circles, 12 gap, 1px border; hover ring 1px `borderStrong`.
- Active app: white circle + black glyph, plus a 4px red dot below (2px gap).
- Click target is the full 44 circle; never shrink the hit area.

### 8.8 Notification / banner

- Pill or `radius.lg` card, width 360, padding 16, `surface1`.
- Left: mono label (app/time, uppercase, 10–12px). Right: close icon button.
- Optional red dot / red accent bar 3px for urgent.
- Body: `body.sm`, max 2 lines, ellipsis.
- Enter: fade + 8px slide down, 200ms.

### 8.9 List row

- Height 44 (compact 36), horizontal padding 12, radius `radius.sm` on hover.
- Leading 24 icon, title `body.sm`, trailing value in `mono.value` / `textSecondary`.
- Divider: 1px `borderSubtle`, inset 44 from left.
- Hover: `surface2`; selected: `surface3`; focus ring outside.

### 8.10 Text input

- Pill (`radius.pill`) or `radius.md` for multiline, height 40.
- Bg `surface2`, 1px `borderDefault`; placeholder `textTertiary`.
- Focus: 2px accent ring, 2px offset; caret 2px white.
- No inner shadow. No white background in dark mode.

### 8.11 Scrollbar

- 4px wide, pill, `borderStrong`, auto-hide after 1s, no arrows, no track fill.
- Hover expands to 6px, never overlaps content padding.

---

## 9. Motion

| Token | Duration | Use |
|---|---|---|
| `motion.instant` | 80 ms | hover, color/opacity changes |
| `motion.fast` | 140 ms | press, toggle, checkbox |
| `motion.base` | 200 ms | expand, panel content, notification |
| `motion.slow` | 320 ms | sheet, modal, page transition |

Easings:
- Enter / appear: `Easing.OutCubic`
- Move / morph: `Easing.InOutCubic`
- Hero / large surface: `Easing.OutQuint`
- Toggle knob: spring, `stiffness 380`, `damping 30`, `mass 1`

Mascot ambient tokens (§7.3) — all stop under reduced motion:

| Token | Value (ms) | Use |
|---|---|---|
| `blink` | 3700 | Blink interval |
| `blinkMove` | 90 | Lid close / open |
| `blinkHold` | 150 | Closed hold |
| `doubleBlinkGap` | 150 | Optional second blink |
| `saccade` | 110 | Gaze jump |
| `saccadeHold` | 180 | Minimum gap between gazes |
| `idleGaze` | 2400 | Idle wander interval |
| `wanderAfter` | 4500 | Idle threshold |
| `play` | 4000 | Roll check interval |
| `roll` | 900 | Roll at 180° |
| `rollHold` | 120 | Hold after roll |
| `arcTurn` | 8000 | Ring re-aim interval |
| `sleepAfter` | 16000 | Idle → sleep |
| `sleepCheck` | 700 | Idle polling |
| `pollActive` / `pollIdle` | 90 / 240 | Pointer polling |

Rules:
- Animate opacity and 8px max translation. No scale above 1.02. No rotation of
  functional UI — the mascot ring (§7.3) is exempt.
- Dot-matrix values do not interpolate — swap with a 2-frame flicker (60 ms).
- No looping decorative animation except (a) a 1.5s pulse on a live red dot and
  (b) the mascot's ambient states (§7.3), which report state rather than decorate.
- Respect reduced motion: all durations → 80 ms, springs → linear, disable flicker
  and pulse, and freeze the mascot (§7.3) in its neutral state with every ambient
  timer stopped.

---

## 10. Interaction states

| State | Change |
|---|---|
| Hover (desktop only) | overlay 6–8%; cursor pointing hand on interactive elements |
| Pressed | overlay 12%; optional 1px inward offset (no scale) |
| Focus (keyboard) | 2px `accent` ring, 2px offset, always visible |
| Disabled | 38% opacity, no hover; not focusable |
| Selected | 16% overlay or inverse fill + inverse text |
| Dragging | 8% overlay + `borderStrong`; no shadow |

- Use `HoverHandler` / `TapHandler` / `Keys` navigation; do not rely on touch only.
- Right-click context menus use the same flat card style (`radius.md`, `surface1`,
  1px border), rows 32px, no separators except 1px `borderSubtle`.
- Tooltips: pill, `surfaceInverse` + `textInverse`, 11px label, 200ms delay.

---

## 11. Accessibility

- Body text contrast ≥ 4.5:1; large text and icons ≥ 3:1.
  `textPrimary` on black ≈ 21:1, `textSecondary` ≈ 8.6:1, red on black ≈ 4.0:1
  (large/icons only), white on red ≈ 5.2:1.
- Never encode meaning with color alone: pair red with a label, icon or dot ring.
- Focus must be visible on every interactive element; do not use `outline: none`
  equivalents without a replacement.
- Hit targets: ≥ 44×44 for primary controls; ≥ 32×32 minimum for dense desktop
  toolbars. Dock icons keep the full 44 circle.
- Support keyboard-only operation for all shell surfaces (dock, panels, palette).
- Support reduced motion (§9) and both themes (§2.2 / §2.3).
- Do not set font sizes below 10px. Dot-matrix below 24px is unreadable — avoid.

---

## 12. QML implementation

### 12.1 Token architecture

- Single `Theme` singleton (`pragma Singleton`, registered via `qmldir`).
- Group tokens: `Theme.color`, `Theme.font`, `Theme.type`, `Theme.radius`,
  `Theme.space`, `Theme.motion`, `Theme.size`, `Theme.mode`.
- Themes are two `QtObject` instances (`darkTokens`, `lightTokens`) selected by
  `Theme.mode`; components read `Theme.color.*`, never `#hex`.
- No component may define its own palette, radius scale or duration constants.

```qml
pragma Singleton
import QtQuick

QtObject {
    id: root
    property string mode: "dark"

    readonly property QtObject _dark: QtObject {
        readonly property color bgBase: "#000000"
        readonly property color surface1: "#141414"
        readonly property color surface2: "#1C1C1C"
        readonly property color textPrimary: "#FFFFFF"
        readonly property color textSecondary: "#A6A6A6"
        readonly property color borderSubtle: "#14FFFFFF"
        readonly property color accent: "#D71921"
        readonly property color onAccent: "#FFFFFF"
    }

    readonly property QtObject _light: QtObject { /* §2.3 */ }

    readonly property QtObject color: mode === "dark" ? _dark : _light

    readonly property QtObject radius: QtObject {
        readonly property int xs: 8
        readonly property int sm: 12
        readonly property int md: 16
        readonly property int lg: 24
        readonly property int xl: 32
        readonly property int xxl: 40
        readonly property int pill: 9999
    }

    readonly property QtObject space: QtObject {
        readonly property int xs: 4
        readonly property int sm: 8
        readonly property int md: 16
        readonly property int lg: 24
        readonly property int xl: 32
    }

    readonly property QtObject motion: QtObject {
        readonly property int instant: 80
        readonly property int fast: 140
        readonly property int base: 200
        readonly property int slow: 320
    }
}
```

### 12.2 Qt / QML conventions

- Target **Qt 6.5+**, `QtQuick` + `QtQuick.Controls` with `Basic` style
  (`QQuickStyle::setStyle("Basic")`). Never Material/Universal/Implicit defaults.
- Set `background: null` and draw custom backgrounds; do not restyle Controls with
  platform defaults.
- Reusable components in `ui/components/`: `Squircle.qml`, `NButton.qml`,
  `NIconButton.qml`, `NToggle.qml`, `NCard.qml`, `NChip.qml`, `NDock.qml`,
  `NText.qml`. Keep one component per file, PascalCase filenames.
- Default properties: declare and document `property string variant`, `size`,
  `text`, `icon`; avoid boolean soup.
- Use `Behavior`/`NumberAnimation` with `Theme.motion.*`, never magic 250.
- Use `MultiEffect` for blur/opacity/shadow; one effect per item. Avoid `ShaderEffect`
  unless measured necessary.
- Crisp small text: `renderType: Text.NativeRendering` for mono labels at 10–12px;
  keep `Text.QtRendering` for scaled/dot-matrix and transformed text.
- Scale: design in logical px; Qt handles `devicePixelRatio`. Test 1×, 1.5×, 2×.
  Never round radius by hand; avoid `Math.floor` on layout values.
- Icons: prefer SVG at 24px with 1.5 stroke; do not scale bitmaps.
- Accessibility: set `Accessible.name` / `Accessible.role` on custom controls.
- Loading: bundle fonts via Qt resources; no runtime network fonts.

### 12.3 Anti-patterns (code review will reject)

```qml
color: "#1C1C1C"                 // hardcoded token
radius: 10                       // off-scale radius
Rectangle { radius: 8; ... }     // big card with tiny radius
layer.effect: DropShadow {}      // decorative shadow
gradient: Gradient { ... }       // gradients (except subtle glass fill)
icon.color: "#4CAF50"            // non-monochrome icon
font.family: "Arial"             // off-system font
```

---

## 13. Review checklist

Before calling any UI task done:

- [ ] Colors only from `Theme.color`; no second accent hue; red ≤ 2% of viewport;
      the mascot sphere is the single hero red and hides during the OSD.
- [ ] Radii from the scale; large cards are squircles/pills, not 8px rectangles.
- [ ] Uppercase mono labels with correct tracking; dot-matrix ≥ 24px, numerals only.
- [ ] Spacing only from the 4pt scale; grid/gutters respected.
- [ ] No gradients, glows, colored icons, emoji, serif, or decorative shadows.
- [ ] Hover / pressed / focus / disabled / selected states implemented.
- [ ] Keyboard navigation + visible focus ring; hit targets ≥ 44 (≥ 32 dense).
- [ ] Contrast checked; red never used for small body text.
- [ ] Motion tokens used; reduced-motion honored (mascot frozen); no loops except
      the live-dot pulse and mascot ambient states (§7.3, §9).
- [ ] Both dark and light themes render correctly.
- [ ] Fonts bundled; no proprietary Nothing fonts unless licensed in-repo.
- [ ] Works at 1×, 1.5×, 2× and at minimum window size.

---

## 14. Reference index

| File | What to take from it |
|---|---|
| `assets/Nothing-OS-4-notification-panel-*.jpg` | Pills, toggles, icon circles, mono labels, brightness slider, dark palette |
| `assets/jpg` | Widget grid, dot-matrix clock, mono metadata, inverted white cards, dock |
| `assets/jpg(1)` | Dot-matrix numerals, red accents, circular controls, technical motifs, red status |
| `assets/jpg(2)` | Squircle tiles, red accent tiles, dot calendar, inverted cards, spacing |
| `assets/Nothing Phone (2)_...jpg` | Dense monochrome widget wall, small type, balanced negative space |
| `assets/Nothing phone setup.jpg` | Dot-matrix time, red dot matrix, pill cards, media widget |
| `assets/aa117fbe-...png` | OS 4 glass, translucency, light mode |
| `assets/jpg(3)` | Print/brand language: mono metadata, registration marks, barcodes, angular wordmark |

The angular octagonal "NOTHING" wordmark is brand artwork — do not imitate it
with a font or use it in the shell UI.
