import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class CliNovaReserva extends StatefulWidget {
  final Function(String codi) onReservaCompletada;
  final VoidCallback onCancel;

  const CliNovaReserva({super.key, required this.onReservaCompletada, required this.onCancel});

  @override
  State<CliNovaReserva> createState() => _CliNovaReservaState();
}

class _CliNovaReservaState extends State<CliNovaReserva> {
  // CONTROLADORS OPERATIUS
  final TextEditingController _origenController = TextEditingController();
  final TextEditingController _destiController = TextEditingController();
  final TextEditingController _volController = TextEditingController();
  final TextEditingController _paxController = TextEditingController(text: '1');
  final TextEditingController _maletesController = TextEditingController(text: '0');
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _mailController = TextEditingController();
  final TextEditingController _observacionsController = TextEditingController();

  // CONTROLADORS FISCALS (Corregit: Adreca sense 'ç')
  final TextEditingController _facturaNomController = TextEditingController();
  final TextEditingController _facturaDniController = TextEditingController();
  final TextEditingController _facturaAdrecaController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 12, minute: 0);
  bool _processant = false;

  final Color colorTaronjaVIP = const Color(0xFFFF700A);
  final Color colorGrisFosc = const Color(0xFF556677);

  Future<void> _crearReserva() async {
    setState(() => _processant = true);
    String codi = List.generate(6, (index) => 'BCDFGHJKLMNPQRSTVWXYZ23456789'[DateTime.now().microsecond % 29]).join();

    await FirebaseFirestore.instance.collection('reserves').add({
      'client': _nomController.text,
      'codi_reserva': codi,
      'email': _mailController.text,
      'origen': _origenController.text,
      'desti': _destiController.text,
      'vol_tren': _volController.text,
      'pax': _paxController.text,
      'maletes': _maletesController.text,
      'observacions': _observacionsController.text,
      'hora': _selectedTime.format(context),
      'data': DateFormat('dd/MM/yyyy').format(_selectedDate),
      'estat_servei': 'pendent',
      
      // Dades Fiscals (Corregit clau a Firebase)
      'factura_nom': _facturaNomController.text,
      'factura_dni': _facturaDniController.text,
      'factura_adreca': _facturaAdrecaController.text,

      // Logs en minúscules
      'log_1': {'fet': false, 'hora': '', 'lat': 0.0, 'lng': 0.0},
      'log_2': {'fet': false, 'hora': '', 'lat': 0.0, 'lng': 0.0},
      'log_3': {'fet': false, 'hora': '', 'lat': 0.0, 'lng': 0.0},
      'log_4': {'fet': false, 'hora': '', 'lat': 0.0, 'lng': 0.0},
      'log_5': {'fet': false, 'hora': '', 'lat': 0.0, 'lng': 0.0},
      'log_6': {'fet': false, 'hora': '', 'lat': 0.0, 'lng': 0.0},
      'creat_el': FieldValue.serverTimestamp(),
    });

    widget.onReservaCompletada(codi);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _titolSeccio("DETALLS DEL VIATGE"),
            _contenidorTargeta([
              _campPredictiu(_origenController, "Origen", Icons.location_on_outlined),
              const SizedBox(height: 15),
              _campPredictiu(_destiController, "Destinació", Icons.flag_outlined),
              const SizedBox(height: 15),
              Row(children: [
                Expanded(child: _botoDataHora(DateFormat('dd/MM/yy').format(_selectedDate), Icons.calendar_today, _triarData)),
                const SizedBox(width: 10),
                Expanded(child: _botoDataHora(_selectedTime.format(context), Icons.access_time, _triarHora)),
              ]),
            ]),

            const SizedBox(height: 25),
            _titolSeccio("PASSATGERS I LOGÍSTICA"),
            _contenidorTargeta([
              _campBlanc(_nomController, "Nom del Passatger", Icons.person_outline),
              const SizedBox(height: 15),
              _campBlanc(_mailController, "Email de confirmació", Icons.alternate_email),
              const SizedBox(height: 15),
              Row(children: [
                Expanded(child: _campBlanc(_paxController, "Persones", Icons.people_outline)),
                const SizedBox(width: 10),
                Expanded(child: _campBlanc(_maletesController, "Maletes", Icons.luggage_outlined)),
              ]),
              const SizedBox(height: 15),
              _campBlanc(_volController, "Núm. Vol / Tren", Icons.flight_takeoff),
              const SizedBox(height: 15),
              _campBlanc(_observacionsController, "Observacions VIP", Icons.edit_note),
            ]),

            const SizedBox(height: 25),
            _titolSeccio("DADES DE FACTURACIÓ"),
            _contenidorTargeta([
              _campBlanc(_facturaNomController, "Empresa o Nom Fiscal", Icons.business),
              const SizedBox(height: 15),
              _campBlanc(_facturaDniController, "CIF / DNI", Icons.badge_outlined),
              const SizedBox(height: 15),
              // Aquí en el text (Adreça) sí que podem posar la 'ç' perquè és una cadena de text
              _campBlanc(_facturaAdrecaController, "Adreça Fiscal Completa", Icons.map_outlined),
            ]),

            const SizedBox(height: 40),
            _processant 
              ? const CircularProgressIndicator() 
              : _botoAccio("CONFIRMAR I PAGAR", _crearReserva),
            const SizedBox(height: 15),
            TextButton(onPressed: widget.onCancel, child: const Text("Tornar enrere", style: TextStyle(color: Colors.grey))),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS D'ESTIL ONLYTRANSFER ---

  Widget _titolSeccio(String t) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, bottom: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(t, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: colorGrisFosc, letterSpacing: 1.2)),
      ),
    );
  }

  Widget _contenidorTargeta(List<Widget> fills) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(children: fills),
    );
  }

  Widget _campPredictiu(TextEditingController ctrl, String hint, IconData icon) {
    return TypeAheadField<String>(
      suggestionsCallback: (p) async {
        if (p.length < 3) return [];
        const String k = "AIzaSyA3yvNuaRTFJgRcRK0m5eu8_1cMquTRKrM";
        final u = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$p&key=$k&language=en";
        final r = await http.get(Uri.parse(u));
        if (r.statusCode == 200) {
          final d = json.decode(r.body);
          return (d['predictions'] as List).map((i) => i['description'] as String).toList();
        }
        return [];
      },
      onSelected: (s) => setState(() => ctrl.text = s),
      itemBuilder: (c, s) => ListTile(title: Text(s, style: const TextStyle(fontSize: 12))),
      builder: (c, ct, f) {
        if (ct.text != ctrl.text) ct.text = ctrl.text;
        return TextField(controller: ct, focusNode: f, style: const TextStyle(fontSize: 14), decoration: _estil(hint, icon));
      },
    );
  }

  Widget _campBlanc(TextEditingController ctrl, String hint, IconData icon) {
    return TextField(controller: ctrl, style: const TextStyle(fontSize: 14), decoration: _estil(hint, icon));
  }

  InputDecoration _estil(String hint, IconData icon) {
    return InputDecoration(
      filled: true, 
      fillColor: const Color(0xFFF9FAFB), 
      prefixIcon: Icon(icon, size: 18, color: colorTaronjaVIP), 
      hintText: hint, 
      hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
      contentPadding: const EdgeInsets.symmetric(vertical: 15),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)
    );
  }

  Widget _botoDataHora(String text, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap, 
      child: Container(
        padding: const EdgeInsets.all(15), 
        decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(12)), 
        child: Row(children: [Icon(icon, size: 16, color: colorTaronjaVIP), const SizedBox(width: 8), Text(text, style: const TextStyle(fontSize: 13))])
      )
    );
  }

  Widget _botoAccio(String text, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity, 
      height: 60, 
      child: ElevatedButton(
        onPressed: onTap, 
        style: ElevatedButton.styleFrom(backgroundColor: colorTaronjaVIP, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), elevation: 0), 
        child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))
      )
    );
  }

  void _triarData() async { DateTime? p = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime.now(), lastDate: DateTime(2030)); if (p != null) setState(() => _selectedDate = p); }
  void _triarHora() async { TimeOfDay? p = await showTimePicker(context: context, initialTime: _selectedTime); if (p != null) setState(() => _selectedTime = p); }
}
