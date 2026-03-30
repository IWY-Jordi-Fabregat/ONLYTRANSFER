// gestor_serveis.dart
class GestorServeis {
  static Future<void> registrarReserva({
    required String tipus,
    required String origen,
    required String desti,
    required String persones,
    required String maletes,
    required String notes,
    required String nom,
    required String email,
    required String telefon,
  }) async {
    // REGLA JORDI: Aquí és on 'tanquem el cercle'
    // Podem calcular el temps (Google + 10 min) i guardar-ho.
    
    print("""
    --- DADES REBUDES AL GESTOR ---
    SERVEI: $tipus
    RUTA: $origen -> $desti
    PASSATGERS: $persones | MALETES: $maletes
    CLIENT: $nom ($email - $telefon)
    NOTES: $notes
    -------------------------------
    """);

    // En el futur, aquí anirà el codi per enviar un WhatsApp o un Email automàtic.
  }
}
