import 'package:flutter/material.dart';

class MenuBordVip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("SERVEIS A BORD", 
            style: TextStyle(color: Color(0xFF2D3142), fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          SizedBox(height: 10),
          Text("Personalitzi la seva experiència OnlyTransfer", 
            style: TextStyle(color: Color(0xFF778591), fontSize: 13)),
          
          SizedBox(height: 30),
          
          // GRILLES DE SERVEIS (Simplicitat Apple)
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              children: [
                _opcioMenu(Icons.local_drink, "Aigua Freda", "Natural o amb gas"),
                _opcioMenu(Icons.newspaper, "Premsa", "Digital / iPad"),
                _opcioMenu(Icons.restaurant, "Snacks VIP", "Ferrero / Fruita"),
                _opcioMenu(Icons.device_thermostat, "Clima", "Ajustar al gust"),
                _opcioMenu(Icons.battery_charging_full, "Càrrega", "Cables a punt"),
                _opcioMenu(Icons.volume_off, "Silenci", "Màxima privacitat"),
              ],
            ),
          ),
          
          // BOTÓ DE CONTACTE DIRECTE AMB TU
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Color(0xFF2D3142),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.mic_none, color: Color(0xFFFF700A)),
                SizedBox(width: 10),
                Text("PARLAR AMB EL XÒFER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _opcioMenu(IconData icona, String titol, String subtitol) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.03)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icona, color: Color(0xFFFF700A), size: 30),
          SizedBox(height: 10),
          Text(titol, style: TextStyle(color: Color(0xFF2D3142), fontWeight: FontWeight.bold, fontSize: 14)),
          Text(subtitol, textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF556677), fontSize: 10)),
        ],
      ),
    );
  }
}
