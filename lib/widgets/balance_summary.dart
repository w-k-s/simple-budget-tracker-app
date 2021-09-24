import 'package:flutter/material.dart';

class BalanceSummary extends StatelessWidget {
  final String totalIncome;
  final String totalExpenses;
  final String balance;
  final Color color;
  final EdgeInsets margin;

  BalanceSummary(
      {required this.totalIncome,
      required this.totalExpenses,
      required this.balance,
      this.color = Colors.blueAccent,
      this.margin = EdgeInsets.zero,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 4,
        margin: this.margin,
        color: this.color,
        child: Padding(
            padding: EdgeInsets.all(8.0),
            child: IntrinsicHeight(
                child: Row(
              children: [
                Expanded(
                    child: Column(children: [
                  Padding(
                    child: Text(
                      "Total Income",
                      textAlign: TextAlign.center,
                      maxLines: 1,
                    ),
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                  ),
                  Text(this.totalIncome,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center)
                ])),
                VerticalDivider(
                  width: 6.0,
                  thickness: 0.5,
                  color: Colors.white,
                ),
                Expanded(
                    child: Column(children: [
                  Padding(
                      child: Text(
                        "Total Expenses",
                        textAlign: TextAlign.center,
                        maxLines: 1,
                      ),
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 5)),
                  Text(
                    this.totalExpenses,
                  )
                ])),
                VerticalDivider(
                  width: 6.0,
                  thickness: 0.5,
                  color: Colors.white,
                ),
                Expanded(
                    child: Column(children: [
                  Padding(
                      child: Text(
                        "Balance",
                        textAlign: TextAlign.center,
                        maxLines: 1,
                      ),
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 5)),
                  Text(
                    this.balance,
                  )
                ]))
              ],
            ))));
  }
}
