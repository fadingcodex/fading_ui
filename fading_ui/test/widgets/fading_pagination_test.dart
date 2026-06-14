import 'package:fading_ui/fading_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

void main() {
  testWidgets('pagination emits tapped page', (WidgetTester tester) async {
    int? emitted;

    await tester.pumpWidget(
      buildApp(
        FadingPagination(
          currentPage: 3,
          totalPages: 8,
          onPageChanged: (int page) {
            emitted = page;
          },
        ),
      ),
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('fading-pagination-page-4')),
    );
    await tester.pumpAndSettle();

    expect(emitted, 4);
  });

  testWidgets('pagination next and previous emit expected pages', (
    WidgetTester tester,
  ) async {
    int currentPage = 2;

    await tester.pumpWidget(
      buildApp(
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return FadingPagination(
              currentPage: currentPage,
              totalPages: 8,
              onPageChanged: (int page) {
                setState(() {
                  currentPage = page;
                });
              },
            );
          },
        ),
      ),
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('fading-pagination-next')),
    );
    await tester.pumpAndSettle();
    expect(currentPage, 3);

    await tester.tap(
      find.byKey(const ValueKey<String>('fading-pagination-prev')),
    );
    await tester.pumpAndSettle();
    expect(currentPage, 2);

    await tester.tap(
      find.byKey(const ValueKey<String>('fading-pagination-last')),
    );
    await tester.pumpAndSettle();
    expect(currentPage, 8);

    await tester.tap(
      find.byKey(const ValueKey<String>('fading-pagination-first')),
    );
    await tester.pumpAndSettle();
    expect(currentPage, 1);
  });

  testWidgets('pagination respects boundaries', (WidgetTester tester) async {
    int? emitted;

    await tester.pumpWidget(
      buildApp(
        FadingPagination(
          currentPage: 1,
          totalPages: 5,
          onPageChanged: (int page) {
            emitted = page;
          },
        ),
      ),
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('fading-pagination-prev')),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey<String>('fading-pagination-first')),
    );
    await tester.pumpAndSettle();

    expect(emitted, isNull);

    await tester.pumpWidget(
      buildApp(
        FadingPagination(
          currentPage: 5,
          totalPages: 5,
          onPageChanged: (int page) {
            emitted = page;
          },
        ),
      ),
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('fading-pagination-next')),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey<String>('fading-pagination-last')),
    );
    await tester.pumpAndSettle();

    expect(emitted, isNull);
  });

  testWidgets('disabled pagination ignores interactions', (
    WidgetTester tester,
  ) async {
    int? emitted;

    await tester.pumpWidget(
      buildApp(
        FadingPagination(
          currentPage: 2,
          totalPages: 8,
          enabled: false,
          onPageChanged: (int page) {
            emitted = page;
          },
        ),
      ),
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('fading-pagination-next')),
    );
    await tester.pumpAndSettle();

    expect(emitted, isNull);
  });

  testWidgets('single page does not emit changes', (WidgetTester tester) async {
    int? emitted;

    await tester.pumpWidget(
      buildApp(
        FadingPagination(
          currentPage: 1,
          totalPages: 1,
          onPageChanged: (int page) {
            emitted = page;
          },
        ),
      ),
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('fading-pagination-page-1')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey<String>('fading-pagination-next')),
    );
    await tester.pumpAndSettle();

    expect(emitted, isNull);
  });

  testWidgets('large page counts render ellipsis window', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildApp(
        FadingPagination(
          currentPage: 10,
          totalPages: 20,
          onPageChanged: (_) {},
        ),
      ),
    );

    expect(find.text('...'), findsNWidgets(2));
    expect(
      find.byKey(const ValueKey<String>('fading-pagination-page-1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('fading-pagination-page-9')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('fading-pagination-page-10')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('fading-pagination-page-11')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('fading-pagination-page-20')),
      findsOneWidget,
    );
  });
}
