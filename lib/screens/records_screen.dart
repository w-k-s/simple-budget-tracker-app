import 'dart:developer' as dev;

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
      final service = context.read<BudgetService>();
      loadInitialData(service);
    });
  }

  void loadInitialData(BudgetService service) async {
    try {
      setState(() => isLoading = true);

      final _accounts = await _loadAccounts(service);
      final _primaryAccount = _accounts.primary;
      var _records;
      if (_primaryAccount != null) {
        _records = await _loadRecords(service, _primaryAccount.id);
      }

      setState(() {
        isLoading = false;
        accounts = _accounts;
        records = _records;
        selectedAccount = _primaryAccount;
      });
    } catch (e) {
      print(e);
      error = "$e";
    }
  }

  void _refresh(BuildContext context) async {
    try {
      setState(() {
        isLoading = true;
      });

      final budgetService = context.read<BudgetService>();
      final _records = await _loadRecords(budgetService, selectedAccount!.id);
      setState(() {
        records = _records;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<Accounts> _loadAccounts(BudgetService service) async {
    return service.getAccounts().onSuccess((json) => Accounts.fromJson(json));
  }

  Future<Records> _loadRecords(BudgetService service, int accountId) async {
    return service
        .getRecords(accountId)
        .onSuccess((json) => Records.fromJson(json));
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
    })).then((value) => _refresh(context));
  }
}
