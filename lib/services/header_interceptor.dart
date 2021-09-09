import 'dart:async';
import 'package:chopper/chopper.dart';

class HeaderInterceptor implements RequestInterceptor {
  @override
  FutureOr<Request> onRequest(Request request) async {
    Request newRequest = request.copyWith(headers: {"Authorization": "4"});
    return newRequest;
  }
}
