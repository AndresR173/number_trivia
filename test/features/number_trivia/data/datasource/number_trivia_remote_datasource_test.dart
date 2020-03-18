import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:number_trivia/core/error/exceptions.dart';
import 'package:number_trivia/features/number_trivia/data/datasources/numbe_trivia_remote_datasource.dart';
import 'package:number_trivia/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:matcher/matcher.dart';
import 'package:http/http.dart' as http;

import '../../../../fixtures/fixture_reader.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  NumberTriviaRemoteDatasourceImpl datasource;
  MockHttpClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockHttpClient();
    datasource = NumberTriviaRemoteDatasourceImpl(client: mockHttpClient);
  });

  void setupMockHttpClient200() {
    when(mockHttpClient.get(any, headers: anyNamed('headers'))).thenAnswer(
            (_) async => http.Response(fixture('trivia.json'), 200));
  }

  void setupMockHttpClient404() {
    when(mockHttpClient.get(any, headers: anyNamed('headers'))).thenAnswer(
            (_) async => http.Response('Something went wrong', 404));
  }

  group('getConcreteNumberTrivia', () {
    final tNumber = 1;
    final tNumberTriviaModel = NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));
    test(
      '''should perform a GET request on an URL with number beign the 
      endpoint and with application/json header''',
      () async {
        // arrange
        setupMockHttpClient200();
        // act
        datasource.getConcreteNumberTrivia(tNumber);
        // assert
        verify(mockHttpClient.get('http://numbersapi.com/$tNumber',
            headers: {'Content-Type': 'application/json'}));
      },
    );

    test(
      'should return NumbetrTrivia when the response is 200',
      () async {
        // arrange
        setupMockHttpClient200();
        // act
        final result = await datasource.getConcreteNumberTrivia(tNumber);
        // assert
        expect(result, equals(tNumberTriviaModel));
      },
    );

    test(
      'should throw a ServerException when the response is an Error code',
      () async {
        // arrange
        setupMockHttpClient404();
        // act
        final call = datasource.getConcreteNumberTrivia;
        // assert
        expect(() => call(tNumber), throwsA(TypeMatcher<ServerException>()));
      },
    );
  });

  group('getRandomNumberTrivia', () {
    final tNumberTriviaModel = NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));
    test(
      '''should perform a GET request on an URL with number beign the 
      endpoint and with application/json header''',
      () async {
        // arrange
        setupMockHttpClient200();
        // act
        datasource.getRandomNumberTrivia();
        // assert
        verify(mockHttpClient.get('http://numbersapi.com/random',
            headers: {'Content-Type': 'application/json'}));
      },
    );

    test(
      'should return NumbetrTrivia when the response is 200',
      () async {
        // arrange
        setupMockHttpClient200();
        // act
        final result = await datasource.getRandomNumberTrivia();
        // assert
        expect(result, equals(tNumberTriviaModel));
      },
    );

    test(
      'should throw a ServerException when the response is an Error code',
      () async {
        // arrange
        setupMockHttpClient404();
        // act
        final call = datasource.getRandomNumberTrivia;
        // assert
        expect(() => call(), throwsA(TypeMatcher<ServerException>()));
      },
    );
  });
}
