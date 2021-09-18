import "dart:async";
import 'dart:developer' as dev;
import 'package:chopper/chopper.dart';
import 'package:flutter/material.dart';
import '../models/record.dart';
import '../models/api_error.dart';
import 'header_interceptor.dart';

part 'budget_service.chopper.dart';

@ChopperApi(baseUrl: "/api/v1")
abstract class BudgetService extends ChopperService {
  @Get(path: "/accounts/{id}/records?latest")
  Future<Response> getRecords(@Path("id") int accountId);

  @Post(path: "/accounts/{id}/records")
  Future<Response> createRecord(
      @Path("id") int accountId, @Body() CreateRecord createRecord);

  @Get(path: "/accounts")
  Future<Response> getAccounts();

  @Get(path: "/categories")
  Future<Response> getCategories();

  static BudgetService create() {
    final client = ChopperClient(
      baseUrl: 'https://budget.w-k-s.io',
      interceptors: [HeaderInterceptor(), HttpLoggingInterceptor()],
      converter: JsonConverter(),
      errorConverter: JsonConverter(),
      services: [
        _$BudgetService(),
      ],
    );
    return _$BudgetService(client);
  }
}

extension Networking on Future<Response> {
  Future<T> onSuccess<T>(T Function(dynamic) f) {
    return this.then((response) {
      if (!response.isSuccessful) {
        final errorBody = response.error;
        var networkingException = NetworkingException(
            NetworkingExceptionType.InternalServerError,
            message: response.error.toString());

        if (errorBody is Map<String, dynamic>) {
          try {
            final problem = Problem.fromJson(errorBody);
            networkingException = problem.toNetworkingException();
          } catch (e) {}
        }

        return Future.error(networkingException);
      }

      if (response.body == null) {
        return Future.error(NetworkingException(
            NetworkingExceptionType.EmptyResponse,
            message: "Empty response"));
      }

      try {
        return Future.value(f(response.body));
      } catch (e) {
        return Future.error(NetworkingException(
            NetworkingExceptionType.Deserialization,
            message: e.toString()));
      }
    });
  }
}

extension ToNetworkingException on Problem {
  NetworkingException toNetworkingException() {
    final type = networkingExceptionType();
    final message = this.detail;
    return NetworkingException(type, message: message);
  }

  NetworkingExceptionType networkingExceptionType() {
    switch (this.status) {
      case 404:
        return NetworkingExceptionType.NotFound;
      case 401:
        return NetworkingExceptionType.Authentication;
      case 403:
        return NetworkingExceptionType.Authorization;
      case 400:
        return NetworkingExceptionType.Validation;
      default:
        return NetworkingExceptionType.InternalServerError;
    }
  }
}

enum NetworkingExceptionType {
  InternalServerError,
  NotFound,
  EmptyResponse,
  Validation,
  Authentication,
  Authorization,
  Deserialization
}

class NetworkingException implements Exception {
  NetworkingExceptionType type;
  String message;
  NetworkingException(this.type, {required this.message}) {}

  @override
  String toString() => this.message;
}
