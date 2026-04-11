import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

// --- ESTÈTICA ONLYTRANSFER ---
const Color colorTaronjaVIP = Color(0xFFFF700A);
const Color colorGrisClar = Color(0xFFF0F2F5);
const Color colorGrisFosc = Color(0xFF556677);
const Color colorGrisNegre = Color(0xFF2D3142);
const Color colorTextSecundari = Color(0xFF778591);

class EnvioConsultaReserva extends StatefulWidget {
  const EnvioConsultaReserva({super.key});

  @override
  State<EnvioConsultaReserva> createState() => _EnvioConsultaReservaState();
}

class _EnvioConsultaReservaState extends State<EnvioConsultaReserva> {
  final TextEditingController _codiController = TextEditingController();
  Map<String, dynamic>? _dadesReserva;
  bool _buscant = false;

  // --- FUNCIÓ PER BUSCAR LA RESERVA AL BÚNQUER ---
  Future<void> _buscarReserva() async {
    String codiEntrat = _codiController.text.toUpperCase().trim();
    if (codiEntrat.isEmpty) return;

    setState(() {
      _buscant = true;
      _dadesReserva = null;
    });

    try {
      final query = await FirebaseFirestore.instance
          .collection('reserves')
          .where('codi_reserva', isEqualTo: codiEntrat)
          .get();

      if (query.docs.isNotEmpty) {
        setState(() {
          _dadesReserva = query.docs.first.data();
        });
      } else {
        _mostrarError("Codi no trobat. Revisa el teu tiquet.");
      }
    } catch (e) {
      _mostrarError("Error en la connexió.");
    } finally {
      setState(() => _buscant = false);
    }
  }

  // --- FUNCIÓ MÀGICA: EL XAT DELS NERVIS ---
  void _obrirXat() async {
    // Aquí posa el teu telèfon de Dubai o Espanya (amb el prefix, ex: 34600000000)
    const String elMeuTelefon = "34600000000"; 
    final String codi = _codiController.text.toUpperCase();
    final String missatge = "Hola, que és la meva primera vegada i estic nerviós amb la reserva $codi";
    
    final Uri url = Uri.parse("https://wa.me/$elMeuTelefon?text=${Uri.encodeComponent(missatge)}");
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      _mostrarError("No s'ha pogut obrir el xat.");
    }
  }

  void _mostrarError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('LA MEVA RESERVA', style: TextStyle(color: colorGrisNegre, letterSpacing: 2, fontSize: 14, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: colorGrisNegre, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text("INTRODUEIX EL TEU CODI", style: TextStyle(color: colorTextSecundari, fontSize: 11, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            
            // Entrada del Codi
            TextField(
              controller: _codiController,
              textAlign: TextAlign.center,
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 8, color: colorTaronjaVIP),
              decoration: InputDecoration(
                filled: true,
                fillColor: colorGrisClar,
                hintText: "XXXXXX",
                hintStyle: TextStyle(color: colorTextSecundari.withOpacity(0.3), letterSpacing: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
            
            const SizedBox(height: 25),
            
            _buscant 
              ? const CircularProgressIndicator(color: colorTaronjaVIP)
              : SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _buscarReserva,
                    style: ElevatedButton.styleFrom(backgroundColor: colorGrisNegre, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: const Text("CONSULTAR ESTAT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),

            // Resultats de la cerca
            if (_dadesReserva != null) ...[
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(color: colorGrisClar, borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: [
                    _filaResum(Icons.person_outline, "CLIENT", _dadesReserva!['client']),
                    const Divider(height: 30),
                    _filaResum(Icons.calendar_today, "DATA I HORA", "${_dadesReserva!['data']} - ${_dadesReserva!['hora']}"),
                    const Divider(height: 30),
                    _filaResum(Icons.location_on_outlined, "ORIGEN", _dadesReserva!['origen']),
                    const Divider(height: 30),
                    _filaResum(Icons.flag_outlined, "DESTÍ", _dadesReserva!['desti']),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // El botó de parlar
              GestureDetector(
                onTap: _obrirXat,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(color: colorGrisFosc),
                    borderRadius: BorderRadius.circular(15)
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.chat_bubble_outline, color: colorGrisFosc, size: 20),
                      const SizedBox(width: 12),
                      const Text("PARLAR AMB NOSALTRES", style: TextStyle(color: colorGrisFosc, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text("Atenció VIP 24h", style: TextStyle(color: colorTextSecundari, fontSize: 10)),
            ]
          ],
        ),
      ),
    );
  }

  Widget _filaResum(IconData icon, String titol, String valor) {
    return Row(
      children: [
        Icon(icon, size: 18, color: colorGrisFosc),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titol, style: const TextStyle(fontSize: 9, color: colorTextSecundari, fontWeight: FontWeight.bold)),
              Text(valor, style: const TextStyle(fontSize: 13, color: colorGrisNegre, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}
