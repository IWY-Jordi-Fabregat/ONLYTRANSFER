import 'package:geocoding/geocoding.dart';

class ValidacioGeografica {
  // Aquesta funció la cridarem des de qualsevol pantalla (Registre, Reserva, Factura)
  static Future<Map<String, String>> obtenirDadesPerCP(String cp) async {
    // 1. EL FILTRE JORDI: Barcelona no es negocia
    if (cp.startsWith("08")) {
      return {
        'ciutat': 'BARCELONA',
        'provincia': 'BARCELONA',
        'pais': 'ESPANYA'
      };
    }

    // 2. EL FILTRE MADRID: Per si de cas (28)
    if (cp.startsWith("28")) {
      return {
        'ciutat': 'MADRID',
        'provincia': 'MADRID',
        'pais': 'ESPANYA'
      };
    }

    // 3. PLA B: Google Geocoding per a la resta del món (Dubai, Japó, etc.)
    try {
      List<Location> locations = await locationFromAddress("$cp, Spain");
      if (locations.isNotEmpty) {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          locations.first.latitude,
          locations.first.longitude,
        );
        return {
          'ciutat': placemarks.first.locality?.toUpperCase() ?? '',
          'provincia': placemarks.first.administrativeArea?.toUpperCase() ?? '',
          'pais': placemarks.first.country?.toUpperCase() ?? 'ESPANYA'
        };
      }
    } catch (e) {
      print("Error Geocoding: $e");
    }

    return {'ciutat': '', 'provincia': '', 'pais': 'ESPANYA'};
  }
}
