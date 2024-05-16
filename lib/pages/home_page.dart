import 'package:expense_tracker/bar%20graph/bar_graph.dart';
import 'package:expense_tracker/components/my_list_tile.dart';
import 'package:expense_tracker/database/expense_database.dart';
import 'package:expense_tracker/helper/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/expense.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    // TODO: implement initState
    Provider.of<ExpenseDatabase>(context, listen: false).readExpenses();
    refreshBarData();
    super.initState();
  }

  //controllers text
  TextEditingController nameController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  //futures
  late Future<Map<int, double>> _monthlyTotalsFuture;

  //refresh bar chart
  void refreshBarData() {
    _monthlyTotalsFuture = Provider.of<ExpenseDatabase>(context, listen: false)
        .calculateMonthlyTotals();
  }

  //open new expense box
  void openNewExpenseBox() {
    showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(
              title: const Text("New Expense"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  //expense name
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(hintText: "name"),
                  ),
                  TextField(
                    controller: amountController,
                    decoration: const InputDecoration(hintText: "amount"),

                  )
                  //expense amount
                ],
              ),
              actions: [
                _cancelButton(),
                _saveButton()
              ],

            )
    );
  }

  //open edit box
  void openEditBox(Expense expense) {
    String existingName = expense.name;
    String existingAmount = expense.amount.toString();

    showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(
              title: const Text("Edit Expense"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  //expense name
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(hintText: existingName),
                  ),
                  TextField(
                    controller: amountController,
                    decoration: InputDecoration(hintText: existingAmount),

                  )
                  //expense amount
                ],
              ),
              actions: [
                _cancelButton(),
                _newEditButton(expense)
              ],

            )
    );
  }

  //open delete box
  void openDeleteBox(Expense expense) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text("Edit Expense"),
            actions: [
              _cancelButton(),
              _deleteButton(expense.id)
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseDatabase>(
        builder: (context, value, child) {
          //get dates
          int startMonth = value.getStartMonth();
          int startYear = value.getStartYear();
          int currentMonth = DateTime.now().month;
          int currentYear = DateTime.now().year;

          // calculate number of months since first
          int monthCount = calculateMonthCount(startYear, startMonth, currentYear, currentMonth);

          // only display expenses for this month
          

          return Scaffold(
            backgroundColor: Colors.grey[300],
            floatingActionButton: FloatingActionButton(
              onPressed: () => openNewExpenseBox(),
              child: const Icon(Icons.add),
            ),
            body: SafeArea(
              child: Column(
                children: [
                  //Bar Graph
                  SizedBox(
                    height: 250,
                    child: FutureBuilder(
                        future: _monthlyTotalsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.done) {
                            final monthlyTotals = snapshot.data ?? {};

                            //list of monthly summary
                            List<double> monthlySummary =
                              List.generate(monthCount, (index) =>
                              monthlyTotals[startMonth + index] ?? 0.0);

                            return MyBarGraph(
                                monthlySummary: monthlySummary,
                                startMonth: startMonth
                            );

                          } else {
                            return const Center(child: Text("Loading!"));
                          }
                        }
                    ),
                  ),
                  // MyBarGraph(
                  //     monthlySummary: monthlySummary, startMonth: startMonth),
                  //Show Expenses
                  Expanded(
                    child: ListView.builder(
                        itemCount: value.allExpenses.length,
                        itemBuilder: (context, index) {
                          //individual expense
                          Expense individualExpense = value.allExpenses[index];

                          return MyListTile(
                            title: individualExpense.name,
                            trailing: formatDouble(individualExpense.amount),
                            onEditPressed: (context) =>
                                openEditBox(individualExpense),
                            onDeletePressed: (context) =>
                                openDeleteBox(individualExpense),
                          );
                        }
                    ),
                  ),
                ],
              ),
            ),
          );
        }
    );
  }

  // CANCEL Button
  Widget _cancelButton() {
    return MaterialButton(
      onPressed: () {
        Navigator.pop(context);
        nameController.clear();
        amountController.clear();
      },
      child: const Text("Cancel"),
    );
  }

  // Save button
  Widget _saveButton() {
    return MaterialButton(
      onPressed: () async {
        if (nameController.text.isNotEmpty &&
            amountController.text.isNotEmpty) {
          Navigator.pop(context);

          Expense newExpense = Expense(
            name: nameController.text,
            amount: ConvertStringToDouble(amountController.text),
            date: DateTime.now(),
          );


          await context.read<ExpenseDatabase>().createNewExpense(newExpense);
          refreshBarData();
          nameController.clear();
          amountController.clear();
        }
      },
      child: const Text("Save"),
    );
  }

  // Save Edit button
  Widget _newEditButton(Expense expense) {
    return MaterialButton(
      onPressed: () async {
        if (nameController.text.isNotEmpty ||
            amountController.text.isNotEmpty) {
          Navigator.pop(context);

          Expense updatedExpense = Expense(
            name: nameController.text.isNotEmpty
                ? nameController.text : expense.name,
            amount: amountController.text.isNotEmpty
                ? ConvertStringToDouble(amountController.text) : expense.amount,
            date: DateTime.now(),
          );
          int existingId = expense.id;

          await context.read<ExpenseDatabase>()
              .updateExpense(existingId, updatedExpense);
          refreshBarData();

          nameController.clear();
          amountController.clear();
        }
      },
      child: const Text("Save"),
    );
  }

  // Delete Button
  Widget _deleteButton(int id) {
    return MaterialButton(
      onPressed: () async {
        Navigator.pop(context);
        await context.read<ExpenseDatabase>().deleteExpense(id);
        refreshBarData();
      },
      child: const Text("Delete"),
    );
  }
}
