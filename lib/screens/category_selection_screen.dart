import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/category.dart';
import 'package:provider/provider.dart';
import '../services/budget_service.dart';

class CategorySelectionScreen extends StatefulWidget {
  const CategorySelectionScreen({Key? key}) : super(key: key);

  @override
  _CategorySelectionScreenState createState() =>
      _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  bool isLoading = false;
  String? error;
  Categories? categories;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      loadInitialData(context);
    });
  }

  void loadInitialData(BuildContext context) async {
    await _setLoading(true)
        .then((_) => _loadCategoris(context))
        .whenComplete(() => _setLoading(false));
  }

  Future<void> _loadCategoris(BuildContext context) async {
    final service = context.read<BudgetService>();
    return service
        .getCategories()
        .onSuccess((json) => Categories.fromJson(json))
        .then((_categories) {
      setState(() {
        categories = _categories;
      });
    }).catchError((e) {
      setState(() {
        error = e.message;
      });
    });
  }

  Future<void> _setLoading(bool loading) {
    setState(() {
      isLoading = loading;
    });
    return Future.value();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Categories"),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    final _error = error;
    if (categories == null && _error != null) {
      return Center(
        child: Text(
          _error,
          textAlign: TextAlign.center,
          textScaleFactor: 1.3,
        ),
      );
    }

    final _categories = categories;
    if (_categories == null || _categories.isEmpty) {
      return Center(
        child: Text(
          "No Categories",
          textAlign: TextAlign.center,
          textScaleFactor: 1.3,
        ),
      );
    }

    return _buildCategoriesList(context);
  }

  Widget _buildCategoriesList(BuildContext context) {
    return ListView.builder(
        itemCount: categories?.categories.length ?? 0,
        padding: EdgeInsets.all(8),
        itemBuilder: (context, index) {
          final category = categories!.categories[index];
          return ListTile(
            title: Text(category.name),
            onTap: () => Navigator.pop(context, category),
          );
        });
  }
}
