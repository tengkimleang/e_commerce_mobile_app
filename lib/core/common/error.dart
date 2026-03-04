import 'package:dio/dio.dart';

class HttpError {
  final Response? response;
  final String? message;

  HttpError({this.response, this.message});
}
