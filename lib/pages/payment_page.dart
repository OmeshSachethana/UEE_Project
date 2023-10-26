import 'package:flutter/material.dart';
import 'package:flutter_paypal/flutter_paypal.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({Key? key, required this.title, required this.highestBid})
      : super(key: key);
  final String title;
  final double highestBid;

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  double serviceCharge = 0.05; // 5% service charge

  @override
  Widget build(BuildContext context) {
    double totalAmount = widget.highestBid * (1 + serviceCharge);
    String totalAmountStr = totalAmount.toStringAsFixed(
        2); // Convert totalAmount to string with 2 decimal places

    var transactions = [
      {
        "amount": {
          "total": totalAmountStr,
          "currency": "USD",
          "details": {
            "subtotal": totalAmountStr,
            "shipping": '0',
            "shipping_discount": 0
          }
        },
        "description": "The payment transaction description.",
        "item_list": {
          "items": [
            {
              "name": "A demo product",
              "quantity": 1,
              "price": totalAmountStr,
              "currency": "USD"
            }
          ],
        }
      }
    ];

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: TextButton(
              onPressed: () => {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (BuildContext context) => UsePaypal(
                            sandboxMode: true,
                            clientId:
                                "AQnn6KdYQ7qb8AwBMK8B4LVnWau7tWmoj9XKe7V53RryuJowjeN7BLF8-JSfGCOJe1vpJu9fema6R8Qi",
                            secretKey:
                                "EGHi7FX1N2-yS-NwIi-4Ki1xZGrLQFCfF-zDHSEe5qfVb4YVGTbfsL5LlFZSCUdcldTyQvHrGdISwjNo",
                            returnURL: "https://samplesite.com/return",
                            cancelURL: "https://samplesite.com/cancel",
                            transactions: transactions,
                            note: "Contact us for any questions on your order.",
                            onSuccess: (Map params) async {
                              print("onSuccess: $params");
                            },
                            onError: (error) {
                              print("onError: $error");
                            },
                            onCancel: (params) {
                              print('cancelled: $params');
                            }),
                      ),
                    )
                  },
              child: const Text("Make Payment")),
        ));
  }
}
