import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_testing_tutorial/article.dart';
import 'package:flutter_testing_tutorial/news_change_notifier.dart';
import 'package:flutter_testing_tutorial/news_page.dart';
import 'package:flutter_testing_tutorial/news_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockNewsService extends Mock implements NewsService {}

main() {
  late MockNewsService mockNewsService;

  setUp(() {
    mockNewsService = MockNewsService();
  });
  final getArticlesFromService = [
    Article(content: 'Test 1 content', title: 'Test Title 1'),
    Article(content: 'Test 2 content', title: 'Test Title 2'),
    Article(content: 'Test 3 content', title: 'Test Title 3'),
  ];

  void arrangeNewsServiceReturn3Articles() {
    when(() => mockNewsService.getArticles()).thenAnswer((_) async => getArticlesFromService);
  }

  void arrangeNewsServiceReturn3ArticlesAfter2SecondDelay() {
    when(() => mockNewsService.getArticles()).thenAnswer((_) async {
      await Future.delayed(const Duration(seconds: 2));
      return getArticlesFromService;
    });
  }

  Widget createWidgetUnderTest() {
    return MaterialApp(
      title: 'News App',
      home: ChangeNotifierProvider(
        create: (_) => NewsChangeNotifier(mockNewsService),
        child: NewsPage(),
      ),
    );
  }

  testWidgets('title is displayed', (WidgetTester tester) async {
    arrangeNewsServiceReturn3Articles();
    await tester.pumpWidget(createWidgetUnderTest());
    expect(find.text("News"), findsOneWidget);
  });

  testWidgets("loading is displayed when awaiting articles", (WidgetTester tester) async {
    arrangeNewsServiceReturn3ArticlesAfter2SecondDelay();
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byKey(const Key("progress-indicator")), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('articles are displayed', (WidgetTester tester) async {
    arrangeNewsServiceReturn3Articles();
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();
    for (final article in getArticlesFromService) {
      expect(find.text(article.title), findsOneWidget);
      expect(find.text(article.content), findsOneWidget);
    }
  });
}
