import 'package:flutter/material.dart';
import 'resum_caixa_final.dart'; // Vista Conductor
import 'menu_bord_vip.dart';      // Vista Client
import 'radar_vip_screen.dart';   // Vista Pista

class SeleccioRolScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2D3142), // Gris Negre corporatiu
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo_app.png', height: 100), // El teu logo taronja
            SizedBox(height: 50),
            Text("BENVINGUT A ONLYTRANSFER", 
              style: TextStyle(color: Colors.white, fontSize: 12, letterSpacing: 3, fontWeight: FontWeight.bold)),
            SizedBox(height: 40),
            
            _botoRol(context, "MODO CONDUCTOR", Icons.directions_car, Color(0xFFFF700A), ResumCaixaFinal()),
            SizedBox(height: 20),
            _botoRol(context, "MODO CLIENT VIP", Icons.star, Colors.white10, MenuBordVip()),
            SizedBox(height: 20),
            _botoRol(context, "CONTROL DE PISTA", Icons.flight_land, Colors.white10, RadarVipScreen()),
          ],
        ),
      ),
    );
  }

  Widget _botoRol(BuildContext context, String titol, IconData icona, Color color, Widget destino) {
    return SizedBox(
      width: double.infinity,
      height: 70,
      child: OutlinedButton.icon(
        icon: Icon(icona, color: color == Color(0xFFFF700A) ? Colors.white : Color(0xFFFF700A)),
        label: Text(titol, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        style: OutlinedButton.styleFrom(
          backgroundColor: color,
          side: BorderSide(color: Color(0xFFFF700A).withOpacity(0.5)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => destino)),
      ),
    );
  }
}
