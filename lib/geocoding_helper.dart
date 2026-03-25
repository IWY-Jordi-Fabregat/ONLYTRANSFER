import 'package:geocoding/geocoding.dart';

class GeocodingHelper {
  
  // 1. CERCADOR PER CODI POSTAL (El que evita que el 08 sigui Madrid)
  static Future<Map<String, String>> buscarLocalitzacio(String cp) async {
    if (cp.startsWith("08")) {
      return {
        'poblacio': 'BARCELONA',
        'provincia': 'BARCELONA',
      };
    }

    try {
      List<Location> locations = await locationFromAddress("$cp, Spain");
      if (locations.isNotEmpty) {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          locations.first.latitude,
          locations.first.longitude,
        );
        return {
          'poblacio': placemarks.first.locality?.toUpperCase() ?? '',
          'provincia': placemarks.first.administrativeArea?.toUpperCase() ?? '',
        };
      }
    } catch (e) {
      print("Error Geocoding: $e");
    }
    return {'poblacio': '', 'provincia': ''};
  }

  // 2. VERIFICADOR DE TERMINALS I RUTES (La teva intel·ligència VIP)
  static Map<String, String> verificarTerminal(String vol) {
    String v = vol.toUpperCase().replaceAll(' ', '');

    // --- CAS ESPECIAL: VOL DE CHARLOTTE (AA112) ---
    if (v == "AA112") {
      return {
        'terminal': 'TERMINAL T1', 
        'origen': 'CHARLOTTE (CLT)',
        'companyia': 'AMERICAN AIRLINES',
        'instruccions': 'Porta d\'Arribades principal (Planta 0)',
        'info_vol': 'Vol directe transatlàntic detectat.'
      };
    }

    // --- AEROPORT DE BARCELONA (BCN) ---
    // T1: Iberia, Vueling, Lufthansa, Emirates, American Airlines, Qatar...
    if (RegExp(r'^(IB|VY|LH|EK|AA|QR|AF|KL|BA|UA)').hasMatch(v)) {
      return {
        'terminal': 'TERMINAL T1', 
        'instruccions': 'Porta d\'Arribades principal (Planta 0)',
        'origen': 'AEROPORT T1'
      };
    }
    
    // T2: Ryanair, EasyJet, Wizz Air, Norwegian...
    if (RegExp(r'^(FR|U2|W6|DY|W9)').hasMatch(v)) {
      return {
        'terminal': 'TERMINAL T2 (B)', 
        'instruccions': 'Sota l\'estàtua del Cavall (Botero)',
        'origen': 'AEROPORT T2'
      };
    }

    // --- AEROPORT DE MADRID (MAD) ---
    if (v.startsWith('IB')) {
      return {
        'terminal': 'TERMINAL T4', 
        'instruccions': 'Arribades T4',
        'origen': 'MADRID T4'
      };
    }
    
    // --- VOLS PRIVATS / CORPORATIUS ---
    if (v.contains('PVT') || v.length < 4) {
      return {
        'terminal': 'TERMINAL DE VOLS PRIVATS', 
        'instruccions': 'Terminal Executiva (Cerca del Prat)',
        'origen': 'AVIACIÓ GENERAL'
      };
    }

    return {
      'terminal': 'DESCONEGUT', 
      'instruccions': 'Si us plau, verifiqui la terminal al panell',
      'origen': '---'
    };
  }
}
