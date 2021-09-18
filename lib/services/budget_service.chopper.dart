// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// ignore_for_file: always_put_control_body_on_new_line, always_specify_types, prefer_const_declarations
class _$BudgetService extends BudgetService {
  _$BudgetService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final definitionType = BudgetService;

  @override
  Future<Response<dynamic>> getRecords(int accountId) {
    final $url = '/api/v1/accounts/$accountId/records?latest';
    final $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> createRecord(
      int accountId, CreateRecord createRecord) {
    final $url = '/api/v1/accounts/$accountId/records';
    final $body = createRecord;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getAccounts() {
    final $url = '/api/v1/accounts';
    final $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getCategories() {
    final $url = '/api/v1/categories';
    final $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }
}
