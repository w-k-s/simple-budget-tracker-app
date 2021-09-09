import 'dart:ui';
import 'package:json_annotation/json_annotation.dart';
import 'package:money2/money2.dart';

part 'amount.g.dart';

@JsonSerializable()
class Amount {
  final String currency;
  final int value;

  Amount({required this.currency, required this.value});
  factory Amount.fromJson(Map<String, dynamic> json) => _$AmountFromJson(json);
  Map<String, dynamic> toJson() => _$AmountToJson(this);

  @override
  String toString() {
    final it = Currencies.find('AED')!;
    print(it.pattern);
    final money = Money.fromBigInt(new BigInt.from(value), it);
    return money.format("###,###.00");
  }

  @override
  operator ==(o) => o is Amount && o.currency == currency && o.value == value;

  @override
  int get hashCode => hashValues(currency, value);
}