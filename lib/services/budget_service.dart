import "dart:async";
import 'dart:developer' as dev;
import 'package:chopper/chopper.dart';
import 'package:flutter/material.dart';
import '../models/record.dart';
import 'header_interceptor.dart';

part 'budget_service.chopper.dart';

@ChopperApi(baseUrl: "/api/v1")
abstract class BudgetService extends ChopperService {
  @Get(path: "/accounts/{id}/records?latest")
  Future<Response> getRecords(@Path("id") int accountId);

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
      if (response.body == null) {
        return Future.error("Empty response");
      }

      if (!response.isSuccessful) {
        // Try to parse error response
        return Future.error("Request failed.");
      }

      try {
        return Future.value(f(response.body));
      } catch (e) {
        debugPrint(e.toString());
        return Future.error(e.toString());
      }
    });
  }
}
