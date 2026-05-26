# fading_ui

Neumorphic Flutter components with a sad sunset palette and retrofuturistic tone.

## Features

- Theme preset for a dark sunset mood.
- Reusable raised and inset neumorphic surfaces.
- V1 components: button, card, container surface, and text field.
- Flutter-only implementation with no external neumorphism package.

## Getting started

Add the package to your app and apply the theme:

```dart
import 'package:flutter/widgets.dart';
import 'package:fading_ui/fading_ui.dart';

WidgetsApp(
	color: FadingColors.midnight,
	pageRouteBuilder: <T>(RouteSettings settings, WidgetBuilder builder) {
		return PageRouteBuilder<T>(
			settings: settings,
			pageBuilder: (BuildContext context, _, _) => builder(context),
		);
	},
	home: const MyScreen(),
)
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
