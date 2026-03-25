import 'package:http/http.dart' as http;
import 'dart:convert';

class HoldedService {
  static const String apiKey = "LA_TEVA_CLAU_API_DE_HOLDED"; // La trobaràs a Holded
  static const String baseUrl = "https://api.holded.com/api/invoicing/v1";

  static Future<bool> crearIFacturar({
    required String nomEmpresa,
    required String email,
    required double import,
    required String concepte,
  }) async {
    try {
      // 1. Primer creem o busquem el contacte (Microsoft)
      // 2. Després creem la factura
      final response = await http.post(
        Uri.parse('$baseUrl/documents/invoice'),
        headers: {
          'key': apiKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "contactName": nomEmpresa,
          "contactEmail": email,
          "items": [
            {
              "name": concepte,
              "units": 1,
              "subtotal": import
            }
          ],
          "sendEmail": true // Això fa que s'enviï en menys d'una hora!
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      print("Error Holded: $e");
      return false;
    }
  }
}
