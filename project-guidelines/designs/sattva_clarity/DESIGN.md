# Design System: Editorial Enlightenment

## 1. Overview & Creative North Star
The Creative North Star for this design system is **"The Digital Sanctuary."** 

Unlike standard utilitarian apps, this system treats digital space as a physical place of reflection. We move away from the "app-like" grid of buttons and borders toward a high-end editorial experience. The design achieves this through **intentional asymmetry**, where scripture is given the "breath" of a physical manuscript, and UI elements are treated as secondary tools that fade into the background when not in use. By utilizing high-contrast typography scales and substantial whitespace, we create a sense of spiritual clarity and premium intentionality.

## 2. Colors & Surface Philosophy

The color palette is anchored in a pure `#FFFFFF` background, accented by a sacred saffron (`#FF7722`). This is not a flat interface; it is a layered environment.

### The "No-Line" Rule
Explicitly, **1px solid borders are prohibited** for sectioning content. To define boundaries, designers must use background color shifts. For example, a "Chapter Selection" section should use `surface-container-low` (#f3f3f4) sitting atop a `surface` (#f9f9f9) background. 

### Surface Hierarchy & Nesting
Treat the UI as a series of stacked sheets of fine paper.
*   **Base:** `surface` (#f9f9f9)
*   **Lower Priority/Nesting:** `surface-container-low` (#f3f3f4)
*   **Interactive Cards:** `surface-container-lowest` (#ffffff) to provide a subtle "lift" against the background.

### Signature Textures & Glassmorphism
To avoid a generic feel, floating elements (like the audio playback bar or navigation overlays) must utilize **Glassmorphism**. Use semi-transparent surface colors with a `backdrop-blur` of 20px-30px. This ensures the scripture text remains the primary focus while the UI feels integrated rather than "pasted on." For primary CTAs, apply a subtle linear gradient from `primary` (#9f4200) to `primary_container` (#ff7722) to add tonal depth.

## 3. Typography: The Editorial Voice

The system uses a dual-font approach to separate the eternal (scripture) from the ephemeral (UI).

*   **Scripture (The Eternal):** Utilizes **Noto Serif**. This is the heart of the experience. `display-lg` and `headline-lg` are used for verse numbers and major headings to create an authoritative, manuscript-like feel.
*   **UI (The Ephemeral):** Utilizes **Manrope**. A clean, modern sans-serif that provides functional clarity without competing with the scripture. 

The typographic hierarchy is exaggerated. We use `spacing.16` (5.5rem) above major chapter headings to emphasize the transition into a new state of mind.

## 4. Elevation & Depth

We eschew traditional drop shadows in favor of **Tonal Layering**.

*   **The Layering Principle:** Place a `surface-container-lowest` card on a `surface-container-low` background to create a soft, natural lift. 
*   **Ambient Shadows:** If a floating element requires a shadow (e.g., the audio controller), it must be extra-diffused. Use a blur of 32px and an opacity of 4% using the `on-surface` color (#1a1c1c). This mimics natural ambient light.
*   **The Ghost Border Fallback:** If a container requires definition against an identical background color, use a "Ghost Border": `outline-variant` (#e0c0b1) at **15% opacity**. Never use a 100% opaque border.

## 5. Components

### Navigation & Chapter Controls
*   **Chapter Chips:** Use `md` (0.75rem) roundness. The container should be `surface-container` (#eeeeee) with `on-surface` text. When active, transition to `primary_container` (#ff7722) with `on-primary_container` (#5e2400) text.
*   **Full-Width Rows:** Component rows must extend to the screen edge. Use `spacing.4` for internal padding, ensuring that the "white space" creates the visual separation rather than lines.

### Buttons & Inputs
*   **Primary Button:** Saffron gradient (`primary` to `primary_container`), `md` (0.75rem) corner radius. Use `title-md` for the label to maintain an elegant weight.
*   **Inputs:** Use `surface-container-lowest` for the field background. Labels must be in `label-md` using `on-surface-variant` (#584237).

### Cards & Lists
*   **No Dividers:** Forbid the use of divider lines. Separate list items using `spacing.3` (1rem) or subtle background shifts between `surface` and `surface-container-low`.

### Audio/Media Floating Bar
*   **Styling:** Must use the "Glassmorphism" rule. High backdrop-blur, `surface-container-lowest` at 80% opacity, and `xl` (1.5rem) corner radius for a soft, pill-like feel that floats at the bottom of the viewport.

## 6. Do's and Don'ts

### Do
*   **Do** use extreme whitespace (Spacing 12+) between major thematic sections to encourage a slow, mindful reading pace.
*   **Do** use `notoSerif` for all verse numbers, even when they appear in UI lists, to maintain the "Scripture First" identity.
*   **Do** prioritize the saffron accent (`#FF7722`) only for moments of enlightenment (Active states, CTAs, Verse highlights).

### Don't
*   **Don't** use black (#000000). Always use `on-surface` (#1a1c1c) for text to keep the contrast soft and readable for long periods.
*   **Don't** use standard 4px or 6px radiuses. Stick to the `md` (8-12px) scale to ensure the UI feels "soft" and approachable.
*   **Don't** cram content. If a screen feels busy, increase the spacing tokens until the "sanctuary" feel returns.