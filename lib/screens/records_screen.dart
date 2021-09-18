import 'package:flutter/material.dart';
import '../models/record.dart';
import 'create_record_screen.dart';
import '../models/account.dart';
import '../services/budget_service.dart';
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
  Records? records;
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
        records = _records;
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
        title: Text(selectedAccount?.name ?? "Accounts"),
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
    if (_records == null || _records.records.isEmpty) {
      return Center(
        child: Text(
          "No records",
          textAlign: TextAlign.center,
          textScaleFactor: 1.3,
        ),
      );
    }

    return _buildRecordsList(context, _records);
  }

  ListView _buildRecordsList(BuildContext context, Records records) {
    return ListView.builder(
      itemCount: records.records.length,
      padding: EdgeInsets.all(8),
      itemBuilder: (context, index) {
        final record = records.records[index];
        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(record.note),
              subtitle: Text(
                  "${new DateFormat("yyyy-MMM-dd").format(record.dateUTC.toLocal())} • ${record.category.name}"),
              trailing: Text(record.amount.toString()),
            ),
          ),
        );
      },
    );
  }

  void _addNewRecord() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return CreateRecordScreen(selectedAccount: selectedAccount);
    })).then((_) => _setLoading(true)
        .then((_) => _loadRecords(context))
        .whenComplete(() => _setLoading(false)));
  }
}
