import 'dart:ui';
import 'package:json_annotation/json_annotation.dart';

part 'category.g.dart';

@JsonSerializable()
class Category {
  final int id;
  final String name;

  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryToJson(this);

  @override
  operator ==(o) => o is Category && o.id == id && o.name == name;

  @override
  int get hashCode => hashValues(id, name);
}

@JsonSerializable()
class Categories {
  final List<Category> categories;

  Categories({required this.categories});

  factory Categories.fromJson(Map<String, dynamic> json) =>
      _$CategoriesFromJson(json);

  Map<String, dynamic> toJson() => _$CategoriesToJson(this);

  Category? get first => categories.isEmpty ? null : categories.first;

  @override
  operator ==(o) => o is Categories && o.categories == categories;

  @override
  int get hashCode => hashList(categories);

  bool get isEmpty => categories.isEmpty;
}
