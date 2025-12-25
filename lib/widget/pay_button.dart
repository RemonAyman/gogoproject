import 'package:flutter/material.dart';

class PayButton extends StatefulWidget {
  final String amount;
  const PayButton({super.key, required this.amount});

  @override
  State<PayButton> createState() => _PayButtonState();
}

class _PayButtonState extends State<PayButton> {
  bool paid = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.payment),
        style: ElevatedButton.styleFrom(
            backgroundColor: paid ? Colors.green : Colors.orange,
            padding: const EdgeInsets.symmetric(vertical: 14)),
        label: Text(paid ? "Payment Successful ✅" : "Pay ${widget.amount}",
            style: const TextStyle(fontSize: 16)),
        onPressed: () {
          setState(() => paid = true);
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Payment successful ✅")));
        },
      ),
    );
  }
}