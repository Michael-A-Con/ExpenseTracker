import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:path_provider/path_provider.dart';

class ExpenseDatabase with ChangeNotifier {
  static late Isar isar;
  List<Expense> _allExpenses = [];


  // Init Database
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([ExpenseSchema], directory: dir.path);
  }

  //Getter Methods
  List<Expense> get allExpenses => _allExpenses;

  //CRUD Operations
  //Create
  Future<void> createNewExpense(Expense newExpense) async {
    //write transaction to db
    await isar.writeTxn(() => isar.expenses.put(newExpense));

    //reread from db
    await readExpenses();
  }

  //Read
  Future<void> readExpenses() async {
    List<Expense> fetchedExpenses = await isar.expenses.where().findAll();
    _allExpenses.clear();
    _allExpenses.addAll(fetchedExpenses);

    notifyListeners();
  }

  //Update
  Future<void> updateExpense(int id, Expense updatedExpense) async {
    updatedExpense.id = id;

    await isar.writeTxn(() => isar.expenses.put(updatedExpense));

    await readExpenses();
  }

  //Delete
  Future<void> deleteExpense(int id) async {
    await isar.writeTxn(() => isar.expenses.delete(id));
    await  readExpenses();
  }

  //Helper methods

  //calculate total expenses per month
  Future<Map<int, double>> calculateMonthlyTotals() async {
    await readExpenses();

    Map<int, double> monthlyTotals = {};

    for (var expense in _allExpenses) {
      int month = expense.date.month;

      if (!monthlyTotals.containsKey(month)) {
        monthlyTotals[month] = 0;
      }

      monthlyTotals[month] = monthlyTotals[month]! + expense.amount;

    }
    return monthlyTotals;
  }

  //get start month
  int getStartMonth() {
    if (_allExpenses.isEmpty) {
      return DateTime.now().month;
    }

    _allExpenses.sort(
        (a, b) => a.date.compareTo(b.date),
    );

    return _allExpenses.first.date.month;
}

  //get start year
  int getStartYear() {
    if (_allExpenses.isEmpty) {
      return DateTime.now().year;
    }

    _allExpenses.sort(
          (a, b) => a.date.compareTo(b.date),
    );

    return _allExpenses.first.date.year;
  }


}