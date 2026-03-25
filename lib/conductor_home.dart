import 'package:flutter/material.dart';

class PantallaConductor extends StatelessWidget {
  const PantallaConductor({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Les meves reserves',
          style: TextStyle(color: Color(0xFF2D3142), fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Exemple de viatge ja acceptat
          _targetaViatge(
            hora: "10:00 - 11:00",
            client: "Jordi Fabregat",
            origen: "Aeroport de Barcelona T1",
            desti: "Passeig de Gràcia, 12",
            estatColor: const Color(0xFF556677), // Gris Fosc (Ocupat)
            textBoto: "Veure detalls",
          ),
          const SizedBox(height: 20),
          
          // Exemple de nova petició pendent
          _targetaViatge(
            hora: "12:00 - 13:00",
            client: "Nou Client",
            origen: "Hotel Arts Barcelona",
            desti: "Estació de Sants",
            estatColor: const Color(0xFFFF700A), // Taronja (Acció pendent)
            textBoto: "Acceptar Reserva",
          ),
        ],
      ),
    );
  }

  Widget _targetaViatge({
    required String hora, 
    required String client, 
    required String origen, 
    required String desti,
    required Color estatColor,
    required String textBoto,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF778591).withOpacity(0.2)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(hora, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFFFF700A))),
              Icon(Icons.more_horiz, color: const Color(0xFF778591)),
            ],
          ),
          const Divider(height: 30),
          Text("CLIENT", style: TextStyle(fontSize: 10, color: const Color(0xFF778591), letterSpacing: 1.2)),
          Text(client, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 15),
          _puntTrajecte(Icons.radio_button_checked, origen),
          const Padding(
            padding: EdgeInsets.only(left: 11),
            child: SizedBox(height: 10, child: VerticalDivider(width: 1)),
          ),
          _puntTrajecte(Icons.location_on, desti),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: estatColor,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {},
              child: Text(textBoto, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  Widget _puntTrajecte(IconData icona, String text) {
    return Row(
      children: [
        Icon(icona, size: 18, color: const Color(0xFF556677)),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
      ],
    );
  }
}
