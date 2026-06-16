import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

// Importem la teva pantalla i el main per a la funció t()
import 'pantalla_confirmacio.dart'; 
import '../main.dart'; 

class PantallaClientWeb extends StatefulWidget {
  const PantallaClientWeb({super.key});

  @override
  State<PantallaClientWeb> createState() => _PantallaClientWebState();
}

class _PantallaClientWebState extends State<PantallaClientWeb> {
  final TextEditingController _controller = TextEditingController();
  String? _codiABuscar;

  // FUNCIÓ MESTRA: Paga i salta a la teva PantallaConfirmacio
  Future<void> _executarPagamentIFinalitzar(String docId, String nom, String correu, String resum) async {
    try {
      // 1. Stripe presenta la targeta
      await Stripe.instance.presentPaymentSheet();

      // 2. SI EL PAGAMENT ÉS OK -> GRAVEM AL BÚNQUER
      await FirebaseFirestore.instance.collection('reserves').doc(docId).set({
        'estat_pagament': 'PAGAT',
        'estat_logistic': 'DISPONIBLE',
        'data_pagament': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 3. TANQUEM EL CERCLE
      if (!mounted) return;
      FocusScope.of(context).unfocus();

      // Saltem a la teva pantalla enviant-li les dades que demana
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PantallaConfirmacio(
            nomClient: nom,
            correuClient: correu,
            resumServei: resum,
          ),
        ),
      );

    } catch (e) {
      print("Procés aturat: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 50),
                const Text("ONLYTRANSFER", style: TextStyle(color: Color(0xFF2D3142), fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 5)),
                const Text("LUXURY TRANSPORT", style: TextStyle(color: Color(0xFF778591), fontSize: 10, letterSpacing: 2)),
                const SizedBox(height: 60),
                
                SizedBox(
                  width: 400,
                  child: TextField(
                    controller: _controller,
                    textAlign: TextAlign.center,
                    textCapitalization: TextCapitalization.characters,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(hintText: "CODI DE RESERVA"),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () => setState(() => _codiABuscar = _controller.text.trim().toUpperCase()),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF700A)),
                  child: const Text("VEURE EL MEU VIATGE", style: TextStyle(color: Colors.white)),
                ),

                const SizedBox(height: 50),

                if (_codiABuscar != null && _codiABuscar!.isNotEmpty)
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('reserves').where('codi_reserva', isEqualTo: _codiABuscar).limit(1).snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const SizedBox();
                      
                      var doc = snapshot.data!.docs.first;
                      var dades = doc.data() as Map<String, dynamic>;
                      String docId = doc.id;

                      // Dades per enviar a la pantalla de confirmació
                      String nom = dades['client'] ?? "Client";
                      String correu = dades['email'] ?? "";
                      String resum = "${dades['data']} - ${dades['hora']} - ${dades['desti']}";

                      return Column(
                        children: [
                          _filaDada("CLIENT", nom),
                          _filaDada("DESTÍ", dades['desti'] ?? ""),
                          _filaDada("ESTAT", dades['estat_pagament'] ?? ""),
                          const SizedBox(height: 30),

                          if (dades['estat_pagament'] != "PAGAT")
                            ElevatedButton(
                              onPressed: () => _executarPagamentIFinalitzar(docId, nom, correu, resum),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2D3142),
                                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20)
                              ),
                              child: const Text("PAGAR ARA AMB EL MÒBIL", style: TextStyle(color: Colors.white)),
                            )
                          else
                            const Text("PAGAMENT FINALITZAT ✅", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                        ],
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _filaDada(String titol, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(titol, style: const TextStyle(color: Color(0xFF778591), fontWeight: FontWeight.bold, fontSize: 12)),
          Expanded(child: Text(valor, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}
