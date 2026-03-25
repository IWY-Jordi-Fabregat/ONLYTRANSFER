import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FacturacioScreen extends StatefulWidget {
  final double importTotal;
  final Map<String, dynamic> dadesReserva;

  const FacturacioScreen({
    super.key, 
    required this.importTotal, 
    required this.dadesReserva
  });

  @override
  State<FacturacioScreen> createState() => _FacturacioScreenState();
}

class _FacturacioScreenState extends State<FacturacioScreen> {
  final _nomFiscalController = TextEditingController();
  final _cifController = TextEditingController();
  final _adrecaController = TextEditingController();
  final _cpController = TextEditingController();
  final _poblacioController = TextEditingController();
  final _provinciaController = TextEditingController();

  // FUNCIÓ DE CERCA CORREGIDA
  void _buscarCP(String cp) async {
    if (cp.length == 5) {
      print("Buscant el codi a Firebase: $cp...");
      try {
        final doc = await FirebaseFirestore.instance
            .collection('codis_postals')
            .doc(cp)
            .get();

        if (doc.exists) {
          setState(() {
            _poblacioController.text = doc.data()?['Població'] ?? "";
            _provinciaController.text = doc.data()?['Província'] ?? "";
          });
          print("Dades rebudes de Firebase correctament.");
        } else {
          print("El document $cp no existeix a la col·lecció 'codis_postals'");
        }
      } catch (e) {
        print("Error de connexió amb Firebase: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2D3142), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "DADES DE FACTURACIÓ",
          style: TextStyle(color: Color(0xFF2D3142), letterSpacing: 2, fontSize: 13, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // RESUM DE L'IMPORT
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("TOTAL A PAGAR", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF556677))),
                  Text(
                    "${widget.importTotal.toStringAsFixed(2)} €",
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFFF700A)),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            _buildSectionTitle("INFORMACIÓ FISCAL"),
            _buildTextField(_nomFiscalController, "Nom Fiscal o Empresa", Icons.business_outlined),
            const SizedBox(height: 15),
            _buildTextField(_cifController, "CIF / NIF", Icons.badge_outlined),
            
            const SizedBox(height: 25),
            _buildSectionTitle("ADREÇA DE FACTURACIÓ"),
            _buildTextField(_adrecaController, "Carrer, número, pis...", Icons.home_work_outlined),
            const SizedBox(height: 15),
            
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildTextField(_cpController, "C. Postal", Icons.local_post_office_outlined, isNumber: true),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 3,
                  child: _buildTextField(_poblacioController, "Població", Icons.location_city_outlined),
                ),
              ],
            ),
            const SizedBox(height: 15),
            _buildTextField(_provinciaController, "Província", Icons.map_outlined),
            
            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _processarPagament,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D3142), 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 0,
                ),
                child: const Text(
                  "PAGAR ARA AMB TARGETA",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                "Pagament segur encriptat via Stripe",
                style: TextStyle(color: Color(0xFF778591), fontSize: 12),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

 void _processarPagament() async {
    // 1. Verifiquem que les dades hi siguin
    if (_nomFiscalController.text.isEmpty || 
        _cifController.text.isEmpty || 
        _cpController.text.isEmpty ||
        _poblacioController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Si us plau, completa les dades de facturació'))
      );
      return;
    }

    print("Iniciant procés de pagament i guardat de dades...");

    try {
      // 2. Aquí guardem les dades a la reserva de Firebase abans de pagar
      // Suposem que 'dadesReserva' té l'ID de la reserva que estem gestionant
      String reservaId = widget.dadesReserva['id'] ?? "reserva_temporal";

      await FirebaseFirestore.instance.collection('reserves').doc(reservaId).update({
        'facturacio_nom': _nomFiscalController.text,
        'facturacio_cif': _cifController.text,
        'facturacio_adreca': _adrecaController.text,
        'facturacio_cp': _cpController.text,
        'facturacio_poblacio': _poblacioController.text, // <--- GUARDEM LA POBLACIÓ
        'facturacio_provincia': _provinciaController.text, // <--- GUARDEM LA PROVÍNCIA
        'estat_pagament': 'pendent_stripe'
      });

      print("Dades de facturació guardades a la reserva $reservaId");

      // 3. AQUÍ ÉS ON CRIDAREM A STRIPE (Proper pas)
      // Per ara, simulem que anem bé:
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dades guardades. Connectant amb Stripe...'))
      );

    } catch (e) {
      print("Error guardant dades de facturació: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error en guardar dades: $e'))
      );
    }
  }
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF778591), letterSpacing: 1.5)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      onChanged: (value) {
        if (hint.contains("Postal")) {
          _buscarCP(value);
        }
      },
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFF556677), size: 20),
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }
}
