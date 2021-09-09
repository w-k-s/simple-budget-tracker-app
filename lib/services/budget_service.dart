import "dart:async";
import 'package:chopper/chopper.dart';
import '../models/record.dart';
import 'header_interceptor.dart';

part 'budget_service.chopper.dart';

@ChopperApi(baseUrl: "/api/v1")
abstract class BudgetService extends ChopperService {
  @Get(path: "/accounts/{id}/records?latest")
  Future<Response> getRecords(@Path("id") int accountId);

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
