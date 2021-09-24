import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/record.dart';
import 'create_record_screen.dart';
import '../models/account.dart';
import '../models/amount.dart';
import '../services/budget_service.dart';
import '../widgets/balance_summary.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({Key? key}) : super(key: key);

  @override
  _RecordsScreenState createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  bool isLoading = false;
  String? error;
  RecordsViewModel? records;
  Accounts? accounts;
  Account? selectedAccount;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      loadInitialData(context);
    });
  }

  void loadInitialData(BuildContext context) async {
    await _setLoading(true)
        .then((_) => _loadAccounts(context))
        .then((_) => _loadRecords(context))
        .whenComplete(() => _setLoading(false));
  }

  Future<void> _loadAccounts(BuildContext context) async {
    final service = context.read<BudgetService>();
    return service
        .getAccounts()
        .onSuccess((json) => Accounts.fromJson(json))
        .then((_accounts) {
      setState(() {
        accounts = _accounts;
        selectedAccount = _accounts.primary;
      });
    }).catchError((e) {
      setState(() {
        error = e.message;
      });
    });
  }

  Future<void> _loadRecords(BuildContext context) async {
    final service = context.read<BudgetService>();
    if (selectedAccount == null) {
      return Future.value(Records.empty("USD"));
    }
    return service
        .getRecords(selectedAccount!.id)
        .onSuccess((json) => Records.fromJson(json))
        .then((_records) {
      setState(() {
        records = RecordsViewModel.fromRecords(_records);
      });
    }).catchError((e) {
      setState(() {
        error = e.message;
      });
    });
  }

  Future<void> _setLoading(bool loading) {
    setState(() {
      isLoading = loading;
    });
    return Future.value();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: InkWell(
            onTap: () => _showAccountPicker(),
            child: Text(selectedAccount?.name ?? "Account")),
      ),
      body: _buildBody(context),
      floatingActionButton: new Visibility(
        visible: selectedAccount != null,
        child: new FloatingActionButton(
          onPressed: _addNewRecord,
          child: new Icon(Icons.add),
          backgroundColor: Colors.red,
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    final _error = error;
    if (records == null && accounts == null && _error != null) {
      return Center(
        child: Text(
          _error,
          textAlign: TextAlign.center,
          textScaleFactor: 1.3,
        ),
      );
    }

    final _accounts = accounts;
    if (_accounts == null || _accounts.accounts.isEmpty) {
      return Center(
        child: Text(
          "Create an account",
          textAlign: TextAlign.center,
          textScaleFactor: 1.3,
        ),
      );
    }

    final _records = records;
    if (_records == null || _records.isEmpty) {
      return Center(
        child: Text(
          "No records",
          textAlign: TextAlign.center,
          textScaleFactor: 1.3,
        ),
      );
    }

    return _buildRecordsList(context);
  }

  void _showAccountPicker() {
    showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return _buildAccountPickerSheet(context);
        });
  }

  Widget _buildAccountPickerSheet(BuildContext context) {
    assert(accounts != null && accounts!.length > 0);

    return Container(
        height: 200,
        color: Colors.blueAccent,
        child: Center(
            child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(children: [
                  Center(
                      child: Text("Select Account",
                          style: Theme.of(context).textTheme.headline6)),
                  Expanded(
                      child: ListView.builder(
                          itemCount: accounts?.accounts.length ?? 0,
                          padding: EdgeInsets.all(8),
                          itemBuilder: (context, index) {
                            return ListTile(
                                title: Text(accounts!.accounts[index].name),
                                onTap: () {
                                  Navigator.pop(context);
                                  setState(() {
                                    selectedAccount = accounts?.accounts[index];
                                    records = null;
                                  });
                                  _loadRecords(context);
                                });
                          }))
                ]))));
  }

  Widget _buildRecordsList(BuildContext context) {
    return ListView.builder(
        itemCount: records?.items.length ?? 0,
        padding: EdgeInsets.all(8),
        itemBuilder: (context, index) {
          return records!.items[index].buildTile(context);
        });
  }

  void _addNewRecord() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return CreateRecordScreen(selectedAccount: selectedAccount);
    })).then((_) => _setLoading(true)
        .then((_) => _loadRecords(context))
        .whenComplete(() => _setLoading(false)));
  }
}

abstract class RecordListTile {
  Widget buildTile(BuildContext context);
}

class AccountSummaryListItem implements RecordListTile {
  RecordsSummary summary;

  AccountSummaryListItem({required this.summary});

  @override
  Widget buildTile(BuildContext context) {
    return BalanceSummary(
        totalExpenses: this.summary.totalExpenses.toString(),
        totalIncome: this.summary.totalIncome.toString(),
        balance: this.summary.balance.toString(),
        margin: const EdgeInsets.only(left: 8.0, right: 8.0));
  }
}

class CalendarMonthListItem implements RecordListTile {
  static final dateFormat = DateFormat("MMMM yyyy");
  final CalendarMonth calendarMonth;

  CalendarMonthListItem({required this.calendarMonth});

  @override
  Widget buildTile(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            dateFormat.format(calendarMonth.month.toLocal()),
            style: Theme.of(context).textTheme.headline5,
          ))
    ]);
  }
}

class MonthSummaryLlistItem implements RecordListTile {
  final Amount totalExpenses;
  final Amount totalIncome;

  MonthSummaryLlistItem(
      {required this.totalExpenses, required this.totalIncome});

  @override
  Widget buildTile(BuildContext context) {
    return BalanceSummary(
        totalExpenses: this.totalExpenses.toString(),
        totalIncome: this.totalIncome.toString(),
        balance: (this.totalIncome + this.totalExpenses).toString(),
        color: Colors.grey.shade700,
        margin: const EdgeInsets.only(left: 8.0, right: 8.0));
  }
}

class DateListItem implements RecordListTile {
  static final dateFormat = DateFormat("EEEE, dd");

  final DateTime date;
  DateListItem({required this.date});

  @override
  Widget buildTile(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8),
        child: Text(
          dateFormat.format(date.toLocal()),
          style: Theme.of(context).textTheme.bodyText1,
        ));
  }
}

class RecordItem implements RecordListTile {
  final Record record;
  RecordItem({required this.record});

  @override
  Widget buildTile(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: ListTile(
          title: Text(record.note),
          subtitle: Text("${record.category.name}"),
          trailing: Text(record.amount.toString()),
        ),
      ),
    );
  }
}

class CalendarMonth {
  DateTime month;
  CalendarMonth({required this.month});
  factory CalendarMonth.of(int month, int year) =>
      CalendarMonth(month: DateTime.utc(year, month, 1));
  factory CalendarMonth.ofDate(DateTime date) =>
      CalendarMonth.of(date.month, date.year);

  @override
  operator ==(o) => o is CalendarMonth && o.month == month;

  @override
  int get hashCode => month.hashCode;

  @override
  String toString() {
    return month.toString();
  }
}

class RecordsViewModel {
  RecordsSummary summary;
  List<RecordListTile> items;

  RecordsViewModel({required this.items, required this.summary});

  factory RecordsViewModel.fromRecords(Records records) {
    final recordsList = records.records;
    final currency = records.summary.balance.currency;

    if (recordsList.isEmpty) {
      return RecordsViewModel(items: [], summary: records.summary);
    }

    recordsList.sort((r1, r2) {
      if (r1.dateUTC == r2.dateUTC) return 0;
      if (r2.dateUTC.isAfter(r1.dateUTC)) return 1;
      return -1;
    });

    final expensesPerMonth = Map<CalendarMonth, DailyExpenses>();
    for (final record in recordsList) {
      final recordDate = DateTime.utc(
          record.dateUTC.year, record.dateUTC.month, record.dateUTC.day);

      final calendarMonth = CalendarMonth.ofDate(record.dateUTC);
      final dailyExpenses = expensesPerMonth[calendarMonth];
      if (dailyExpenses == null) {
        expensesPerMonth[calendarMonth] = Map<DateTime, List<Record>>();
        expensesPerMonth[calendarMonth]![recordDate] = [record];
        continue;
      }

      final expensesOfDay = dailyExpenses[recordDate];
      if (expensesOfDay == null) {
        dailyExpenses[recordDate] = [record];
      } else {
        expensesOfDay.add(record);
      }
    }

    final items = <RecordListTile>[];
    items.add(AccountSummaryListItem(summary: records.summary));

    for (final monthlyEntry in expensesPerMonth.entries) {
      final month = monthlyEntry.key;
      final expensesPerDay = monthlyEntry.value;
      final expensesOfMonth =
          expensesPerDay.values.expand((element) => element).toList();

      items.add(CalendarMonthListItem(calendarMonth: month));
      items.add(MonthSummaryLlistItem(
          totalExpenses: expensesOfMonth.totalExpenses(currency),
          totalIncome: expensesOfMonth.totalIncome(currency)));
      for (final dailyEntry in expensesPerDay.entries) {
        final day = dailyEntry.key;
        final records = dailyEntry.value;

        items.add(DateListItem(date: dailyEntry.key));
        for (final record in records) {
          items.add(RecordItem(record: record));
        }
      }
    }

    return RecordsViewModel(items: items, summary: records.summary);
  }

  bool get isEmpty => this.items.isEmpty;
}

typedef DailyExpenses = Map<DateTime, List<Record>>;
