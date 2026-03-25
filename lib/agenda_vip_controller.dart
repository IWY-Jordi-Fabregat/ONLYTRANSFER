import 'package:flutter/material.dart';

class AgendaVip extends StatelessWidget {
  // Simulació de la teva agenda de contactes de poder
  final List<Map<String, String>> clientsVip = [
    {"nom": "Somb (Artista)", "pref": "Aigua natural, Ferrero negres, silenci total."},
    {"nom": "Executiu Microsoft", "pref": "Wifi actiu, premsa del dia, rumb directe T1."},
    {"nom": "CEO Apple", "pref": "Aigua molt freda, tovalloles humides extres."},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2D3142),
      appBar: AppBar(
        title: Text("AGENDA DE PREFERÈNCIES", style: TextStyle(color: Colors.white, fontSize: 16)),
        backgroundColor: Colors.transparent,
      ),
      body: ListView.builder(
        itemCount: clientsVip.length,
        itemSender: (context, index) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(clientsVip[index]['nom']!, 
                  style: TextStyle(color: Color(0xFFFF700A), fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(clientsVip[index]['pref']!, 
                        style: TextStyle(color: Colors.white70, fontSize: 14)),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
