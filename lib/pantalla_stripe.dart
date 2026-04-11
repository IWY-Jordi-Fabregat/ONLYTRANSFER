import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Jordi: Hem canviat el nom a PantallaStripe perquè coincideixi amb la crida
class PantallaStripe extends StatefulWidget {
  final double import;
  final String nomClient;
  final String codiReserva;
  final Map<String, dynamic> dadesViatge;

  const PantallaStripe({
    super.key, 
    required this.import, 
    required this.nomClient, 
    required this.codiReserva, 
    required this.dadesViatge
  });

  @override
  State<PantallaStripe> createState() => _PantallaStripeState();
}

class _PantallaStripeState extends State<PantallaStripe> {
  final Color taronja = const Color(0xFFFF700A);
  final Color grisNegre = const Color(0xFF2D3142);

  Future<void> _processarPagament() async {
    try {
      // 1. Simulem l'èxit del pagament (com ahir) per gravar al búnquer
      // Més endavant aquí posarem el PaymentIntent real
      
      await FirebaseFirestore.instance.collection('viatges').add({
        ...widget.dadesViatge,
        'estat_pagament': 'PAGAT', // Confirmem el pagament
        'import_pagat': widget.import,
        'metode': 'STRIPE_CARD',
        'data_pagament': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("PAGAMENT CONFIRMAT I VIATGE REGISTRAT"), 
            backgroundColor: Colors.green
          ),
        );
        // Tornem a la pantalla principal
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("ERROR EN EL REGISTRE: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("PAGAMENT SEGUR", style: TextStyle(fontSize: 16, letterSpacing: 2)),
        backgroundColor: grisNegre,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            const Text("CLIENT", style: TextStyle(fontSize: 10, letterSpacing: 2, color: Colors.grey)),
            Text(widget.nomClient.toUpperCase(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Text("${widget.import.toStringAsFixed(2)} €", 
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: taronja)),
            const SizedBox(height: 10),
            Text("CODI RESERVA: ${widget.codiReserva}", 
                style: TextStyle(color: grisNegre, fontWeight: FontWeight.bold, letterSpacing: 1)),
            const SizedBox(height: 40),
            
            // Formulari de targeta (L'estètica Apple que t'agrada)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(15),
              ),
              child: CardFormField(
                style: CardFormStyle(
                  borderColor: Colors.transparent,
                  textColor: grisNegre,
                  fontSize: 16,
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: grisNegre,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                ),
                onPressed: _processarPagament,
                child: const Text("CONFIRMAR PAGAMENT", 
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
