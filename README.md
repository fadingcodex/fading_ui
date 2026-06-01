# fading_ui

Neumorphic Flutter components with Diaspora and Imperium theme groups in a retrofuturistic tone.

## Features

- Runtime grouped theme support through `FadingThemeScope`.
- Reusable raised and inset neumorphic surfaces.
- Material and Cupertino free.
- Core components: button, card, surface, toast, and text field.
- Selection and control components: checkbox, switch, slider, radio group, and tab bar.
- Progress components: linear and circular progress indicators.
- Flutter-only implementation with no external neumorphism package.

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
			home: const MyScreen(),
		),
	);
}
```

Switch themes at runtime:

```dart
class MyApp extends StatefulWidget {
	const MyApp({super.key});

	@override
	State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
	FadingThemeName _theme = FadingThemeName.abyss;

	@override
	Widget build(BuildContext context) {
		final FadingThemeData theme = FadingThemeData.fromTheme(_theme);

		return FadingThemeScope(
			theme: _theme,
			data: theme,
			child: WidgetsApp(
				color: theme.backgroundStart,
				debugShowCheckedModeBanner: false,
				home: MyScreen(
					onToggleTheme: () {
						setState(() {
							_theme = _theme == FadingThemeName.abyss
								? FadingThemeName.dawn
								: FadingThemeName.abyss;
						});
					},
				),
			),
		);
	}
}
```

## Usage

```dart
Column(
	children: <Widget>[
		FadingButton(
			label: 'Engage Drive',
			onPressed: () {},
		),
		const SizedBox(height: 16),
		const FadingCard(
			title: 'Noble House Signal',
			child: Text('Orbital route synchronized.'),
		),
		const SizedBox(height: 16),
		const FadingTextField(
			label: 'Transmission',
			hint: 'Type your command',
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

## Theme

`FadingThemeData` provides four built-in palettes grouped into Diaspora (`Dawn`, `Abyss`) and Imperium (`Hope`, `Dream`) plus semantic tokens for text, surfaces, controls, and progress states. Use `FadingThemeData.fromTheme(...)` to switch between the built-in themes, or construct your own theme data if you want a custom palette.

## Public API

The package exports the following widgets from [fading_ui.dart](fading_ui/lib/fading_ui.dart): `FadingButton`, `FadingCard`, `FadingSurface`, `FadingToast`, `FadingTextField`, `FadingCheckbox`, `FadingSwitch`, `FadingSlider`, `FadingProgressIndicator`, `FadingRadioGroup`, and `FadingTabBar`.
