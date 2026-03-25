import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'transfer_screen.dart';
import 'geocoding_helper.dart'; // <--- 1. IMPORTEM EL TEU NOU HELPER
import 'main_selector.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String _poblacio = "";
  String _provincia = "";
  bool _buscant = false;

  final _nomController = TextEditingController();
  final _emailController = TextEditingController();
  final _adrecaController = TextEditingController();
  final _cpController = TextEditingController();

  // --- LA MÀGIA UNIFICADA ESTÀ AQUÍ ---
  Future<void> _buscarCP(String cp) async {
    if (cp.length == 5) {
      setState(() => _buscant = true);
      
      // Fem servir el cervell centralitzat que hem creat abans
      final dades = await GeocodingHelper.buscarLocalitzacio(cp);
      
      setState(() {
        _poblacio = dades['poblacio']!;
        _provincia = dades['provincia']!;
        _buscant = false;
      });
    }
  }

Future<void> _guardarPerfil() async {
    if (_nomController.text.isEmpty || _emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Si us plau, ompli el nom i l'email")),
      );
      return;
    }

    // Iniciem el procés visual
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFFFF700A))),
    );

    try {
      // --- PAS 1: FILTRE INTEL·LIGENT (No duplicar) ---
      final queryEmail = await FirebaseFirestore.instance
          .collection('clients')
          .where('email', isEqualTo: _emailController.text.trim())
          .get();

      if (queryEmail.docs.isNotEmpty) {
        // El client ja existeix! No guardem res, simplement passem a la següent pantalla
        if (!mounted) return;
        Navigator.pop(context); // Tanquem el cercle de càrrega
        
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (context) => MainSelectorScreen())
        );
        return;
      }

      // --- PAS 2: SI ÉS NOU, EL GUARDEM ---
      await FirebaseFirestore.instance.collection('clients').add({
        'nom': _nomController.text,
        'email': _emailController.text.trim(),
        'adreca': _adrecaController.text,
        'cp': _cpController.text,
        'poblacio': _poblacio,
        'provincia': _provincia,
        'creat_el': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ BENVINGUT A ONLYTRANSFER"),
          backgroundColor: Color(0xFF2D3142),
          duration: Duration(seconds: 2),
        ),
      );

      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (context) => MainSelectorScreen())
        );
      });

    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("EL SEU PERFIL",
            style: TextStyle(letterSpacing: 2, fontSize: 14, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF2D3142),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            _buildCard(
              title: "DADES PERSONALS",
              child: Column(
                children: [
                  _buildTextField(_nomController, "Nom complet", Icons.person_outline),
                  const SizedBox(height: 15),
                  _buildTextField(_emailController, "Email", Icons.email_outlined),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildCard(
              title: "ADREÇA DE RESIDÈNCIA",
              child: Column(
                children: [
                  _buildTextField(_adrecaController, "Carrer, número, pis", Icons.home_outlined),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _cpController,
                    keyboardType: TextInputType.number,
                    onChanged: (val) => _buscarCP(val),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.map_outlined, color: Color(0xFF556677), size: 20),
                      hintText: "Codi Postal",
                      suffixIcon: _buscant
                          ? const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFF700A)),
                            )
                          : null,
                      filled: true,
                      fillColor: const Color(0xFFF8F9FA),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(child: _buildInfoField("Població", _poblacio)),
                      const SizedBox(width: 15),
                      Expanded(child: _buildInfoField("Província", _provincia)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            _buildBotoGuardar(),
          ],
        ),
      ),
    );
  }

  // --- GINYS DE DISSENY (MANTENIM ELS TEUS) ---
  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF778591).withOpacity(0.2), width: 1),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFFF700A), letterSpacing: 1.2)),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoField(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: const Color(0xFFF1F3F5), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 9, color: Color(0xFF778591))),
          const SizedBox(height: 4),
          Text(value.isEmpty ? "---" : value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF2D3142))),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFF556677), size: 20),
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildBotoGuardar() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _guardarPerfil,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2D3142),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 0,
        ),
        child: const Text("GUARDAR I CONTINUAR",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
      ),
    );
  }
}
