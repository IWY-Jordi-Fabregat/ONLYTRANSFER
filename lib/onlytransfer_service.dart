import 'dart:math' as math;

/// L'ESTÀNDARD JORDI FABREGAT: PUNT I A PART
enum TerminalAeroport { t1, t2, volsPrivats }

class OnlyTransferService {
  // 1. Configuració de Seguretat (Geofencing)
  // Coordenades reals per evitar "guapos" a la platja
  static const Map<TerminalAeroport, Map<String, double>> puntsControl = {
    TerminalAeroport.t1: {'lat': 41.2883, 'lon': 2.0733},
    TerminalAeroport.t2: {'lat': 41.3032, 'lon': 2.0745},
    TerminalAeroport.volsPrivats: {'lat': 41.2945, 'lon': 2.0550},
  };

  // 2. Estat del Kit VIP (Imprescindible per sortir)
  bool aiguaNatural = false;
  bool ferreroTancats = false;
  bool caramelsMelLlimona = false;
  bool tovallolesHumides = false;

  // 3. Validació de Posició Real
  bool validarArribada(double latActual, double lonActual, TerminalAeroport terminal) {
    double latDesti = puntsControl[terminal]!['lat']!;
    double lonDesti = puntsControl[terminal]!['lon']!;

    double distancia = _calcularMetres(latActual, lonActual, latDesti, lonDesti);

    if (distancia > 500) {
      print("⚠️ ERROR: Massa lluny de la terminal ($distancia m). No pots fitxar.");
      return false;
    }
    print("✅ VALIDAT: Ets a la zona de recollida.");
    return true;
  }

  // 4. Protocol de Sortida (Fidelització Total)
  bool verificarProtocolSortida() {
    if (aiguaNatural && ferreroTancats && caramelsMelLlimona && tovallolesHumides) {
      print("🚀 Protocol VIP Validat. Llest per al Tour o recollida.");
      return true;
    }
    print("❌ ATENCIÓ: Revisa el Kit VIP. L'aigua ha de ser natural i els Ferrero tancats.");
    return false;
  }

  // 5. Motor de Distància (Haversine)
  double _calcularMetres(double lat1, double lon1, double lat2, double lon2) {
    const double radiTerra = 6371000; // metres
    double dLat = _grausARadians(lat2 - lat1);
    double dLon = _grausARadians(lon2 - lon1);
    
    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
               math.cos(_grausARadians(lat1)) * math.cos(_grausARadians(lat2)) *
               math.sin(dLon / 2) * math.sin(dLon / 2);
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return radiTerra * c;
  }

  double _grausARadians(double graus) => graus * (math.pi / 180);
}
