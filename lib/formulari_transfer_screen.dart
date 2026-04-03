import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FormulariTransferScreen extends StatefulWidget {
  // Hem fet el resum opcional perquè el PIN 0000 pugui entrar directament
  final Map<String, String>? resum;

  const FormulariTransferScreen({super.key, this.resum});

  @override
  State<FormulariTransferScreen> createState() => _FormulariTransferScreenState();
}

class _FormulariTransferScreenState extends State<FormulariTransferScreen> {
  final _origenController = TextEditingController();
  final _destiController = TextEditingController();
  final _volController = TextEditingController();
  final _welcomeSignController = TextEditingController();
  final _passatgersController = TextEditingController();
  final _maletesController = TextEditingController();
  final _observacionsController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  
  String _vehicleSeleccionat = 'Sedan 2 pax';
  final List<String> _vehicles = [
    'Sedan 2 pax',
    'MiniVan 6 pax',
    'Bussines de Luxe 2 pax',
    'SUV Premiun 6 pax'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2D3142)),
        title: const Text(
          'DADES DEL TRANSFER',
          style: TextStyle(color: Color(0xFF2D3142), fontSize: 16, letterSpacing: 2, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("RECOLLIDA I DESTÍ"),
            _buildTextField(_origenController, "Origen (Aeroport, Port...)", Icons.location_on_outlined),
            const SizedBox(height: 15),
            _buildTextField(_destiController, "Destí (Hotel, Adreça...)", Icons.flag_outlined),
            
            const SizedBox(height: 30),
            _buildSectionTitle("DATA I HORA"),
            Row(
              children: [
                Expanded(child: _buildPickerTile(
                  "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}", 
                  Icons.calendar_today, 
                  () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) setState(() => _selectedDate = picked);
                  }
                )),
                const SizedBox(width: 15),
                Expanded(child: _buildPickerTile(
                  _selectedTime.format(context), 
                  Icons.access_time, 
                  () async {
                    TimeOfDay? picked = await showTimePicker(context: context, initialTime: _selectedTime);
                    if (picked != null) setState(() => _selectedTime = picked);
                  }
                )),
              ],
            ),

            const SizedBox(height: 30),
            _buildSectionTitle("TIPUS DE VEHICLE"),
            _buildVehicleDropdown(),

            const SizedBox(height: 30),
            _buildSectionTitle("DETALLS DEL SERVEI"),
            _buildTextField(_volController, "Número de Vol / Tren", Icons.flight_takeoff),
            const SizedBox(height: 15),
            _buildTextField(_welcomeSignController, "Nom al cartell (Welcome Sign)", Icons.badge_outlined),

            const SizedBox(height: 30),
            _buildSectionTitle("CAPACITAT"),
            Row(
              children: [
                Expanded(child: _buildTextField(_passatgersController, "Passatgers", Icons.people_outline, isNumber: true)),
                const SizedBox(width: 15),
                Expanded(child: _buildTextField(_maletesController, "Maletes", Icons.luggage_outlined, isNumber: true)),
              ],
            ),

            const SizedBox(height: 30),
            _buildSectionTitle("OBSERVACIONS"),
            _buildTextField(_observacionsController, "Notes addicionals...", Icons.notes_outlined, maxLines: 3),

            const SizedBox(height: 40),
            _buildBotoSubmit(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- GINYS AUXILIARS ---
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF778591), letterSpacing: 1.5)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool isNumber = false, int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFF556677), size: 20),
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildPickerTile(String text, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 15),
        decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(15)),
        child: Row(children: [Icon(icon, size: 20, color: const Color(0xFFFF700A)), const SizedBox(width: 12), Text(text)]),
      ),
    );
  }

  Widget _buildVehicleDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(15)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _vehicleSeleccionat,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFFFF700A)),
          items: _vehicles.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
          onChanged: (n) => setState(() => _vehicleSeleccionat = n!),
        ),
      ),
    );
  }

  Widget _buildBotoSubmit() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _confirmarReserva,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF700A), 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 0
        ),
        child: const Text("SOL·LICITAR TRANSFER", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _confirmarReserva() async {
    if (_origenController.text.isEmpty || _destiController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Si us plau, omple Origen i Destí')));
      return;
    }
    
    showDialog(
      context: context, 
      barrierDismissible: false, 
      builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFFFF700A)))
    );

    try {
      // UNIFIQUEM A LA COL·LECCIÓ 'viatges'
      await FirebaseFirestore.instance.collection('viatges').add({
        'CLIENT': _welcomeSignController.text.isNotEmpty ? _welcomeSignController.text : "Client VIP",
        'O': _origenController.text,
        'D': _destiController.text,
        'DATA': "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
        'HORA': _selectedTime.format(context),
        'VEHICLE': _vehicleSeleccionat,
        'VOL': _volController.text,
        'SIGN': _welcomeSignController.text,
        'PAX': _passatgersController.text,
        'MALETES': _maletesController.text,
        'NOTES': _observacionsController.text,
        'ESTAT': 'pendent',
        'creat_el': FieldValue.serverTimestamp(),
      });
      
      if (!mounted) return;
      Navigator.pop(context); // Tanquem el cercle de càrrega

      // Tornem a l'inici amb un missatge d'èxit
      Navigator.popUntil(context, (route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Reserva enviada correctament! 🧡"))
      );
      
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}
