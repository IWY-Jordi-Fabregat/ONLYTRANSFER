import 'package:flutter/material.dart';

class CliResumViatge extends StatelessWidget {
  final Map<String, dynamic> dades;
  final String nomXofer;
  final VoidCallback onModificarHora;
  final VoidCallback onObrirXat; // El cable del xat
  final VoidCallback onTornar;

  const CliResumViatge({
    super.key, 
    required this.dades, 
    required this.nomXofer,
    required this.onModificarHora,
    required this.onObrirXat,
    required this.onTornar,
  });

  final Color taronja = const Color(0xFFFF700A);
  final Color grisNegre = const Color(0xFF2D3142);

  @override
  Widget build(BuildContext context) {
    String estat = (dades['estat_servei'] ?? 'PENDENT').toString().toUpperCase();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: onTornar,
        ),
        title: const Text("LA TEVA RESERVA", 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 1.2)),
        backgroundColor: grisNegre,
        centerTitle: true,
        elevation: 0,
        actions: [
          // BOTÓ DE XAT PREMIUM
          IconButton(
            onPressed: onObrirXat,
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
          ),
          const SizedBox(width: 5),
        ],
      ),
      body: Column(
        children: [
          // ESTAT DEL VIATGE
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            color: taronja.withOpacity(0.08),
            child: Column(
              children: [
                Text("ESTAT DEL VIATGE", 
                  style: TextStyle(color: taronja, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 2.0)),
                Text(estat, 
                  style: TextStyle(color: grisNegre, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              ],
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView(
                shrinkWrap: true,
                children: [
                  _filaDetall(Icons.person, "CONDUCTOR", nomXofer),
                  const Divider(height: 1),
                  
                  _filaHora(Icons.access_time_filled, "HORA DE RECOLLIDA", "${dades['hora'] ?? '--:--'} h"),
                  const Divider(height: 1),
                  
                  _filaDetall(Icons.location_on, "RECOLLIR A:", dades['origen'] ?? '-', destacat: true),
                  const Divider(height: 1),
                  
                  _filaDetall(Icons.flag_circle, "DESTÍ FINAL:", dades['desti'] ?? '-', destacat: true, colorIcona: Colors.green),
                  const Divider(height: 1),
                  
                  _filaDetall(Icons.directions_car, "VEHICLE", dades['cotxe'] ?? 'Premium Sedan'),
                ],
              ),
            ),
          ),

          // BOTONS FIXES A BAIX
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _botoTaronja("MODIFICAR HORA", onModificarHora),
                const SizedBox(height: 10),
                _botoBlanc("TORNAR A L'INICI", onTornar),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filaDetall(IconData icona, String titol, String valor, {bool destacat = false, Color? colorIcona}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icona, color: colorIcona ?? taronja, size: 20),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titol, 
                  style: const TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                const SizedBox(height: 4),
                Text(
                  valor.toUpperCase(),
                  style: TextStyle(
                    fontSize: destacat ? 14 : 12, 
                    fontWeight: FontWeight.w400, // Sense negreta
                    color: grisNegre,
                    height: 1.3, // Més espai entre línies si el text és llarg
                    letterSpacing: 1.1 // Lletres més separades
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filaHora(IconData icona, String titol, String valor) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icona, color: taronja, size: 20),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(titol, 
                        style: const TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                      const SizedBox(height: 4),
                      Text(
                        valor,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: grisNegre, letterSpacing: 1.2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        IconButton(
          onPressed: onModificarHora,
          icon: Icon(Icons.edit_calendar, color: taronja, size: 18),
        ),
      ],
    );
  }

  Widget _botoTaronja(String text, VoidCallback accio) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: taronja,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        onPressed: accio,
        child: Text(text, 
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.0)),
      ),
    );
  }

  Widget _botoBlanc(String text, VoidCallback accio) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFE0E0E0)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: accio,
        child: Text(text, 
          style: TextStyle(color: grisNegre, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.0)),
      ),
    );
  }
}
