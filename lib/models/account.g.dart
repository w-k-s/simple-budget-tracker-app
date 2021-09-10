// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Account _$AccountFromJson(Map<String, dynamic> json) {
  return Account(
    id: json['id'] as int,
    name: json['name'] as String,
    currency: json['currency'] as String,
  );
}

Map<String, dynamic> _$AccountToJson(Account instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'currency': instance.currency,
    };

Accounts _$AccountsFromJson(Map<String, dynamic> json) {
  return Accounts(
    accounts: (json['accounts'] as List<dynamic>)
        .map((e) => Account.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$AccountsToJson(Accounts instance) => <String, dynamic>{
      'accounts': instance.accounts,
    };
