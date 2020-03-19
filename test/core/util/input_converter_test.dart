import 'dart:math';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:number_trivia/core/util/input_converter.dart';

void main() {
  InputConverter inputConverter;

  setUp(() {
    inputConverter = InputConverter();
  });

  group('stringToUnsignedInt', () {
    test(
      'should return an integer when the string represents an unsigned integer',
      () async {
        // arrange
        final str = '123';
        // act
        final resutl = inputConverter.stringToUnsignedInteger(str);
        // assert
        expect(resutl, Right(123));
      },
    );

    test(
      'should return failure when the string is not an integer',
      () async {
        // arrange
        final str = 'asd';
        // act
        final resutl = inputConverter.stringToUnsignedInteger(str);
        // assert
        expect(resutl, Left(InvalidInputFailure()));
      },
    );

    test(
      'should return failure when the string is a negative integer',
      () async {
        // arrange
        final str = '-123';
        // act
        final resutl = inputConverter.stringToUnsignedInteger(str);
        // assert
        expect(resutl, Left(InvalidInputFailure()));
      },
    );
  });
}
