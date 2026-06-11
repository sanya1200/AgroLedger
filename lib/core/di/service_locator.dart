import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:agroledger/core/services/biometric_service.dart';
import 'package:agroledger/core/services/auth_session_service.dart';
import 'package:agroledger/core/network/dio_client.dart';
import 'package:agroledger/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:agroledger/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:agroledger/features/calculator/data/datasources/calculator_remote_data_source.dart';
import 'package:agroledger/features/calculator/data/repositories/calculator_repository.dart';
import 'package:agroledger/features/calculator/domain/services/report_export_service.dart';
import 'package:agroledger/features/calculator/presentation/bloc/calculator_bloc.dart';
import 'package:agroledger/features/marketplace/data/datasources/marketplace_remote_data_source.dart';
import 'package:agroledger/features/marketplace/presentation/bloc/marketplace_bloc.dart';
import 'package:agroledger/features/home/data/datasources/business_profile_remote_data_source.dart';
import 'package:agroledger/features/home/data/datasources/ai_remote_data_source.dart';
import 'package:agroledger/features/calculator/presentation/bloc/calendar_bloc.dart';

final sl = GetIt.instance;

Future<void> initServiceLocator() async {
  const secureStorage = FlutterSecureStorage();
  sl.registerSingleton<FlutterSecureStorage>(secureStorage);

  sl.registerSingleton<AuthSessionService>(AuthSessionService());
  sl.registerSingleton<BiometricService>(BiometricService());
  sl.registerSingleton<DioClient>(
    DioClient(
      Dio(),
      sl<FlutterSecureStorage>(),
      sl<AuthSessionService>(),
    ),
  );

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      sl<DioClient>(),
      sl<FlutterSecureStorage>(),
    ),
  );
  sl.registerLazySingleton<CalculatorRemoteDataSource>(
    () => CalculatorRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<CalculatorRepository>(
    () => CalculatorRepository(sl<CalculatorRemoteDataSource>()),
  );
  sl.registerLazySingleton<ReportExportService>(ReportExportService.new);
  sl.registerLazySingleton<MarketplaceRemoteDataSource>(
    () => MarketplaceRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<BusinessProfileRemoteDataSource>(
    () => BusinessProfileRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<AiRemoteDataSource>(
    () => AiRemoteDataSourceImpl(sl<DioClient>()),
  );

  sl.registerLazySingleton(
    () => AuthBloc(
      authRemoteDataSource: sl<AuthRemoteDataSource>(),
      storage: sl<FlutterSecureStorage>(),
    ),
  );
  sl.registerFactory(
    () => CalculatorBloc(sl<CalculatorRepository>()),
  );
  sl.registerFactory(
    () => MarketplaceBloc(sl<MarketplaceRemoteDataSource>()),
  );
  sl.registerFactory(
    () => CalendarBloc(sl<CalculatorRepository>()),
  );
}
