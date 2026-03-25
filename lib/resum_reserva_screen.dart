import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'transfer_screen.dart';
import 'geocoding_helper.dart'; 
import 'espera_vip_screen.dart'; 

class ResumReservaScreen extends StatefulWidget {
  final Map<String, dynamic>? dades; 
  
  const ResumReservaScreen({super.key, this.dades});

  @override
  State<ResumReservaScreen> createState() => _ResumReservaScreenState();
}

class _ResumReservaScreenState extends State<ResumReservaScreen> {
  String _poblacio = "";
  String _provincia = "";
  bool _buscant = false;

  late TextEditingController _nomController;
  late TextEditingController _emailController;
  final _adrecaController = TextEditingController();
  final _cpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.dades?['nom'] ?? "");
    _emailController = TextEditingController(text: widget.dades?['email'] ?? "");
  }

  Future<void> _buscarCP(String cp) async {
    if (cp.length == 5) {
      setState(() => _buscant = true);
      final dades = await GeocodingHelper.buscarLocalitzacio(cp);
      setState(() {
        _poblacio = dades['poblacio']!;
        _provincia = dades['provincia']!;
        _buscant = false;
      });
    }
  }

  Future<void> _guardarReserva() async {
    // Verificació metòdica de dades
    if (_nomController.text.isEmpty || _cpController.text.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Dades incompletes per a la reserva")),
      );
      return;
    }

    // Mostrem l'indicador de càrrega (pau visual per al client)
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFFFF700A))),
    );

    try {
      // 1. CREEM EL PAQUET DE DADES (Diferenciant nom del client i welcome sign)
      final dadesFinals = {
        'nom_client': _nomController.text, // El nom real de la persona
        'welcome_sign': _nomController.text, // El que veurà el xòfer (per defecte el mateix)
        'email': _emailController.text,
        'adreca_recollida': _adrecaController.text,
        'cp': _cpController.text,
        'poblacio': _poblacio,
        'provincia': _provincia,
        'vol_tren': widget.dades?['vol_tren'] ?? "---",
        'desti': widget.dades?['desti'] ?? "---",
        'hora': widget.dades?['hora'] ?? "---",
        'estat': 'PENDENT',
        'creat_el': FieldValue.serverTimestamp(),
      };

      // 2. ENVIEM A FIREBASE
      await FirebaseFirestore.instance.collection('reserves').add(dadesFinals);

      if (!mounted) return;
      Navigator.pop(context); // Tanquem el diàleg de càrrega

      // Missatge de confirmació d'èxit
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ RESERVA REGISTRADA I ENVIADA AL XÒFER"),
          backgroundColor: Color(0xFF2D3142),
        ),
      );

      // 3. SALT A LA PANTALLA D'ESPERA
      // Fem servir pushAndRemoveUntil per tancar el cercle i que no torni enrere
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => EsperaVipScreen(dades: dadesFinals)
          ),
          (route) => false,
        );
      });

    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Tanquem el diàleg de càrrega
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
        title: const Text("RESUM DE LA RESERVA",
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
              title: "IDENTIFICACIÓ CLIENT",
              child: Column(
                children: [
                  _buildTextField(_nomController, "Nom o Empresa", Icons.business_outlined),
                  const SizedBox(height: 15),
                  _buildTextField(_emailController, "Correu de contacte", Icons.alternate_email),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildCard(
              title: "PUNT DE RECOLLIDA",
              child: Column(
                children: [
                  _buildTextField(_adrecaController, "Adreça completa", Icons.location_on_outlined),
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
            _buildBotoConfirmar(),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
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

  Widget _buildBotoConfirmar() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _guardarReserva,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2D3142),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: const Text("CONFIRMAR RESERVA VIP",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
      ),
    );
  }
}
