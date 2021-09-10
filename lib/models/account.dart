import 'dart:ui';
import 'package:json_annotation/json_annotation.dart';

part 'account.g.dart';

@JsonSerializable()
class Account {
  final int id;
  final String name;
  final String currency;

  Account({required this.id, required this.name, required this.currency});

  factory Account.fromJson(Map<String, dynamic> json) =>
      _$AccountFromJson(json);

  Map<String, dynamic> toJson() => _$AccountToJson(this);

  @override
  operator ==(o) =>
      o is Account && o.id == id && o.name == name && o.currency == currency;

  @override
  int get hashCode => hashValues(id, name, currency);
}

@JsonSerializable()
class Accounts {
  final List<Account> accounts;

  Accounts({required this.accounts});
  factory Accounts.fromJson(Map<String, dynamic> json) =>
      _$AccountsFromJson(json);

  Map<String, dynamic> toJson() => _$AccountsToJson(this);

  Account? get primary => accounts.isEmpty ? null : accounts.first;

  @override
  int get hashCode => hashList(this.accounts);

  @override
  operator ==(o) => o is Accounts && o.accounts == accounts;
}
