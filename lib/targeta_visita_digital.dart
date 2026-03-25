import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class TargetaVisitaDigital extends StatelessWidget {
  final String nom = "Jordi Fabregat";
  final String carrec = "CEO & Private Chauffeur";
  final String telDubai = "+971 50 XXX XXXX"; // El teu número de Dubai
  final String email = "jordi@onlytransfer.com";

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Color(0xFF2D3142), // Gris Negre
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(0xFFFF700A), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("TARGETA DE VISITA VIP", 
            style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 3)),
          SizedBox(height: 20),
          
          // EL TEU LOGO/ICONO
          CircleAvatar(
            radius: 40,
            backgroundColor: Color(0xFFFF700A),
            child: Icon(Icons.airport_shuttle, color: Colors.white, size: 40),
          ),
          
          SizedBox(height: 20),
          Text(nom, style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          Text(carrec, style: TextStyle(color: Color(0xFF778591), fontSize: 14)),
          
          Divider(height: 40, color: Colors.white10),
          
          // DADES DE CONTACTE
          _filaDada(Icons.phone_android, telDubai),
          _filaDada(Icons.email, email),
          _filaDada(Icons.language, "onlytransfer.com"),
          
          SizedBox(height: 30),
          
          // EL BOTÓ DE COMPARTIR (El que fa la màgia)
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              icon: Icon(Icons.share, color: Colors.white),
              label: Text("COMPARTIR AMB CLIENT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFF700A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: () {
                final text = "ONLYTRANSFER VIP CONTACT\nName: $nom\nRole: $carrec\nPhone: $telDubai\nWeb: onlytransfer.com";
                Share.share(text);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filaDada(IconData icona, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icona, color: Color(0xFF556677), size: 16),
          SizedBox(width: 10),
          Text(text, style: TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }
}
