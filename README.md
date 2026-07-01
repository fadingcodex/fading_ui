# fading_ui

Components and widgets inspired on Fading Suns, the TTRPG game.

## Features

- Runtime grouped theme support through `FadingThemeScope`.
- Reusable raised and inset neumorphic surfaces.
- Material and Cupertino free.
- Core components: button, card, surface, toast, and text field.
- Selection and control components: checkbox, switch, slider, radio group, and tab bar.
- Progress components: linear and circular progress indicators.
- Flutter-only implementation with no external neumorphism package.

## Documentation

- [Roadmap](docs/roadmap.md) for implemented widgets, planned widgets, and design direction.
- [Theme guide](docs/theme.md) for theme groups, API direction, and color reference.

## Getting started

Add the package to your app and apply the theme:

```dart
import 'package:flutter/widgets.dart';
import 'package:fading_ui/fading_ui.dart';

Widget buildApp() {
	return FadingThemeScope(
		theme: FadingThemeName.abyss,
		data: FadingThemeData.abyss,
		child: WidgetsApp(
			color: FadingThemeData.abyss.backgroundStart,
			debugShowCheckedModeBanner: false,
			pageRouteBuilder: <T>(RouteSettings settings, WidgetBuilder builder) {
				return PageRouteBuilder<T>(
					settings: settings,
					pageBuilder: (BuildContext context, _, _) => builder(context),
				);
			},
		),
		const SizedBox(height: 16),
		FadingCheckbox(
			value: true,
			onChanged: (bool value) {},
			label: 'Enable pulse lock',
		),
		const SizedBox(height: 16),
		FadingSwitch(
			value: false,
			onChanged: (bool value) {},
			label: 'Aux relay',
		),
		const SizedBox(height: 16),
		FadingSlider(
			value: 42,
			min: 0,
			max: 100,
			onChanged: (double value) {},
		),
		const SizedBox(height: 16),
		const FadingProgressIndicator(
			value: 0.6,
			label: 'Telemetry',
		),
	],
)
```

## Public API

The package exports the following widgets from [fading_ui.dart](fading_ui/lib/fading_ui.dart): `FadingButton`, `FadingCard`, `FadingSurface`, `FadingToast`, `FadingTextField`, `FadingCheckbox`, `FadingSwitch`, `FadingSlider`, `FadingProgressIndicator`, `FadingRadioGroup`, and `FadingTabBar`.
