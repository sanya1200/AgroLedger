import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:agroledger/features/calculator/presentation/bloc/calculator_bloc.dart';
import 'package:agroledger/features/calculator/data/repositories/calculator_repository.dart';
import 'package:agroledger/features/calculator/data/models/calculator_summary_model.dart';
import 'package:agroledger/features/calculator/data/models/livestock_asset_model.dart';

class MockCalculatorRepository extends Mock implements CalculatorRepository {}

void main() {
  late MockCalculatorRepository mockRepository;
  late CalculatorBloc calculatorBloc;

  setUp(() {
    mockRepository = MockCalculatorRepository();
    calculatorBloc = CalculatorBloc(mockRepository);
  });

  tearDown(() {
    calculatorBloc.close();
  });

  const testSummary = CalculatorSummaryModel(
    assetId: null,
    assetsCount: 1,
    initialInvestment: 1000.0,
    feedCost: 100.0,
    vetCost: 50.0,
    utilityCost: 0.0,
    otherCost: 0.0,
    operatingExpenses: 150.0,
    totalCosts: 1150.0,
    totalEarnings: 1500.0,
    earningsByProduct: {'meat': 1500.0},
    netProfit: 350.0,
    roi: 30.43,
  );

  final testAssets = <LivestockAssetModel>[];

  group('CalculatorBloc', () {
    test('initial state is CalculatorInitial', () {
      expect(calculatorBloc.state, const CalculatorInitial());
    });

    blocTest<CalculatorBloc, CalculatorState>(
      'emits [CalculatorLoading, CalculatorSummaryLoaded] when FetchCalculatorSummaryEvent is successful',
      build: () {
        when(() => mockRepository.getSummary(assetId: any(named: 'assetId')))
            .thenAnswer((_) async => testSummary);
        when(() => mockRepository.getAssets())
            .thenAnswer((_) async => testAssets);
        return calculatorBloc;
      },
      act: (bloc) => bloc.add(const FetchCalculatorSummaryEvent()),
      expect: () => [
        const CalculatorLoading(),
        CalculatorSummaryLoaded(summary: testSummary, assets: testAssets),
      ],
      verify: (_) {
        verify(() => mockRepository.getSummary()).called(1);
        verify(() => mockRepository.getAssets()).called(1);
      },
    );

    blocTest<CalculatorBloc, CalculatorState>(
      'emits [CalculatorLoading, CalculatorError] when FetchCalculatorSummaryEvent throws an exception (Network Failure)',
      build: () {
        when(() => mockRepository.getSummary())
            .thenThrow(Exception('Network Error'));
        return calculatorBloc;
      },
      act: (bloc) => bloc.add(const FetchCalculatorSummaryEvent()),
      expect: () => [
        const CalculatorLoading(),
        const CalculatorError('Exception: Network Error'),
      ],
    );
  });
}
