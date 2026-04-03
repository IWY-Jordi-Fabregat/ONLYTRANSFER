import 'package:deepl_dart/deepl_dart.dart';

class ServeiTraduccioOnlyTransfer {
  // 1. Posarem la nova clau (la que NO acaba en :fx)
  final String _authKey = "LA_TEVA_NOVA_CLAU_PRO"; 

  ServeiTraduccioOnlyTransfer() {
    _translator = Translator(
      authKey: _authKey,
      // 2. CANVIEM LA URL A PRO:
      serverUrl: "https://api.deepl.com", 
    );
  }
  Future<String> traduir(String text, String idiomaDesti) async {
    if (text.isEmpty) return text;

    try {
      // DeepL és intel·ligent: ell sol detecta si escrius en Català
      final result = await _translator.translateTextSingular(
        text,
        idiomaDesti.toUpperCase(), // DeepL vol els codis en majúscules (JA, EN, ES...)
      );
      return result.text;
    } catch (e) {
      print("Error DeepL: $e");
      return text; // Si falla, que no s'aturi el servei, enviem l'original
    }
  }
}
