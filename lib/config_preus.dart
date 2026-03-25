class PreusConfig {
  // Aquí definim els preus per a cada vehicle
  static const Map<String, double> llistaPreus = {
    'Sedan 2 pax': 65.00,
    'MiniVan 6 pax': 85.00,
    'Bussines de Luxe 2 pax': 110.00,
    'SUV Premiun 6 pax': 130.00,
  };

  static double obtenirPreu(String vehicle) {
    return llistaPreus[vehicle] ?? 0.00;
  }
}
