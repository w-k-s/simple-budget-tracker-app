import 'dart:ui';
import 'package:json_annotation/json_annotation.dart';
import 'category.dart';
import 'amount.dart';

part 'record.g.dart';

enum Type {
  INCOME,
  EXPENSE,
  TRANSFER,
}

extension TypeName on Type {
  String name() {
    switch (this) {
      case Type.INCOME:
        return "Income";
      case Type.EXPENSE:
        return "Expense";
      case Type.TRANSFER:
        return "Transfer";
    }
  }
}

@JsonSerializable()
class Beneficiary {
  final int id;

  Beneficiary({required this.id});
  factory Beneficiary.fromJson(Map<String, dynamic> json) =>
      _$BeneficiaryFromJson(json);

  Map<String, dynamic> toJson() => _$BeneficiaryToJson(this);

  @override
  int get hashCode => this.id;

  @override
  operator ==(o) => o is Beneficiary && o.id == id;

  @override
  String toString() => "Beneficiary{id: $id}";
}

@JsonSerializable()
class Transfer {
  final Beneficiary beneficiary;
  Transfer({required this.beneficiary});
  factory Transfer.fromJson(Map<String, dynamic> json) =>
      _$TransferFromJson(json);

  Map<String, dynamic> toJson() => _$TransferToJson(this);

  @override
  int get hashCode => this.beneficiary.hashCode;

  @override
  operator ==(o) => o is Transfer && o.beneficiary == beneficiary;

  @override
  String toString() => "Transfer{beneficiary: $beneficiary}";
}

@JsonSerializable()
class AccountBalance {
  final int id;
  final Amount balance;
  AccountBalance({required this.id, required this.balance});
  factory AccountBalance.fromJson(Map<String, dynamic> json) =>
      _$AccountBalanceFromJson(json);

  Map<String, dynamic> toJson() => _$AccountBalanceToJson(this);

  @override
  int get hashCode => hashValues(this.id, this.balance);

  @override
  operator ==(o) => o is AccountBalance && o.id == id && o.balance == balance;

  @override
  String toString() => "AccountBalance{id: $id, balance: $balance}";
}

@JsonSerializable()
class Record {
  final int id;
  final String note;
  final Category category;
  final Amount amount;
  final Type type;
  @JsonKey(name: "date")
  final DateTime dateUTC;
  final Transfer? transfer;
  final AccountBalance? balance;
  Record(
      {required this.id,
      required this.note,
      required this.category,
      required this.amount,
      required this.type,
      required this.dateUTC,
      this.transfer,
      this.balance});
  factory Record.fromJson(Map<String, dynamic> json) => _$RecordFromJson(json);

  Map<String, dynamic> toJson() => _$RecordToJson(this);

  @override
  int get hashCode => hashValues(this.id, this.note, this.category, this.amount,
      this.type, this.dateUTC, this.transfer, this.balance);

  @override
  operator ==(o) =>
      o is Record &&
      o.id == id &&
      o.note == note &&
      o.category == category &&
      o.amount == amount &&
      o.type == type &&
      o.dateUTC == dateUTC &&
      o.transfer == transfer &&
      o.balance == balance;

  @override
  String toString() =>
      "Record{id: $id, amount: $amount, note: $note, type: $type, date: $dateUTC}";
}

@JsonSerializable()
class RecordsSummary {
  final Amount totalIncome;
  final Amount totalExpenses;

  RecordsSummary({required this.totalIncome, required this.totalExpenses});

  factory RecordsSummary.fromJson(Map<String, dynamic> json) =>
      _$RecordsSummaryFromJson(json);

  factory RecordsSummary.empty(String currency) => RecordsSummary(
      totalIncome: Amount.zero(currency), totalExpenses: Amount.zero(currency));

  Map<String, dynamic> toJson() => _$RecordsSummaryToJson(this);

  Amount get balance => this.totalIncome + this.totalExpenses;

  @override
  int get hashCode => hashValues(this.totalIncome, this.totalExpenses);

  @override
  operator ==(o) =>
      o is RecordsSummary &&
      o.totalIncome == totalIncome &&
      o.totalExpenses == totalExpenses;

  @override
  String toString() =>
      "RecordsSummary{totalIncome: $totalIncome, totalExpenses: $totalExpenses}";
}

@JsonSerializable()
class SearchParameters {
  final DateTime from;
  final DateTime to;

  SearchParameters({required this.from, required this.to});

  factory SearchParameters.fromJson(Map<String, dynamic> json) =>
      _$SearchParametersFromJson(json);

  factory SearchParameters.empty() => SearchParameters(
      from: DateTime.now().toUtc(), to: DateTime.now().toUtc());

  Map<String, dynamic> toJson() => _$SearchParametersToJson(this);

  @override
  int get hashCode => hashValues(this.from, this.to);

  @override
  operator ==(o) => o is SearchParameters && o.from == from && o.to == to;

  @override
  String toString() => "SearchParameters{from: $from, to: $to}";
}

@JsonSerializable()
class Records {
  final List<Record> records;
  final RecordsSummary summary;
  final SearchParameters search;

  Records({required this.records, required this.summary, required this.search});

  factory Records.fromJson(Map<String, dynamic> json) =>
      _$RecordsFromJson(json);

  Map<String, dynamic> toJson() => _$RecordsToJson(this);

  factory Records.empty(String currency) => Records(
      records: <Record>[],
      summary: RecordsSummary.empty(currency),
      search: SearchParameters.empty());

  @override
  int get hashCode => hashValues(
        this.summary,
        this.search,
        hashList(this.records),
      );

  @override
  operator ==(o) =>
      o is Records &&
      o.records == records &&
      o.summary == summary &&
      o.search == search;
}

@JsonSerializable()
class CreateRecord {
  final String note;
  final Category category;
  final Amount amount;
  final Type type;
  @JsonKey(name: "date")
  final DateTime dateUTC;
  final Transfer? transfer;
  CreateRecord(
      {required this.note,
      required this.category,
      required this.amount,
      required this.type,
      required this.dateUTC,
      this.transfer});
  factory CreateRecord.fromJson(Map<String, dynamic> json) =>
      _$CreateRecordFromJson(json);

  Map<String, dynamic> toJson() => _$CreateRecordToJson(this);
}
