import 'package:budget_app/services/budget_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/records_screen.dart';
import 'package:logging/logging.dart';
import 'package:money2/money2.dart';

void main() {
  _setupLogging();
  _setupCurrencies();
  runApp(SimpleBudgetTracker());
}

void _setupLogging() {
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });
}

void _setupCurrencies() {
  CommonCurrencies().registerAll();
  Currencies.register(Currency.create('AED', 2));
}

class SimpleBudgetTracker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          Provider<BudgetService>(
            create: (_) => BudgetService.create(),
            dispose: (_, BudgetService service) => service.client.dispose(),
          )
        ],
        child: MaterialApp(
          theme: ThemeData.dark().copyWith(
            primaryColor: Color(0xFF0A0E21),
            scaffoldBackgroundColor: Color(0xFF0A0E21),
          ),
          home: RecordsScreen(),
        ));
  }
}
