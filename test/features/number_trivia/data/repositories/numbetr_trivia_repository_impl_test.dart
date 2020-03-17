import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:number_trivia/core/error/exceptions.dart';
import 'package:number_trivia/core/error/failures.dart';
import 'package:number_trivia/core/network/network_info.dart';
import 'package:number_trivia/features/number_trivia/data/datasources/numbe_trivia_remote_datasource.dart';
import 'package:number_trivia/features/number_trivia/data/datasources/number_trivia_local_datasource.dart';
import 'package:number_trivia/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:number_trivia/features/number_trivia/data/repositories/number_trivia_repository_imp.dart';
import 'package:number_trivia/features/number_trivia/domain/entities/number_trivia.dart';

class MockRemoteDatasource extends Mock
    implements NumberTriviaRemoteDatasource {}

class MockLocalDatasource extends Mock implements NumberTriviaLocalDatasource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  NumberTriviaRepositoryImpl repository;
  MockRemoteDatasource mockRemoteDatasource;
  MockLocalDatasource mockLocalDatasource;
  MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDatasource = MockRemoteDatasource();
    mockLocalDatasource = MockLocalDatasource();
    mockNetworkInfo = MockNetworkInfo();
    repository = NumberTriviaRepositoryImpl(
        remoteDatasource: mockRemoteDatasource,
        localDatasource: mockLocalDatasource,
        networkInfo: mockNetworkInfo);
  });

  void runTestsOnline(Function body) {
    group('device is online', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      body();
    });
  }

  void runTestsOffline(Function body) {
    group('device is offline', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      body();
    });
  }

  group('getConcreteNumberTrivia', () {
    final tNumber = 1;
    final tNumberTriviaModel =
        NumberTriviaModel(number: 1, text: 'Test trivia');
    final NumberTrivia tNumberTrivia = tNumberTriviaModel;

    test('should check if device is online', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      // act
      repository.getConcreteNumberTrivia(tNumber);
      // assert
      verify(mockNetworkInfo.isConnected);
    });

    runTestsOnline(() {
      test(
        'should return remote data when the call to remote datasource is successful',
        () async {
          // arrange
          when(mockRemoteDatasource.getConcreteNumberTrivia(any))
              .thenAnswer((_) async => tNumberTriviaModel);
          // act
          final result = await repository.getConcreteNumberTrivia(tNumber);
          // assert
          verify(mockRemoteDatasource.getConcreteNumberTrivia(tNumber));
          expect(result, equals(Right(tNumberTrivia)));
        },
      );

      test(
        'should return cache data when the call to remote datasource is successful',
        () async {
          // arrange
          when(mockRemoteDatasource.getConcreteNumberTrivia(any))
              .thenAnswer((_) async => tNumberTriviaModel);
          // act
          await repository.getConcreteNumberTrivia(tNumber);
          // assert
          verify(mockRemoteDatasource.getConcreteNumberTrivia(tNumber));
          verify(mockLocalDatasource.cacheNumberTrivia(tNumberTriviaModel));
        },
      );

      test(
        'should return rserver failure when the call to remote datasource is unsuccessful',
        () async {
          // arrange
          when(mockRemoteDatasource.getConcreteNumberTrivia(any))
              .thenThrow(ServerException());
          // act
          final result = await repository.getConcreteNumberTrivia(tNumber);
          // assert
          verify(mockRemoteDatasource.getConcreteNumberTrivia(tNumber));
          verifyZeroInteractions(mockLocalDatasource);
          expect(result, equals(Left(ServerFailure())));
        },
      );
    });

    runTestsOffline(() {
      test(
        'should return last locally cached data when the cached data is present',
        () async {
          // arrange
          when(mockLocalDatasource.getLastNumberTrivia())
              .thenAnswer((_) async => tNumberTriviaModel);
          // act
          final result = await repository.getConcreteNumberTrivia(tNumber);
          // assert
          verifyZeroInteractions(mockRemoteDatasource);
          verify(mockLocalDatasource.getLastNumberTrivia());
          expect(result, equals(Right(tNumberTrivia)));
        },
      );

      test(
        'should return CacheFailure when there is no cached data present',
        () async {
          // arrange
          when(mockLocalDatasource.getLastNumberTrivia())
              .thenThrow(CacheException());
          // act
          final result = await repository.getConcreteNumberTrivia(tNumber);
          // assert
          verifyZeroInteractions(mockRemoteDatasource);
          verify(mockLocalDatasource.getLastNumberTrivia());
          expect(result, equals(Left(CacheFailure())));
        },
      );
    });
  });

  group('getRandomNumberTrivia', () {
    final tNumberTriviaModel =
        NumberTriviaModel(number: 123, text: 'Test trivia');
    final NumberTrivia tNumberTrivia = tNumberTriviaModel;

    test('should check if device is online', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      // act
      repository.getRandomNumberTrivia();
      // assert
      verify(mockNetworkInfo.isConnected);
    });

    runTestsOnline(() {
      test(
        'should return remote data when the call to remote datasource is successful',
        () async {
          // arrange
          when(mockRemoteDatasource.getRandomNumberTrivia())
              .thenAnswer((_) async => tNumberTriviaModel);
          // act
          final result = await repository.getRandomNumberTrivia();
          // assert
          verify(mockRemoteDatasource.getRandomNumberTrivia());
          expect(result, equals(Right(tNumberTrivia)));
        },
      );

      test(
        'should return cache data when the call to remote datasource is successful',
        () async {
          // arrange
          when(mockRemoteDatasource.getRandomNumberTrivia())
              .thenAnswer((_) async => tNumberTriviaModel);
          // act
          await repository.getRandomNumberTrivia();
          // assert
          verify(mockRemoteDatasource.getRandomNumberTrivia());
          verify(mockLocalDatasource.cacheNumberTrivia(tNumberTriviaModel));
        },
      );

      test(
        'should return rserver failure when the call to remote datasource is unsuccessful',
        () async {
          // arrange
          when(mockRemoteDatasource.getRandomNumberTrivia())
              .thenThrow(ServerException());
          // act
          final result = await repository.getRandomNumberTrivia();
          // assert
          verify(mockRemoteDatasource.getRandomNumberTrivia());
          verifyZeroInteractions(mockLocalDatasource);
          expect(result, equals(Left(ServerFailure())));
        },
      );
    });

    runTestsOffline(() {
      test(
        'should return last locally cached data when the cached data is present',
        () async {
          // arrange
          when(mockLocalDatasource.getLastNumberTrivia())
              .thenAnswer((_) async => tNumberTriviaModel);
          // act
          final result = await repository.getRandomNumberTrivia();
          // assert
          verifyZeroInteractions(mockRemoteDatasource);
          verify(mockLocalDatasource.getLastNumberTrivia());
          expect(result, equals(Right(tNumberTrivia)));
        },
      );

      test(
        'should return CacheFailure when there is no cached data present',
        () async {
          // arrange
          when(mockLocalDatasource.getLastNumberTrivia())
              .thenThrow(CacheException());
          // act
          final result = await repository.getRandomNumberTrivia();
          // assert
          verifyZeroInteractions(mockRemoteDatasource);
          verify(mockLocalDatasource.getLastNumberTrivia());
          expect(result, equals(Left(CacheFailure())));
        },
      );
    });
  });
}
