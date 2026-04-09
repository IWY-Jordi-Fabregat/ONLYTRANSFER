import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_stripe/flutter_stripe.dart'; // 1. Importem Stripe

// --- ESTÈTICA ONLYTRANSFER ---
const Color colorFonsBlanc = Colors.white;
const Color colorGrisClar = Color(0xFFF0F2F5); 
const Color colorTaronjaVIP = Color(0xFFFF700A);
const Color colorGrisFosc = Color(0xFF556677);
const Color colorGrisNegre = Color(0xFF2D3142);
const Color colorTextSecundari = Color(0xFF778591);

class ExperienciaClient extends StatefulWidget {
  const ExperienciaClient({super.key});
  @override
  State<ExperienciaClient> createState() => _ExperienciaClientState();
}

class _ExperienciaClientState extends State<ExperienciaClient> {
  int _pasActual = 0; 
  
  // Controladors de dades de reserva
  final TextEditingController _origenController = TextEditingController();
  final TextEditingController _destiController = TextEditingController();
  final TextEditingController _volController = TextEditingController();
  final TextEditingController _paxController = TextEditingController(text: '1');
  final TextEditingController _maletesController = TextEditingController(text: '0');
  final TextEditingController _obsController = TextEditingController();
  
  // Controladors de dades de factura
  final TextEditingController _nomClientController = TextEditingController();
  final TextEditingController _dniClientController = TextEditingController();
  final TextEditingController _mailClientController = TextEditingController();
  final TextEditingController _telClientController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 12, minute: 0);

  // --- FUNCIÓ MÀGICA DE PAGAMENT (STRIPE) ---
  Future<void> _processarPagamentIReserva() async {
    try {
      // 1. Càlcul de l'import (1€ per a la prova d'avui)
      // En el futur aquí posarem l'import real (125 o 185)
      String importCentims = "100"; // 100 cèntims = 1,00 €

      // 2. Truquem a l'API de Stripe per crear el tiquet
      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer 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',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': importCentims,
          'currency': 'eur',
          'description': 'Reserva OnlyTransfer: ${_nomClientController.text}',
        },
      );

      final jsonResponse = json.decode(response.body);
      final clientSecret = jsonResponse['client_secret'];

      // 3. Inicialitzem la finestra de pagament de luxe
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'OnlyTransfer',
          style: ThemeMode.light,
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(primary: colorTaronjaVIP),
          ),
        ),
      );

      // 4. Mostrem la finestra al client
      await Stripe.instance.presentPaymentSheet();

      // 5. SI EL PAGAMENT ÉS OK, GRAVEM A FIREBASE
      _gravarReservaAFirebase();

    } catch (e) {
      print("Error en el procés: $e");
      // Si l'usuari cancel·la el pagament, no fem res i es queda a la pantalla
    }
  }

  void _gravarReservaAFirebase() {
    int numPax = int.tryParse(_paxController.text) ?? 0;
    int numMaletes = int.tryParse(_maletesController.text) ?? 0;
    
    final dadesReserva = {
      'client': _nomClientController.text,
      'dni': _dniClientController.text,
      'email': _mailClientController.text,
      'telefon': _telClientController.text,
      'data': DateFormat('dd/MM/yyyy').format(_selectedDate),
      'hora': _selectedTime.format(context),
      'origen': _origenController.text,
      'desti': _destiController.text,
      'pax': numPax.toString(),
      'maletes': numMaletes.toString(),
      'vol_tren': _volController.text,
      'observacions': _obsController.text,
      'vehicle_tipus': (numPax >= 3 || numMaletes >= 3) ? "VAN Executive" : "Sedan Luxe",
      'import': (numPax >= 3 || numMaletes >= 3) ? "185.00" : "125.00",
      'estat_pagament': 'COBRAT (1€ Prova)',
      'estat_servei': 'pendent_assignar',
      'UID_xofer': '',
      'V_MATRICULA': '',
      'creat_el': FieldValue.serverTimestamp(),
    };

    FirebaseFirestore.instance.collection('reserves').add(dadesReserva).then((value) {
      setState(() => _pasActual = 4); // Anem a la pantalla de gràcies
    }).catchError((error) => print("🚨 Error Firebase: $error"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorFonsBlanc,
      appBar: AppBar(
        title: const Text('ONLY TRANSFER', style: TextStyle(color: colorGrisNegre, letterSpacing: 2, fontSize: 14, fontWeight: FontWeight.bold)),
        backgroundColor: colorFonsBlanc,
        elevation: 0,
        centerTitle: true,
        leading: _pasActual > 0 && _pasActual < 4 ? IconButton(icon: const Icon(Icons.arrow_back_ios, size: 18), onPressed: () => setState(() => _pasActual--)) : null,
      ),
      body: _construirPasActual(),
    );
  }

  Widget _construirPasActual() {
    switch (_pasActual) {
      case 0: return _pantallaSeleccio();
      case 1: return _pantallaDetalls();
      case 2: return _pantallaResum();
      case 3: return _pantallaIdentificacio();
      case 4: return _pantallaGracies();
      default: return _pantallaSeleccio();
    }
  }

  // --- PANTALLES ---

  Widget _pantallaSeleccio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.airplanemode_active, color: colorTaronjaVIP, size: 40),
          const Text("TRANSFER", style: TextStyle(fontSize: 10, color: colorTaronjaVIP)),
          const SizedBox(height: 60),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: _botoAccio("NOVA RESERVA", () => setState(() => _pasActual = 1)),
          ),
        ],
      ),
    );
  }

  Widget _pantallaDetalls() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        children: [
          _campPredictiu(_origenController, "Recollida (Aeroport, Hotel...)", Icons.location_on_outlined),
          const SizedBox(height: 15),
          _campPredictiu(_destiController, "Destinació", Icons.flag_outlined),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(child: _botoGris(DateFormat('dd/MM/yy').format(_selectedDate), Icons.calendar_today, _triarData)),
              const SizedBox(width: 10),
              Expanded(child: _botoGris(_selectedTime.format(context), Icons.access_time, _triarHora)),
            ],
          ),
          const SizedBox(height: 15),
          _campBlanc(_volController, "Número de Vol", Icons.flight_takeoff),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(child: _campBlanc(_paxController, "Pax", Icons.people_outline, esNumber: true)),
              const SizedBox(width: 10),
              Expanded(child: _campBlanc(_maletesController, "Maletes", Icons.luggage_outlined, esNumber: true)),
            ],
          ),
          const SizedBox(height: 15),
          _campBlanc(_obsController, "Observacions (Opcional)", Icons.chat_bubble_outline),
          const SizedBox(height: 30),
          _botoAccio("CONTINUAR", () => setState(() => _pasActual = 2)),
        ],
      ),
    );
  }

  Widget _pantallaResum() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("RESUM DE LA RESERVA", style: TextStyle(color: colorTaronjaVIP, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: colorGrisClar, borderRadius: BorderRadius.circular(15)),
            child: Column(
              children: [
                _filaResum(Icons.location_on_outlined, "Origen", _origenController.text),
                const Divider(height: 30),
                _filaResum(Icons.flag_outlined, "Destí", _destiController.text),
                const Divider(height: 30),
                _filaResum(Icons.calendar_today, "Data i Hora", "${DateFormat('dd/MM/yy').format(_selectedDate)} - ${_selectedTime.format(context)}"),
                const Divider(height: 30),
                _filaResum(Icons.people_outline, "Pax / Maletes", "${_paxController.text} Pax / ${_maletesController.text} Maletes"),
              ],
            ),
          ),
          const SizedBox(height: 30),
          _botoAccio("CONFIRMAR I IDENTIFICAR-ME", () => setState(() => _pasActual = 3)),
        ],
      ),
    );
  }

  Widget _pantallaIdentificacio() {
    int numPax = int.tryParse(_paxController.text) ?? 0;
    int numMaletes = int.tryParse(_maletesController.text) ?? 0;
    String preuFinal = (numPax >= 3 || numMaletes >= 3) ? "185,00 €" : "125,00 €";

    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("DADES DE FACTURACIÓ", style: TextStyle(color: colorTaronjaVIP, fontWeight: FontWeight.bold, fontSize: 11)),
          const SizedBox(height: 20),
          _campBlanc(_nomClientController, "Nom Complet o Empresa", Icons.person_outline),
          const SizedBox(height: 10),
          _campBlanc(_dniClientController, "DNI / NIE / CIF", Icons.badge_outlined),
          const SizedBox(height: 10),
          _campBlanc(_mailClientController, "Correu Electrònic", Icons.alternate_email),
          const SizedBox(height: 10),
          _campBlanc(_telClientController, "Telèfon de contacte", Icons.phone_android_outlined, esNumber: true),
          const SizedBox(height: 30),
          const Text("PAGAMENT SEGUR", style: TextStyle(color: colorTaronjaVIP, fontWeight: FontWeight.bold, fontSize: 11)),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: colorGrisNegre, borderRadius: BorderRadius.circular(15)),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("IMPORT A PAGAR", style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text(preuFinal, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 20),
                _botoTaronjaStripe("PAGAR ARA AMB TARGETA", _processarPagamentIReserva),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pantallaGracies() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, color: colorTaronjaVIP, size: 80),
            const SizedBox(height: 20),
            const Text("PAGAMENT COMPLETAT", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorGrisNegre)),
            const SizedBox(height: 10),
            const Text(
              "Gràcies Jordi. La teva reserva ja està a l'oficina.\nRebràs un correu amb la confirmació.",
              textAlign: TextAlign.center,
              style: TextStyle(color: colorGrisFosc, height: 1.5),
            ),
            const SizedBox(height: 40),
            _botoGris("TORNAR A L'INICI", Icons.home, () => setState(() => _pasActual = 0)),
          ],
        ),
      ),
    );
  }

  // --- COMPONENTS NETS ---

  Widget _botoTaronjaStripe(String text, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.lock_outline, color: Colors.white, size: 18),
        label: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: colorTaronjaVIP,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _campPredictiu(TextEditingController ctrl, String hint, IconData icon) {
    return TypeAheadField<String>(
      suggestionsCallback: (pattern) async {
        if (pattern.length < 3) return [];
        const String apiKey = "AIzaSyA3yvNuaRTFJgRcRK0m5eu8_1cMquTRKrM";
        final url = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$pattern&key=$apiKey&types=establishment|geocode&language=en";
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['status'] == 'OK') {
            return (data['predictions'] as List).map((p) => p['description'] as String).toList();
          }
        }
        return [];
      },
      onSelected: (suggestion) {
        setState(() { 
          ctrl.text = suggestion;
        });
      },
      itemBuilder: (context, String suggestion) => ListTile(title: Text(suggestion, style: const TextStyle(fontSize: 13))),
      builder: (context, controller, focusNode) {
        if (controller.text != ctrl.text) controller.text = ctrl.text;
        return TextField(controller: controller, focusNode: focusNode, decoration: _estilInput(hint, icon));
      },
    );
  }

  Widget _campBlanc(TextEditingController ctrl, String hint, IconData icon, {bool esNumber = false}) {
    return TextField(controller: ctrl, keyboardType: esNumber ? TextInputType.number : TextInputType.text, decoration: _estilInput(hint, icon));
  }

  InputDecoration _estilInput(String hint, IconData icon) {
    return InputDecoration(
      filled: true, fillColor: colorGrisClar,
      prefixIcon: Icon(icon, color: colorGrisFosc, size: 18),
      hintText: hint, hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    );
  }

  Widget _filaResum(IconData icon, String titol, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colorGrisFosc),
          const SizedBox(width: 15),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(titol.toUpperCase(), style: const TextStyle(fontSize: 9, color: colorTextSecundari, fontWeight: FontWeight.bold)),
            Text(valor, style: const TextStyle(fontSize: 13, color: colorGrisNegre, fontWeight: FontWeight.w500)),
          ])),
        ],
      ),
    );
  }

  Widget _botoGris(String text, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: colorGrisClar, borderRadius: BorderRadius.circular(12)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 16, color: colorGrisFosc), const SizedBox(width: 8), Text(text, style: const TextStyle(fontSize: 12))]),
      ),
    );
  }

  Widget _botoAccio(String text, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity, height: 50,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(backgroundColor: colorTaronjaVIP, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
        child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _triarData() async {
    DateTime? p = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime.now(), lastDate: DateTime(2030));
    if (p != null) setState(() => _selectedDate = p);
  }

  void _triarHora() async {
    TimeOfDay? p = await showTimePicker(context: context, initialTime: _selectedTime);
    if (p != null) setState(() => _selectedTime = p);
  }
}
