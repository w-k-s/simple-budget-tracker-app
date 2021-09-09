import 'dart:convert';
import 'package:test/test.dart';
import 'package:budget_app/models/record.dart';
import 'package:budget_app/models/category.dart';

void main() {
  group('Records', () {
    test('records json can be deserialized', () {
      final json = """{
        "records": [{
          "id": 1,
          "note": "Salary",
          "category": {
            "id": 1630067305041,
            "name": "Salary"
          },
          "amount": {
            "currency": "AED",
            "value": 10000
          },
          "date": "2021-01-01T00:00:00+0000",
          "type": "INCOME"
        }],
        "summary": {
          "totalExpenses": {
            "currency": "AED",
            "value": 0
          },
          "totalIncome": {
            "currency": "AED",
            "value": 10000
          }
        },
        "search": {
          "from": "2021-01-01T00:00:00Z",
          "to": "2021-01-01T00:00:00Z"
        }
      }""";
      final record = Records.fromJson(jsonDecode(json));

      expect(record.records[0].amount.toString(), "AED 10000");
      expect(record.records[0].note, "Salary");
      expect(record.records[0].category,
          Category(id: 1630067305041, name: "Salary"));
      expect(record.records[0].type, Type.INCOME);
      expect(record.summary.totalIncome.toString(), "AED 10000");
      expect(record.summary.totalExpenses.toString(), "AED 0");
    });
  });
}
