import 'package:flutter/material.dart';
import 'package:harvestly/core/services/auth/auth_service.dart';

class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthService().currentUser!;
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Cartão de Crédito",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    foregroundColor:
                        Theme.of(context).colorScheme.onSecondaryContainer,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        width: 0.5,
                        color: Theme.of(context).colorScheme.surface,
                      ),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add,
                        color: Theme.of(context).colorScheme.surface,
                        size: 30,
                      ),
                      Text(
                        "Adicionar Cartão",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.surface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "IBAN",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              TextFormField(enabled: false, initialValue: currentUser.iban),
            ],
          ),
          const SizedBox(height: 30),
          Column(
            children: [
              Row(
                children: [
                  Container(
                    height: 50,
                    width: 50,
                    child: Image.asset('assets/images/paypal.png'),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "PayPal",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const Divider(),
              Row(
                children: [
                  Container(
                    height: 50,
                    width: 50,
                    child: Image.asset('assets/images/google_pay.png'),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Google Pay",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const Divider(),
              Row(
                children: [
                  Container(
                    height: 50,
                    width: 50,
                    child: Image.asset('assets/images/apple_pay.png'),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Apple Pay",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const Divider(),
            ],
          ),
        ],
      ),
    );
  }
}
