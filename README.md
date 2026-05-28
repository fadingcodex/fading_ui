# fading_ui

Neumorphic Flutter components with a sad sunset palette and retrofuturistic tone.

## Features

- Runtime day/night theme mode support.
- Reusable raised and inset neumorphic surfaces.
- V1 components: button, card, container surface, and text field.
- Flutter-only implementation with no external neumorphism package.

## Getting started

Add the package to your app and apply the theme:

```dart
import 'package:flutter/widgets.dart';
import 'package:fading_ui/fading_ui.dart';

WidgetsApp(
	color: FadingThemeData.night.backgroundStart,
	pageRouteBuilder: <T>(RouteSettings settings, WidgetBuilder builder) {
		return PageRouteBuilder<T>(
			settings: settings,
			pageBuilder: (BuildContext context, _, _) => builder(context),
		);
	},
	home: const FadingThemeScope(
		mode: FadingThemeMode.night,
		data: FadingThemeData.night,
		child: MyScreen(),
	),
)
```

Switch theme mode at runtime:

```dart
class MyApp extends StatefulWidget {
	const MyApp({super.key});

	@override
	State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
	FadingThemeMode _mode = FadingThemeMode.night;

	@override
	Widget build(BuildContext context) {
		final FadingThemeData theme = FadingThemeData.fromMode(_mode);

		return FadingThemeScope(
			mode: _mode,
			data: theme,
			child: WidgetsApp(
				color: theme.backgroundStart,
				home: MyScreen(
					onToggleTheme: () {
						setState(() {
							_mode = _mode == FadingThemeMode.night
								? FadingThemeMode.day
								: FadingThemeMode.night;
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
	],
)
```

## Status

This is the initial visual foundation. A separate demo app in this workspace showcases the components in context.
