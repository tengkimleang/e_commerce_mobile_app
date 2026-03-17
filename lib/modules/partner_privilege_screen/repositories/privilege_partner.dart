import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:e_commerce_mobile_app/core/common/error.dart';
import 'package:e_commerce_mobile_app/core/common/repository.dart';
import 'package:e_commerce_mobile_app/modules/partner_privilege_screen/models/slide.dart';
import 'package:e_commerce_mobile_app/modules/partner_privilege_screen/models/wholesale_request.dart';

class PrivilegePartnerRepository extends Repository {
  Future<Either<HttpError, List<SliderModel>>> getSlider() async {
    try {
      final response = await client.get<List>('/getSlider');

      final sliders = (response.data ?? [])
          .map((json) => SliderModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return Right(sliders);
    } on DioException catch (e) {
      return Left(getErrorMessage(e));
    }
  }

  Future<Either<HttpError, List<WholesaleRequest>>> getRequests({
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await client.get<List>(
        '/partnership/getAll',
        queryParameters: {'page': page, 'pageSize': pageSize},
      );

      final requests = (response.data ?? [])
          .map((json) =>
              WholesaleRequest.fromJson(json as Map<String, dynamic>))
          .toList();

      return Right(requests);
    } on DioException catch (e) {
      return Left(getErrorMessage(e));
    }
  }
}
