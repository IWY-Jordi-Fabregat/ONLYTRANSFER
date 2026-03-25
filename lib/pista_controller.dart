import 'package:url_launcher/url_launcher.dart';

class PistaController {
  // Aquesta és la URL que el "Mandao" veurà al seu WhatsApp
  // En el futur serà la teva web, ara fem una prova
  static const String urlBotoGegant = "https://onlytransfer.com/pista/recollida";

  static void enviarOrdreAlMandao(String telefon, String vol, String client) async {
    // El missatge que rebrà a l'iPhone (Directe i sense soroll)
    String missatge = "JORDI ONLYTRANSFER:\n"
        "📍 Vol: $vol\n"
        "👤 Client: $client\n\n"
        "Prem aquí quan els tinguis:\n$urlBotoGegant";

    String url = "https://wa.me/$telefon?text=${Uri.encodeComponent(missatge)}";

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
      print("🚀 Ordre enviada a l'iPhone del Mandao");
    } else {
      print("❌ Error: No s'ha pogut obrir WhatsApp");
    }
  }
}
