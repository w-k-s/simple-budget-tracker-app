import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:chopper/chopper.dart';
import 'package:flutter/material.dart';
import '../models/record.dart';
import '../services/budget_service.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({Key? key}) : super(key: key);

  @override
  _RecordsScreenState createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Records'),
      ),
      body: _buildBody(context),
    );
  }

  FutureBuilder<Response> _buildBody(BuildContext context) {
    return FutureBuilder<Response>(
      future: Provider.of<BudgetService>(context).getRecords(4),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
                textAlign: TextAlign.center,
                textScaleFactor: 1.3,
              ),
            );
          }

          final records = Records.fromJson(snapshot.data?.body ?? "{}");
          return _buildRecordsList(context, records);
        } else {
          // Show a loading indicator while waiting for the movies
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
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
                  "${new DateFormat("yyyy-MMM-dd").format(record.dateUTC.toLocal())} - ${record.category.name}"),
              trailing: Text(record.amount.toString()),
            ),
          ),
        );
      },
    );
  }
}
