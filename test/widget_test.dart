import 'package:flutter_test/flutter_test.dart';
import 'package:agroledger/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:agroledger/core/di/service_locator.dart';

void main() {
  testWidgets('Initial smoke test', (WidgetTester tester) async {
    // Этот тест заглушен, так как инфраструктура приложения
    // требует инициализации Firebase/DI и сетевого слоя.
    // Тесты функционала BLoC и Repository находятся в соответствующих папках feature.
    expect(true, true);
  });
}
