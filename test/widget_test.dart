import 'package:flutter_test/flutter_test.dart';
import 'package:lifetours/main.dart';

void main() {
  testWidgets('App renders landing screen', (WidgetTester tester) async {
    await tester.pumpWidget(const LifeToursApp());
    await tester.pump();

    expect(find.text('Life Tours'), findsOneWidget);
    expect(find.text('Crear Cuenta'), findsOneWidget);
    expect(find.text('Iniciar Sesion'), findsOneWidget);
  });
}
