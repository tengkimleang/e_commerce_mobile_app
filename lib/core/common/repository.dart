import 'dart:io';

import 'package:dio/dio.dart';
import 'package:e_commerce_mobile_app/core/common/di.dart';
import 'package:e_commerce_mobile_app/core/common/error.dart';

abstract class Repository {
  final Dio client;
  Repository() : client = di<Dio>();

  HttpError getErrorMessage(DioException de) {
    switch (de.type) {
      case DioExceptionType.connectionTimeout:
        return HttpError(message: 'បរាជ័យក្នុងការភ្ជាប់ទៅម៉ាស៊ីនមេ');
      case DioExceptionType.sendTimeout:
        return HttpError(message: 'បានបរាជ័យក្នុងការផ្ញើទៅម៉ាស៊ីនមេ');
      case DioExceptionType.receiveTimeout:
        return HttpError(message: 'បរាជ័យក្នុងការទទួលពីម៉ាស៊ីនមេ');
      case DioExceptionType.badResponse:
        if (de.response?.statusCode == 500) {
          return HttpError(message: 'កំហុសម៉ាស៊ីនមេ');
        } else if (de.response?.statusCode == 404) {
          if (de.response?.data == null) {
            return HttpError(message: 'រកមិនឃើញទិន្នន័យ');
          } else {
            return HttpError(response: de.response);
          }
        }
        return HttpError(response: de.response);
      case DioExceptionType.cancel:
        return HttpError(message: 'ការតភ្ជាប់ទៅម៉ាស៊ីនមេត្រូវបានលុបចោល');
      case DioExceptionType.unknown:
        if (de.error is SocketException) {
          return HttpError(message: 'គ្មានការតភ្ជាប់អ៊ីនធឺណិត');
        } else {
          return HttpError(message: 'កំហុសបានកើតឡើង');
        }
      case DioExceptionType.badCertificate:
      case DioExceptionType.connectionError:
        return HttpError(message: 'កំហុសបានកើតឡើង');
    }
  }
}
