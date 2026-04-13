import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';

class StripeService {
  static Future<void> executarPagamentDirecte({
    required String nomClient,
  }) async {
    final response = await http.post(
      Uri.parse('https://api.stripe.com/v1/payment_intents'),
      headers: {
        'Authorization': 'Bearer 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',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'amount': '100',
        'currency': 'eur',
        'description': 'Reserva OnlyTransfer: $nomClient',
      },
    );

    final jsonResponse = json.decode(response.body);

    if (jsonResponse['error'] != null) {
      throw Exception(jsonResponse['error']['message']);
    }

    final String? clientSecret = jsonResponse['client_secret'];
    if (clientSecret == null) {
      throw Exception("Error de connexió amb Stripe");
    }

    await Stripe.instance.confirmPayment(
      paymentIntentClientSecret: clientSecret,
      data: const PaymentMethodParams.card(
        paymentMethodData: PaymentMethodData(),
      ),
    );
  }
}
