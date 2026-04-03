import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PagamentStripe extends StatefulWidget {
  final String viatgeId;
  final double importViatge;
  final String clientNom;

  const PagamentStripe({
    super.key, 
    required this.viatgeId, 
    required this.importViatge,
    required this.clientNom
  });

  @override
  State<PagamentStripe> createState() => _PagamentStripeState();
}

class _PagamentStripeState extends State<PagamentStripe> {
  // Colors corporatius Jordi
  final Color taronja = const Color(0xFFFF700A);
  final Color grisNegre = const Color(0xFF2D3142);

  @override
  void initState() {
    super.initState();
    // CONFIGURACIÓ INICIAL: Aquí posaràs la teva clau pública de Stripe
    Stripe.publishableKey = "LA_TEVA_CLAU_PK_AQUI"; 
  }

  Future<void> _processarPagament() async {
    try {
      // 1. Aquí aniria la crida al teu servidor per crear el 'PaymentIntent'
      // Per ara, simularem l'èxit per tancar el cercle del flux
      
      await FirebaseFirestore.instance.collection('viatges').doc(widget.viatgeId).update({
        'ESTAT_PAGAMENT': 'PAGAT',
        'METODE_DETALL': 'STRIPE_CARD'
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("PAGAMENT CONFIRMAT CORRECTAMENT"), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("ERROR EN EL PAGAMENT: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PAGAMENT SEGUR STRIPE"),
        backgroundColor: Colors.white,
        foregroundColor: grisNegre,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            Text(widget.clientNom, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("${widget.importViatge} €", style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: taronja)),
            const SizedBox(height: 40),
            
            // Formulari de targeta de Stripe
            CardFormField(
              style: CardFormStyle(
                borderColor: Colors.grey,
                textColor: grisNegre,
                placeholderColor: Colors.grey,
              ),
            ),
            
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: grisNegre),
                onPressed: _processarPagament,
                child: const Text("PAGAR ARA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
