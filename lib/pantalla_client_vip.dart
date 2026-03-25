import 'package:flutter/material.dart';

class PantallaClientVip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Blanc pur, menys és més
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text("ONLYTRANSFER EXPERIENCE", 
          style: TextStyle(color: Color(0xFF2D3142), fontSize: 12, letterSpacing: 2)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            // FOTO DEL JORDI I EL COTXE
            CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFF778591), // Gris Clar
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            SizedBox(height: 20),
            Text("Jordi Fabregat", 
              style: TextStyle(color: Color(0xFF2D3142), fontSize: 22, fontWeight: FontWeight.w600)),
            Text("Mercedes Van VIP • 7785-GFC", 
              style: TextStyle(color: Color(0xFF778591), fontSize: 14)),
            
            SizedBox(height: 40),
            
            // ESTAT DEL SERVEI (Línia de temps neta)
            _liniaEstat("Recollida confirmada", true),
            _liniaEstat("Vehicle en posició a Vols Privats", true),
            _liniaEstat("Camí del vostre destí", false),
            
            Spacer(),
            
            // EL BOTÓ DE "FLIPAR" PER AL CLIENT
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _iconaServei(Icons.ac_unit, "21°C"),
                  _iconaServei(Icons.wifi, "WiFi ON"),
                  _iconaServei(Icons.local_drink, "Aigua"),
                ],
              ),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _liniaEstat(String text, bool fet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(fet ? Icons.check_circle : Icons.radio_button_unchecked, 
               color: fet ? Color(0xFFFF700A) : Colors.black12),
          SizedBox(width: 15),
          Text(text, style: TextStyle(color: fet ? Colors.black87 : Colors.black26)),
        ],
      ),
    );
  }

  Widget _iconaServei(IconData icona, String text) {
    return Column(
      children: [
        Icon(icona, color: Color(0xFF556677)),
        SizedBox(height: 5),
        Text(text, style: TextStyle(fontSize: 10, color: Color(0xFF556677))),
      ],
    );
  }
}
