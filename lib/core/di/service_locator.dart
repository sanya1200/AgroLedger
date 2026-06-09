import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:agroledger/core/services/biometric_service.dart';
import 'package:agroledger/core/network/dio_client.dart';
import 'package:agroledger/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:agroledger/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:agroledger/features/calculator/data/datasources/calculator_remote_data_source.dart';
import 'package:agroledger/features/calculator/presentation/bloc/calculator_bloc.dart';
import 'package:agroledger/features/marketplace/data/datasources/marketplace_remote_data_source.dart';
import 'package:agroledger/features/marketplace/presentation/bloc/marketplace_bloc.dart';

final sl = GetIt.instance;

Future<void> initServiceLocator() async {
  // External
  const secureStorage = FlutterSecureStorage();
  sl.registerSingleton<FlutterSecureStorage>(secureStorage);

  // Core
  sl.registerSingleton<BiometricService>(BiometricService());
  sl.registerSingleton<DioClient>(DioClient(Dio(), sl<FlutterSecureStorage>()));

  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      sl<DioClient>(),
      sl<FlutterSecureStorage>(),
    ),
  );
  sl.registerLazySingleton<CalculatorRemoteDataSource>(
    () => CalculatorRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<MarketplaceRemoteDataSource>(
    () => MarketplaceRemoteDataSourceImpl(sl<DioClient>()),
  );

  // BLoCs
  sl.registerFactory(
    () => AuthBloc(
      authRemoteDataSource: sl<AuthRemoteDataSource>(),
      storage: sl<FlutterSecureStorage>(),
    ),
  );
  sl.registerFactory(
    () => CalculatorBloc(sl<CalculatorRemoteDataSource>()),
  );
  sl.registerFactory(
    () => MarketplaceBloc(sl<MarketplaceRemoteDataSource>()),
  );
}
