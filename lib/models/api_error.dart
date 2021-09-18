import 'dart:ui';
import 'package:json_annotation/json_annotation.dart';

part 'api_error.g.dart';

@JsonSerializable()
class Problem {
  final String type;
  final String title;
  final int status;
  final String detail;
  final String instance;

  Problem(
      {required this.type,
      required this.title,
      required this.status,
      required this.detail,
      required this.instance});

  factory Problem.fromJson(Map<String, dynamic> json) =>
      _$ProblemFromJson(json);
  Map<String, dynamic> toJson() => _$ProblemToJson(this);

  @override
  String toString() => "$detail";

  @override
  operator ==(o) => o is Problem && o.type == type && o.instance == instance;

  @override
  int get hashCode => hashValues(type, instance);
}
