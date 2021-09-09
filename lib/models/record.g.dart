// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Beneficiary _$BeneficiaryFromJson(Map<String, dynamic> json) {
  return Beneficiary(
    id: json['id'] as int,
  );
}

Map<String, dynamic> _$BeneficiaryToJson(Beneficiary instance) =>
    <String, dynamic>{
      'id': instance.id,
    };

Transfer _$TransferFromJson(Map<String, dynamic> json) {
  return Transfer(
    beneficiary:
        Beneficiary.fromJson(json['beneficiary'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$TransferToJson(Transfer instance) => <String, dynamic>{
      'beneficiary': instance.beneficiary,
    };

AccountBalance _$AccountBalanceFromJson(Map<String, dynamic> json) {
  return AccountBalance(
    id: json['id'] as int,
    balance: Amount.fromJson(json['balance'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$AccountBalanceToJson(AccountBalance instance) =>
    <String, dynamic>{
      'id': instance.id,
      'balance': instance.balance,
    };

Record _$RecordFromJson(Map<String, dynamic> json) {
  return Record(
    id: json['id'] as int,
    note: json['note'] as String,
    category: Category.fromJson(json['category'] as Map<String, dynamic>),
    amount: Amount.fromJson(json['amount'] as Map<String, dynamic>),
    type: _$enumDecode(_$TypeEnumMap, json['type']),
    dateUTC: DateTime.parse(json['date'] as String),
    transfer: json['transfer'] == null
        ? null
        : Transfer.fromJson(json['transfer'] as Map<String, dynamic>),
    balance: json['balance'] == null
        ? null
        : AccountBalance.fromJson(json['balance'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$RecordToJson(Record instance) => <String, dynamic>{
      'id': instance.id,
      'note': instance.note,
      'category': instance.category,
      'amount': instance.amount,
      'type': _$TypeEnumMap[instance.type],
      'date': instance.dateUTC.toIso8601String(),
      'transfer': instance.transfer,
      'balance': instance.balance,
    };

K _$enumDecode<K, V>(
  Map<K, V> enumValues,
  Object? source, {
  K? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  return enumValues.entries.singleWhere(
    (e) => e.value == source,
    orElse: () {
      if (unknownValue == null) {
        throw ArgumentError(
          '`$source` is not one of the supported values: '
          '${enumValues.values.join(', ')}',
        );
      }
      return MapEntry(unknownValue, enumValues.values.first);
    },
  ).key;
}

const _$TypeEnumMap = {
  Type.INCOME: 'INCOME',
  Type.EXPENSE: 'EXPENSE',
  Type.TRANSFER: 'TRANSFER',
};

RecordsSummary _$RecordsSummaryFromJson(Map<String, dynamic> json) {
  return RecordsSummary(
    totalIncome: Amount.fromJson(json['totalIncome'] as Map<String, dynamic>),
    totalExpenses:
        Amount.fromJson(json['totalExpenses'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$RecordsSummaryToJson(RecordsSummary instance) =>
    <String, dynamic>{
      'totalIncome': instance.totalIncome,
      'totalExpenses': instance.totalExpenses,
    };

SearchParameters _$SearchParametersFromJson(Map<String, dynamic> json) {
  return SearchParameters(
    from: DateTime.parse(json['from'] as String),
    to: DateTime.parse(json['to'] as String),
  );
}

Map<String, dynamic> _$SearchParametersToJson(SearchParameters instance) =>
    <String, dynamic>{
      'from': instance.from.toIso8601String(),
      'to': instance.to.toIso8601String(),
    };

Records _$RecordsFromJson(Map<String, dynamic> json) {
  return Records(
    records: (json['records'] as List<dynamic>)
        .map((e) => Record.fromJson(e as Map<String, dynamic>))
        .toList(),
    summary: RecordsSummary.fromJson(json['summary'] as Map<String, dynamic>),
    search: SearchParameters.fromJson(json['search'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$RecordsToJson(Records instance) => <String, dynamic>{
      'records': instance.records,
      'summary': instance.summary,
      'search': instance.search,
    };
