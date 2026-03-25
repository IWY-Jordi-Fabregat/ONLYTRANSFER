import 'package:flutter/material.dart';

class CalendariDisponibilitat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2D3142),
      appBar: AppBar(
        title: Text("GESTIÓ DEL TEMPS (LLIBERTAT)", style: TextStyle(color: Colors.white, fontSize: 14)),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("AVUI: DISSABTE 21 MARÇ", style: TextStyle(color: Color(0xFFFF700A), fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            
            // L'HORITZÓ DEL DIA
            _franjaHoraria("09:00 - 11:00", "SERVEI CONFIRMAT", "T1 -> Hotel Arts (Microsoft)", Colors.green),
            _franjaHoraria("11:30 - 13:30", "SERVEI VIP", "Vols Privats -> Tour BCN (Somb)", Color(0xFFFF700A)),
            _franjaHoraria("14:00 - 16:00", "DINAR I DESCANS", "Temps de Pau - No disponible", Colors.blueGrey),
            _franjaHoraria("17:00 - 19:00", "DISPONIBLE", "Esperant petició corporativa", Colors.white24),
            
            Spacer(),
            
            // EL BOTÓ DE "BLOQUEJAR DIA"
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("MODE OXIGEN (REPOS)", style: TextStyle(color: Colors.white70)),
                  Switch(
                    value: false, 
                    onChanged: (v) {
                      print("📡 MODE PAU ACTIVAT: L'App no acceptarà més serveis per avui.");
                    },
                    activeColor: Color(0xFFFF700A),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _franjaHoraria(String hora, String titol, String desc, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: color, width: 4)),
        color: Colors.white.withOpacity(0.03),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(hora, style: TextStyle(color: Colors.white38, fontSize: 12)),
              Text(titol, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text(desc, style: TextStyle(color: Colors.white60, fontSize: 12)),
            ],
          ),
          Icon(Icons.access_time, color: color.withOpacity(0.5), size: 18),
        ],
      ),
    );
  }
}
