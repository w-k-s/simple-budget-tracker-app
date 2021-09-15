import 'package:budget_app/models/record.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/budget_service.dart';
import 'package:date_time_picker/date_time_picker.dart';
import '../models/account.dart';
import '../models/category.dart';

class CreateRecordScreen extends StatefulWidget {
  final Account? selectedAccount;

  const CreateRecordScreen({this.selectedAccount, Key? key}) : super(key: key);

  @override
  _CreateRecordScreenState createState() => _CreateRecordScreenState();
}

class _CreateRecordScreenState extends State<CreateRecordScreen> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("New Record"),
      ),
      body: new Container(
          padding: new EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: new CreateRecordForm()),
    );
  }
}

class CreateRecordForm extends StatefulWidget {
  final Account? selectedAccount;
  const CreateRecordForm({this.selectedAccount, Key? key}) : super(key: key);

  @override
  _CreateRecordFormState createState() => _CreateRecordFormState();
}

class _CreateRecordFormState extends State<CreateRecordForm> {
  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;
  Accounts accounts = Accounts(accounts: []);
  Categories categories = Categories(categories: []);
  String? error;

  DateTime? selectedDateTime;
  Type? selectedRecordType;
  Account? selectedAccount;
  Category? selectedCategory;
  Account? selectedBeneficiary;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      final service = context.read<BudgetService>();

      loadInitialData(service);
    });
  }

  void loadInitialData(BudgetService service) async {
    try {
      setState(() => isLoading = true);

      final _accounts = await _loadAccounts(service);
      final _categories = await _loadCategories(service);

      setState(() {
        isLoading = false;
        accounts = _accounts;
        categories = _categories;
        selectedAccount = widget.selectedAccount;
      });
    } catch (e) {
      print(e);
      error = "$e";
    }
  }

  Future<Accounts> _loadAccounts(BudgetService service) async {
    return service.getAccounts().onSuccess((json) => Accounts.fromJson(json));
  }

  Future<Categories> _loadCategories(BudgetService service) async {
    return service
        .getCategories()
        .onSuccess((json) => Categories.fromJson(json));
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return _buildForm(context);
  }

  Form _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButton<Type>(
              value: selectedRecordType ?? Type.EXPENSE,
              icon: const Icon(Icons.arrow_downward),
              iconSize: 24,
              underline: Container(
                height: 2,
                color: Colors.deepPurpleAccent,
              ),
              onChanged: (Type? newValue) {
                setState(() {
                  selectedRecordType = newValue;
                });
              },
              items: Type.values.map<DropdownMenuItem<Type>>((Type value) {
                return DropdownMenuItem<Type>(
                  value: value,
                  child: Text(value.name()),
                );
              }).toList()),
          DropdownButton<Category>(
              value: selectedCategory ?? categories.first,
              icon: const Icon(Icons.arrow_downward),
              iconSize: 24,
              underline: Container(
                height: 2,
                color: Colors.deepPurpleAccent,
              ),
              onChanged: (Category? newValue) {
                setState(() {
                  selectedCategory = newValue;
                });
              },
              items: categories.categories
                  .map<DropdownMenuItem<Category>>((Category value) {
                return DropdownMenuItem<Category>(
                  value: value,
                  child: Text(value.name),
                );
              }).toList()),
          Visibility(
              visible:
                  selectedRecordType == Type.TRANSFER && accounts.length != 1,
              child: DropdownButton<Account>(
                  value: selectedBeneficiary,
                  icon: const Icon(Icons.arrow_downward),
                  iconSize: 24,
                  underline: Container(
                    height: 2,
                    color: Colors.deepPurpleAccent,
                  ),
                  onChanged: (Account? newValue) {
                    setState(() {
                      selectedBeneficiary = newValue;
                    });
                  },
                  items: accounts.accounts
                      .where((account) => account.id != selectedAccount?.id)
                      .map<DropdownMenuItem<Account>>((Account value) {
                    return DropdownMenuItem<Account>(
                      value: value,
                      child: Text(value.name),
                    );
                  }).toList())),
          TextFormField(
            decoration: const InputDecoration(
              hintText: 'Title of the record',
              labelText: 'Note',
            ),
            maxLength: 50,
            textCapitalization: TextCapitalization.sentences,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
          ),
          TextFormField(
            decoration: const InputDecoration(
              hintText: 'Amount',
              labelText: 'Amount',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9\.,]'))
            ],
            validator: (value) {
              if (value == null ||
                  value.isEmpty ||
                  double.tryParse(value) == null) {
                return 'Please enter an amount';
              }
              return null;
            },
          ),
          DateTimePicker(
            type: DateTimePickerType.date,
            dateMask: 'd MMM, yyyy',
            initialValue: DateTime.now().toString(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
            dateLabelText: 'Date',
            onChanged: (val) {
              selectedDateTime = DateTime.parse(val);
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () {
                // Validate returns true if the form is valid, or false otherwise.
                if (_formKey.currentState!.validate()) {
                  // If the form is valid, display a snackbar. In the real world,
                  // you'd often call a server or save the information in a database.
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Processing Data')),
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
}
