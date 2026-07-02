# Themes

This page is the canonical home for theme information. Related docs:

- [Inicio](../README.md)
- [Widget roadmap](roadmap.md)

The package now uses two theme groups.

## Diaspora

- `Dawn`: the existing day palette and styling.
- `Abyss`: the existing night palette and styling.

## Imperium

- `Hope`: gold, ochre, bronze, charcoal, silver, and black.
- `Dream`: beige, cream, steel gray, slate, dark charcoal, and white.

## API direction

- Theme grouping is represented by `FadingThemeGroup`.
- Concrete theme selection is represented by `FadingThemeName`.
- Resolve theme data with `FadingThemeData.fromTheme(...)`.
- `FadingThemeScope` stores the selected `theme` and its resolved `data`.

## Theme overview

`FadingThemeData` provides four built-in palettes grouped into Diaspora (`Dawn`, `Abyss`) and Imperium (`Hope`, `Dream`) plus semantic tokens for text, surfaces, controls, and progress states. Use `FadingThemeData.fromTheme(...)` to switch between the built-in themes, or construct your own theme data if you want a custom palette.

## Color reference

### Diaspora — Abyss

| Color | Hex | Preview |
|-------|-----|---------|
| midnight | #1A1824 | <span style="display:inline-block;width:40px;height:40px;background-color:#1A1824;border:1px solid #ccc;vertical-align:middle;"></span> |
| dusk | #2A2235 | <span style="display:inline-block;width:40px;height:40px;background-color:#2A2235;border:1px solid #ccc;vertical-align:middle;"></span> |
| dust | #3C2D3B | <span style="display:inline-block;width:40px;height:40px;background-color:#3C2D3B;border:1px solid #ccc;vertical-align:middle;"></span> |
| amberGlow | #EC8A54 | <span style="display:inline-block;width:40px;height:40px;background-color:#EC8A54;border:1px solid #ccc;vertical-align:middle;"></span> |
| ember | #CC5C4D | <span style="display:inline-block;width:40px;height:40px;background-color:#CC5C4D;border:1px solid #ccc;vertical-align:middle;"></span> |
| roseHaze | #D88AA1 | <span style="display:inline-block;width:40px;height:40px;background-color:#D88AA1;border:1px solid #ccc;vertical-align:middle;"></span> |
| starlight | #F1E6D9 | <span style="display:inline-block;width:40px;height:40px;background-color:#F1E6D9;border:1px solid #ccc;vertical-align:middle;"></span> |
| storm | #93879C | <span style="display:inline-block;width:40px;height:40px;background-color:#93879C;border:1px solid #ccc;vertical-align:middle;"></span> |
| border | #4B3B4E | <span style="display:inline-block;width:40px;height:40px;background-color:#4B3B4E;border:1px solid #ccc;vertical-align:middle;"></span> |
| success | #79B889 | <span style="display:inline-block;width:40px;height:40px;background-color:#79B889;border:1px solid #ccc;vertical-align:middle;"></span> |
| error | #D96D6D | <span style="display:inline-block;width:40px;height:40px;background-color:#D96D6D;border:1px solid #ccc;vertical-align:middle;"></span> |

### Diaspora — Dawn

| Color | Hex | Preview |
|-------|-----|---------|
| daybreak | #F8EFE4 | <span style="display:inline-block;width:40px;height:40px;background-color:#F8EFE4;border:1px solid #ccc;vertical-align:middle;"></span> |
| sunwash | #EBD9C7 | <span style="display:inline-block;width:40px;height:40px;background-color:#EBD9C7;border:1px solid #ccc;vertical-align:middle;"></span> |
| sand | #DFC6B3 | <span style="display:inline-block;width:40px;height:40px;background-color:#DFC6B3;border:1px solid #ccc;vertical-align:middle;"></span> |
| linen | #FFF8F0 | <span style="display:inline-block;width:40px;height:40px;background-color:#FFF8F0;border:1px solid #ccc;vertical-align:middle;"></span> |
| ink | #2D2332 | <span style="display:inline-block;width:40px;height:40px;background-color:#2D2332;border:1px solid #ccc;vertical-align:middle;"></span> |
| mist | #6F5F68 | <span style="display:inline-block;width:40px;height:40px;background-color:#6F5F68;border:1px solid #ccc;vertical-align:middle;"></span> |
| dayBorder | #CCB19F | <span style="display:inline-block;width:40px;height:40px;background-color:#CCB19F;border:1px solid #ccc;vertical-align:middle;"></span> |
| amberGlow | #EC8A54 | <span style="display:inline-block;width:40px;height:40px;background-color:#EC8A54;border:1px solid #ccc;vertical-align:middle;"></span> |
| ember | #CC5C4D | <span style="display:inline-block;width:40px;height:40px;background-color:#CC5C4D;border:1px solid #ccc;vertical-align:middle;"></span> |
| success | #79B889 | <span style="display:inline-block;width:40px;height:40px;background-color:#79B889;border:1px solid #ccc;vertical-align:middle;"></span> |
| error | #D96D6D | <span style="display:inline-block;width:40px;height:40px;background-color:#D96D6D;border:1px solid #ccc;vertical-align:middle;"></span> |

### Imperium — Hope

| Color | Hex | Preview |
|-------|-----|---------|
| imperialBlack | #121317 | <span style="display:inline-block;width:40px;height:40px;background-color:#121317;border:1px solid #ccc;vertical-align:middle;"></span> |
| imperialCharcoal | #26282E | <span style="display:inline-block;width:40px;height:40px;background-color:#26282E;border:1px solid #ccc;vertical-align:middle;"></span> |
| imperialBronze | #7B5A3A | <span style="display:inline-block;width:40px;height:40px;background-color:#7B5A3A;border:1px solid #ccc;vertical-align:middle;"></span> |
| imperialGold | #D1A446 | <span style="display:inline-block;width:40px;height:40px;background-color:#D1A446;border:1px solid #ccc;vertical-align:middle;"></span> |
| imperialOchre | #B6812B | <span style="display:inline-block;width:40px;height:40px;background-color:#B6812B;border:1px solid #ccc;vertical-align:middle;"></span> |
| imperialSilver | #D3D2D0 | <span style="display:inline-block;width:40px;height:40px;background-color:#D3D2D0;border:1px solid #ccc;vertical-align:middle;"></span> |
| imperialBorder | #5C4C35 | <span style="display:inline-block;width:40px;height:40px;background-color:#5C4C35;border:1px solid #ccc;vertical-align:middle;"></span> |
| success | #79B889 | <span style="display:inline-block;width:40px;height:40px;background-color:#79B889;border:1px solid #ccc;vertical-align:middle;"></span> |
| error | #D96D6D | <span style="display:inline-block;width:40px;height:40px;background-color:#D96D6D;border:1px solid #ccc;vertical-align:middle;"></span> |

### Imperium — Dream

| Color | Hex | Preview |
|-------|-----|---------|
| dreamWhite | #F8F8F6 | <span style="display:inline-block;width:40px;height:40px;background-color:#F8F8F6;border:1px solid #ccc;vertical-align:middle;"></span> |
| dreamCream | #F5EBDD | <span style="display:inline-block;width:40px;height:40px;background-color:#F5EBDD;border:1px solid #ccc;vertical-align:middle;"></span> |
| dreamBeige | #E0D1BF | <span style="display:inline-block;width:40px;height:40px;background-color:#E0D1BF;border:1px solid #ccc;vertical-align:middle;"></span> |
| dreamCharcoal | #2C3139 | <span style="display:inline-block;width:40px;height:40px;background-color:#2C3139;border:1px solid #ccc;vertical-align:middle;"></span> |
| dreamSlate | #6B7480 | <span style="display:inline-block;width:40px;height:40px;background-color:#6B7480;border:1px solid #ccc;vertical-align:middle;"></span> |
| dreamSteel | #8F99A6 | <span style="display:inline-block;width:40px;height:40px;background-color:#8F99A6;border:1px solid #ccc;vertical-align:middle;"></span> |
| dreamBorder | #B6AA9C | <span style="display:inline-block;width:40px;height:40px;background-color:#B6AA9C;border:1px solid #ccc;vertical-align:middle;"></span> |
| success | #79B889 | <span style="display:inline-block;width:40px;height:40px;background-color:#79B889;border:1px solid #ccc;vertical-align:middle;"></span> |
| error | #D96D6D | <span style="display:inline-block;width:40px;height:40px;background-color:#D96D6D;border:1px solid #ccc;vertical-align:middle;"></span> |