import 'dart:math';
import 'dart:io';

import 'package:expenses/components/chart.dart';

import 'package:flutter/material.dart';
import 'components/transaction_form.dart';
import '/models/transaction.dart';
import '/components/transaction_list.dart';

main() {
  runApp(const ExpensesApp());
}

class ExpensesApp extends StatelessWidget {
  const ExpensesApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ThemeData();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
      theme: ThemeData(
        colorScheme: theme.colorScheme.copyWith(
          primary: Colors.purple,
          secondary: Colors.amber,
        ),
        textTheme: theme.textTheme.copyWith(
          titleLarge: const TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          labelLarge: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        appBarTheme: const AppBarTheme(
          titleTextStyle: TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Transaction> _transactions = [];
  bool _showChart = false;

  List<Transaction> get _recentTransactions {
    return _transactions.where((tr) {
      return tr.date.isAfter(DateTime.now().subtract(
        const Duration(days: 7),
      ));
    }).toList();
  }

  _addTransaction(String title, double value, DateTime date) {
    final newTransaction = Transaction(
      id: Random().nextDouble().toString(),
      title: title,
      value: value,
      date: date,
    );

    setState(() {
      _transactions.add(newTransaction);
    });

    Navigator.of(context).pop();
  }

  _removeTransaction(String id) {
    setState(() {
      _transactions.removeWhere((tr) => tr.id == id);
    });
  }

  _openTransactionFormModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return TransactionForm(_addTransaction);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    bool isLandscape = mediaQuery.orientation == Orientation.landscape;

    final appBar = AppBar(
      title: Text(
        'Despesas Pessoais',
        style: TextStyle(
          fontSize: 20 * mediaQuery.textScaleFactor,
        ),
      ),
      actions: [
        if (isLandscape)
          IconButton(
            onPressed: () {
              setState(() {
                _showChart = !_showChart;
              });
              ;
            },
            icon: Icon(_showChart ? Icons.list : Icons.stacked_bar_chart),
          ),
        IconButton(
          onPressed: () {
            _openTransactionFormModal(context);
          },
          icon: const Icon(Icons.add),
        ),
      ],
    );

    final availableHeight = mediaQuery.size.height -
        appBar.preferredSize.height -
        mediaQuery.padding.top;

    return Scaffold(
        appBar: appBar,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_showChart || !isLandscape)
                Container(
                  height: availableHeight * (isLandscape ? 0.8 : 0.25),
                  child: Chart(_recentTransactions),
                ),
              if (!_showChart || !isLandscape)
                Container(
                    height: availableHeight * (isLandscape ? 1 : 0.65),
                    child: TransactionList(
                      _transactions,
                      _removeTransaction,
                    )),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _openTransactionFormModal(context);
          },
          child: Icon(Icons.add),
        ),
        floatingActionButtonLocation: !Platform.isIOS
            ? (isLandscape
                ? FloatingActionButtonLocation.centerFloat
                : FloatingActionButtonLocation.endFloat)
            : null);
  }
}
