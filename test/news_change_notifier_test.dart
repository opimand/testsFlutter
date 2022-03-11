import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_testing_tutorial/article.dart';
import 'package:flutter_testing_tutorial/news_change_notifier.dart';
import 'package:flutter_testing_tutorial/news_service.dart';
import 'package:mocktail/mocktail.dart';

class MockNewsService extends Mock implements NewsService {}

void main() {
  late NewsChangeNotifier sut;
  late MockNewsService mockNewsService;

  setUp(() {
    mockNewsService = MockNewsService();
    sut = NewsChangeNotifier(mockNewsService);
  });

  test("initial value are correct", () {
    expect(sut.articles, []);
    expect(sut.isLoading, false);
  });

  group("get_articles", () {
    final getArticlesFromService = [
      Article(content: 'Test 1 content', title: 'Test Title 1'),
      Article(content: 'Test 2 content', title: 'Test Title 2'),
      Article(content: 'Test 3 content', title: 'Test Title 3'),
    ];

    void arrangeNewsServiceReturn3Articles() {
      when(() => mockNewsService.getArticles()).thenAnswer((_) async => getArticlesFromService);
    }

    test('get articles uses the NewsService', () async {
      arrangeNewsServiceReturn3Articles();
      await sut.getArticles();
      verify(() => mockNewsService.getArticles()).called(1);
      //arrange
      // act
      // assert
    });

    test("""indicates loading of data, 
    sets the articles to the ones from the service,
     indicates that data is not being loaded anymore
     """, () async {
      //arrange
      arrangeNewsServiceReturn3Articles();
      // act
      final future = sut.getArticles();
      // assert
      expect(sut.isLoading, true);
      await future;
      expect(sut.articles, getArticlesFromService);
      expect(sut.isLoading, false);
    });
  });
}
