import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:get_it/get_it.dart';
import 'package:number_trivia/core/network/network_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/util/input_converter.dart';
import 'features/number_trivia/data/datasources/numbe_trivia_remote_datasource.dart';
import 'features/number_trivia/data/datasources/number_trivia_local_datasource.dart';
import 'features/number_trivia/data/repositories/number_trivia_repository_imp.dart';
import 'features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'features/number_trivia/presentation/bloc/bloc.dart';

import 'package:http/http.dart' as http;

final serviceLocator = GetIt.instance;

Future<void> init() async {
  //! Features - Number Trivia
  // Bloc
  serviceLocator.registerFactory(() => NumberTriviaBloc(
        concrete: serviceLocator(),
        random: serviceLocator(),
        inputConverter: serviceLocator(),
      ));

  // Use cases
  serviceLocator
      .registerLazySingleton(() => GetConcreteNumberTrivia(serviceLocator()));
  serviceLocator
      .registerLazySingleton(() => GetRandomNumberTrivia(serviceLocator()));

  // Repository
  serviceLocator.registerLazySingleton<NumberTriviaRepository>(() =>
    NumberTriviaRepositoryImpl(
      remoteDatasource: serviceLocator(), 
      localDatasource: serviceLocator(), 
      networkInfo: serviceLocator()
    )
  );

  // Datasources
  serviceLocator.registerLazySingleton<NumberTriviaLocalDatasource>(() => 
    NumberTriviaLocalDatasourceImpl(sharedPreferences: serviceLocator())
  );

  serviceLocator.registerLazySingleton<NumberTriviaRemoteDatasource>(() => 
    NumberTriviaRemoteDatasourceImpl(client: serviceLocator())
  );
  //! Core
  serviceLocator.registerLazySingleton(() => InputConverter());
  serviceLocator.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(serviceLocator()));
  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  serviceLocator.registerLazySingleton(() => sharedPreferences);
  serviceLocator.registerLazySingleton(() => http.Client());
  serviceLocator.registerLazySingleton(() => DataConnectionChecker());
}
