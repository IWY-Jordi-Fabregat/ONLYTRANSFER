import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Per posar l'hora exacta

class DiariBitacola extends StatelessWidget {
  // Simulació d'esdeveniments reals d'avui
  final List<Map<String, String>> esdeveniments = [
    {"hora": "11:45", "msg": "📱 iPhone Mandao: WhatsApp enviat correctament."},
    {"hora": "12:10", "msg": "💧 Kit VIP validat: Aigua i Ferreros a punt."},
    {"hora": "12:30", "msg": "💎 Servei VIP iniciat: Vol Somb - Pista Privats."},
    {"hora": "13:15", "msg": "🔇 Mode Silenci demanat pel client (Android 2)."},
    {"hora": "14:00", "msg": "💶 Factura 2026-0001-OT generada cap a Dubai."},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2D3142),
      appBar: AppBar(
        title: Text("DIARI DE BITÀCOLA (LOG)", style: TextStyle(color: Colors.white, fontSize: 14)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(20),
        itemCount: esdeveniments.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(esdeveniments[index]['hora']!, 
                  style: TextStyle(color: Color(0xFFFF700A), fontWeight: FontWeight.bold, fontSize: 12)),
                SizedBox(width: 20),
                Expanded(
                  child: Text(esdeveniments[index]['msg']!, 
                    style: TextStyle(color: Color(0xFF778591), fontSize: 14)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
