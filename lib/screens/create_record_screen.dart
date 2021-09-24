import 'package:budget_app/models/record.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/budget_service.dart';
import 'package:date_time_picker/date_time_picker.dart';
import '../models/account.dart';
import '../models/category.dart';
import '../models/amount.dart';
import 'category_selection_screen.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/cupertino.dart';

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
          child: new CreateRecordForm(selectedAccount: widget.selectedAccount)),
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
  bool isSubmitting = false;
  Accounts accounts = Accounts(accounts: []);
  Categories categories = Categories(categories: []);
  String? error;

  DateTime? selectedDateTime;
  Type? selectedRecordType;
  Account? selectedAccount;
  Category? selectedCategory;
  Account? selectedBeneficiary;
  String amount = "0.00";
  String title = "";

  TextEditingController _categoryController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      final service = context.read<BudgetService>();

      _loadInitialData(service);
    });
  }

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  void _loadInitialData(BudgetService service) async {
    try {
      setState(() {
        isLoading = true;
        selectedRecordType = Type.EXPENSE;
        selectedDateTime = DateTime.now().toLocal();
        selectedAccount = widget.selectedAccount;
      });

      final _accounts = await _loadAccounts(service);
      final _categories = await _loadCategories(service);

      _categoryController.text = _categories.first?.name ?? "";

      setState(() {
        isLoading = false;
        accounts = _accounts;
        categories = _categories;
        selectedCategory = _categories.first;
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

  void _submit(BuildContext context) async {
    Transfer? transfer;

    if (this.selectedRecordType == Type.TRANSFER) {
      transfer =
          Transfer(beneficiary: Beneficiary(id: this.selectedBeneficiary!.id));
    }

    final request = CreateRecord(
      type: this.selectedRecordType!,
      category: this.selectedCategory!,
      amount: Amount.parseDecimal(selectedAccount!.currency, this.amount),
      note: this.title,
      dateUTC: this.selectedDateTime!.toUtc(),
      transfer: transfer,
    );

    try {
      final budgetService = context.read<BudgetService>();
      await budgetService
          .createRecord(this.selectedAccount!.id, request)
          .onSuccess((json) => Record.fromJson(json));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Record Created"),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
      ));
    }
  }

  void _selectCategory() async {
    final Category _category =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return CategorySelectionScreen();
    }));

    _categoryController.text = _category.name;
    setState(() {
      selectedCategory = _category;
    });
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

  final _recordTypeSegmentedControllerChildren = {
    Type.INCOME: Text(
      "Income",
      style: TextStyle(color: Colors.white),
    ),
    Type.EXPENSE: Text("Expense", style: TextStyle(color: Colors.white)),
    Type.TRANSFER: Text("Transfer", style: TextStyle(color: Colors.white))
  };

  Form _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CupertinoSegmentedControl<Type>(
            children: _recordTypeSegmentedControllerChildren,
            groupValue: selectedRecordType,
            borderColor: Colors.blueAccent,
            selectedColor: Colors.blueAccent,
            unselectedColor: Colors.transparent,
            onValueChanged: (index) {
              setState(() {
                selectedRecordType = index as Type;
              });
            },
          ),
          TextFormField(
              decoration: const InputDecoration(
                  hintText: 'Category of record',
                  labelText: 'Category',
                  counterText: ""),
              maxLength: 50,
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a category';
                }
                return null;
              },
              onSaved: (value) {
                title = value ?? "";
              },
              controller: _categoryController,
              onTap: () => {_selectCategory()},
              readOnly: true),
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
            onSaved: (value) {
              title = value ?? "";
            },
          ),
          TextFormField(
            decoration: const InputDecoration(
              hintText: 'Amount',
              labelText: 'Amount',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9\.,]')),
              CurrencyTextInputFormatter(symbol: ""),
            ],
            onSaved: (value) {
              amount = value ?? "0.00";
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an amount';
              }
              final amount = double.tryParse(value) ?? 0;
              if (amount == 0 || amount < 0) {
                return "Amount must not be less than or equal to 0";
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
              onSaved: (val) {
                selectedDateTime = DateTime.parse(val!);
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a date';
                }
                return null;
              }),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () {
                      // Validate returns true if the form is valid, or false otherwise.
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        setState(() {
                          isSubmitting = true;
                        });
                        _submit(context);
                        setState(() {
                          isSubmitting = false;
                        });
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
