import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import '../models/record.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(accounts?.primary?.name ?? "Accounts"),
      ),
      body: _buildBody(context),
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      final service = context.read<BudgetService>();
      loadInitialData(service);
    });
  }

  void loadInitialData(BudgetService service) async {
    setState(() {
      isLoading = true;
    });

    await _loadAccounts(service);

    final primaryAccount = accounts?.primary;
    if (primaryAccount != null) {
      await _loadRecords(service, primaryAccount.id);
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _loadAccounts(BudgetService service) async {
    final handleAccountError = (e) {
      print(e);
      if (accounts == null) {
        setState(() {
          error = "Failed to load accounts";
        });
      }
    };

    try {
      await service
          .getAccounts()
          .parse((json) => Accounts.fromJson(json))
          .then((_accounts) => setState(() {
                accounts = _accounts;
              }))
          .catchError(handleAccountError);
    } catch (e) {
      handleAccountError(e);
    }
  }

  Future<void> _loadRecords(BudgetService service, int accountId) async {
    final handleRecordsError = (e) {
      print(e);
      if (records == null) {
        setState(() {
          error = "Failed to load records";
        });
      }
    };

    try {
      await service
          .getRecords(accountId)
          .parse((json) => Records.fromJson(json))
          .then((_records) => setState(() {
                records = _records;
              }))
          .catchError(handleRecordsError);
    } catch (e) {
      handleRecordsError(e);
    }
  }

  Widget _buildBody(BuildContext context) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    final _error = error;
    if (_error != null) {
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
}
