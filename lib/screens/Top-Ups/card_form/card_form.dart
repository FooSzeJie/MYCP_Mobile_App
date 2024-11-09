import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CardForm extends StatefulWidget {
  final String userId;

  const CardForm({Key? key, required this.userId}) : super(key: key);

  @override
  State<CardForm> createState() => _CardFormState();
}

class _CardFormState extends State<CardForm> {
  // Text Controllers
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();
  final TextEditingController expiryController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    // Add listeners to form fields to update button state
    cardNumberController.addListener(_validateForm);
    nameController.addListener(_validateForm);
    cvvController.addListener(_validateForm);
    expiryController.addListener(_validateForm);
    priceController.addListener(_validateForm);
  }

  void _validateForm() {
    setState(() {
      _isFormValid = cardNumberController.text.isNotEmpty &&
          nameController.text.isNotEmpty &&
          cvvController.text.isNotEmpty &&
          expiryController.text.isNotEmpty &&
          priceController.text.isNotEmpty &&
          _formKey.currentState?.validate() == true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: cardNumberController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(19),
                      CardNumberInputFormatter(),
                    ],
                    decoration: const InputDecoration(
                      labelText: "Card Number",
                      prefixIcon: Icon(Icons.credit_card),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty || value.length < 19) {
                        return 'Please enter a valid card number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "Full Name",
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the cardholder name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: cvvController,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(3),
                          ],
                          decoration: const InputDecoration(
                            labelText: "CVV",
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.length < 3) {
                              return 'Invalid CVV';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: expiryController,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                            CardMonthInputFormatter(),
                          ],
                          decoration: const InputDecoration(
                            labelText: "MM/YY",
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.length != 5) {
                              return 'Invalid expiry date';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      PriceInputFormatter(),
                    ],
                    decoration: const InputDecoration(
                      labelText: "Price",
                      prefixText: "\$ ",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a valid price';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const Spacer(),
            if (_isFormValid)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF6E48F9),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Perform checkout action
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Checkout Successful")),
                    );
                  }
                },
                child: const Text("Checkout"),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    cardNumberController.dispose();
    nameController.dispose();
    cvvController.dispose();
    expiryController.dispose();
    priceController.dispose();
    super.dispose();
  }
}

class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    String inputData = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();

    for (var i = 0; i < inputData.length; i++) {
      buffer.write(inputData[i]);
      if ((i + 1) % 4 == 0 && i + 1 != inputData.length) {
        buffer.write(" ");
      }
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class CardMonthInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    var newText = newValue.text.replaceAll('/', '');
    final buffer = StringBuffer();

    for (int i = 0; i < newText.length; i++) {
      buffer.write(newText[i]);
      if (i == 1 && i + 1 != newText.length) {
        buffer.write('/');
      }
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class PriceInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    double value = double.tryParse(digitsOnly) ?? 0;
    String formatted = (value / 100).toStringAsFixed(2);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
