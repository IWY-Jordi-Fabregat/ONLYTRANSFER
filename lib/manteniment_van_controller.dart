import 'package:flutter/material.dart';

class MantenimentVan extends StatelessWidget {
  // Dades de control de la teva Mercedes Van VIP
  final int kmActuals = 45600;
  final int kmProximaRevisio = 50000;
  
  @override
  Widget build(BuildContext context) {
    double progresRevisio = kmActuals / kmProximaRevisio;

    return Scaffold(
      backgroundColor: Color(0 suicide2D3142), // Gris Negre
      appBar: AppBar(
        title: Text("ESTAT DE LA VAN VIP", style: TextStyle(color: Colors.white, fontSize: 14)),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            // INDICADOR VISUAL DE SALUT DEL VEHICLE
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 150,
                  height: 150,
                  child: CircularProgressIndicator(
                    value: progresRevisio,
                    strokeWidth: 10,
                    color: progresRevisio > 0.9 ? Colors.red : Color(0xFFFF700A),
                    backgroundColor: Colors.white10,
                  ),
                ),
                Icon(Icons.directions_car, color: Colors.white, size: 50),
              ],
            ),
            
            SizedBox(height: 40),
            
            // LLISTA DE PUNTS CRÍTICS
            _puntControl("Pneumàtics (Pressió/Desgast)", "OK - Fa 2.000 km", Icons.panorama_fish_eye),
            _puntControl("Nivell d'Oli i Filtres", "Revisar en 4.400 km", Icons.opacity),
            _puntControl("Neteja VIP Interior", "PENDENT (Avui 19:00h)", Icons.cleaning_services),
            _puntControl("Frenada i Seguretat", "OK - Revisió Oficial", Icons.e_mobiledata),
            
            Spacer(),
            
            // EL BOTÓ DE "TOT IMPECABLE"
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFF556677), // Gris Fosc
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Icon(Icons.verified, color: Color(0xFFFF700A)),
                  SizedBox(width: 15),
                  Expanded(
                    child: Text("LA VAN ESTÀ LLESTA PER ALS PROPERS 30 ANYS", 
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _puntControl(String titol, String estat, IconData icona) {
    return ListTile(
      leading: Icon(icona, color: Color(0xFF778591)),
      title: Text(titol, style: TextStyle(color: Colors.white, fontSize: 14)),
      subtitle: Text(estat, style: TextStyle(color: Colors.white38, fontSize: 12)),
      trailing: Icon(Icons.check_circle, color: Colors.green.withOpacity(0.5), size: 16),
    );
  }
}
