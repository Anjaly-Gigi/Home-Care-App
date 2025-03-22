import 'package:clients/screen/paymentsuccesspage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:clients/main.dart';

class PaymentGatewayScreen extends StatefulWidget {
  final int bookingId;
  const PaymentGatewayScreen({super.key, required this.bookingId});

  @override
  _PaymentGatewayScreenState createState() => _PaymentGatewayScreenState();
}

class _PaymentGatewayScreenState extends State<PaymentGatewayScreen> {
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Future<void> checkout() async {
    try {
      await supabase
          .from('tbl_request')
          .update({'status': 6}).match({'id': widget.bookingId});
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment Successful!')),
        
      );
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PaymentSuccessPage()));
    } catch (e) {
      print('Error during payment: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Method'),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        color: Colors.white,
        child: SafeArea(
          child: Column(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color.fromARGB(255, 239, 56, 205),Color(0xFF9C27B0), Color(0xFFE040FB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                child: SizedBox(
                  width: 350, // Adjust width
                  height: 200, // Adjust height
                  child: CreditCardWidget(
                    cardNumber: cardNumber,
                    expiryDate: expiryDate,
                    cardHolderName: cardHolderName,
                    cvvCode: cvvCode,
                    showBackView: isCvvFocused,
                    onCreditCardWidgetChange: (creditCardBrand) {},
                    isHolderNameVisible: true,
                    glassmorphismConfig: Glassmorphism.defaultConfig(),
                    cardBgColor: Colors.transparent,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      spreadRadius: 2,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: CreditCardForm(
                  cardNumber: cardNumber,
                  expiryDate: expiryDate,
                  cardHolderName: cardHolderName,
                  cvvCode: cvvCode,
                  isHolderNameVisible: true,
                  themeColor: Colors.deepPurple,
                  onCreditCardModelChange: (creditCardModel) {
                    setState(() {
                      cardNumber = creditCardModel.cardNumber;
                      expiryDate = creditCardModel.expiryDate;
                      cardHolderName = creditCardModel.cardHolderName;
                      cvvCode = creditCardModel.cvvCode;
                      isCvvFocused = creditCardModel.isCvvFocused;
                    });
                  },
                  formKey: formKey,
                ),
              ),
              const Spacer(),
              Container(
                margin: const EdgeInsets.all(16),
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      checkout();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Please fill in all fields correctly!')),
                      );
                    }
                  },
                  child: const Text('Pay ',
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}