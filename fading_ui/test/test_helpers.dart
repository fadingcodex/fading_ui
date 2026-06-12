import 'package:fading_ui/fading_ui.dart';
import 'package:flutter/widgets.dart';

Widget buildApp(Widget child) {
  return WidgetsApp(
    color: FadingColors.midnight,
    debugShowCheckedModeBanner: false,
    pageRouteBuilder: <T>(RouteSettings settings, WidgetBuilder builder) {
      return PageRouteBuilder<T>(
        settings: settings,
        pageBuilder: (BuildContext context, _, _) => builder(context),
      );
    },
    home: Directionality(textDirection: TextDirection.ltr, child: child),
  );
}
