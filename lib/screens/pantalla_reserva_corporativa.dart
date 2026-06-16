import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../services/reserva_service.dart';

// --- COLORS CORPORATIUS ONLYTRANSFER ---
const Color colorFonsBlanc = Colors.white;
const Color colorTaronjaVIP = Color(0xFFFF700A);
const Color colorGrisClar = Color(0xFF778591);
const Color colorGrisFosc = Color(0xFF556677);
const Color colorGrisNegre = Color(0xFF2D3142);
const Color colorGrisClarBackground = Color(0xFFF0F2F5);

class PantallaReservaCorporativa extends StatefulWidget {
  const PantallaReservaCorporativa({super.key});

  @override
  State<PantallaReservaCorporativa> createState() =>
      _PantallaReservaCorporativaState();
}

class _PantallaReservaCorporativaState
    extends State<PantallaReservaCorporativa> {
  int _pasActual = 0;
  bool _processant = false;

  // --- SERVEI ---
  final TextEditingController _origenController = TextEditingController();
  final TextEditingController _destiController = TextEditingController();
  final TextEditingController _volController = TextEditingController();
  final TextEditingController _paxController = TextEditingController(text: '1');
  final TextEditingController _maletesController =
      TextEditingController(text: '0');
  final TextEditingController _obsController = TextEditingController();
  final TextEditingController _welcomeSignController = TextEditingController();

  // --- CONTACTE / EMPRESA ---
  final TextEditingController _nomClientController = TextEditingController();
  final TextEditingController _mailClientController = TextEditingController();
  final TextEditingController _telClientController = TextEditingController();

  final TextEditingController _nomEmpresaController = TextEditingController();
  final TextEditingController _personaContacteController =
      TextEditingController();
  final TextEditingController _emailEmpresaController =
      TextEditingController();
  final TextEditingController _telefonEmpresaController =
      TextEditingController();
  final TextEditingController _referenciaInternaController =
      TextEditingController();
  final TextEditingController _obsFacturacioController =
      TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 12, minute: 0);

  String _generarCodiReservaNetejat() {
    const String alfabetNet = 'BCDFGHJKLMNPQRSTVWXYZ23456789';
    return List.generate(
      6,
      (index) => alfabetNet[Random().nextInt(alfabetNet.length)],
    ).join();
  }

  Future<void> _crearReservaCorporativa() async {
    if (_nomEmpresaController.text.trim().isEmpty ||
        _personaContacteController.text.trim().isEmpty ||
        _emailEmpresaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Omple com a mínim empresa, persona de contacte i correu",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _processant = true);

    try {
      await _gravarReservaAFirebase();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _processant = false);
      }
    }
  }

  Future<void> _gravarReservaAFirebase() async {
    final int numPax = int.tryParse(_paxController.text) ?? 1;
    final int numMaletes = int.tryParse(_maletesController.text) ?? 0;
    final String codiUnic = _generarCodiReservaNetejat();

    final String mailClient = _mailClientController.text.trim();
    final String nomClient = _nomClientController.text.trim().isEmpty
        ? _personaContacteController.text.trim()
        : _nomClientController.text.trim();
    final String vol = _volController.text.trim().isEmpty
        ? "No indicat"
        : _volController.text.trim();
    final String sign = _welcomeSignController.text.trim().isEmpty
        ? nomClient
        : _welcomeSignController.text.trim();

    final DateTime dataServei = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final Map<String, dynamic> dadesReserva = {
      // IDENTITAT DEL SERVEI
      'codi_reserva': codiUnic,
      'tipus_client': 'corporatiu',
      'tipus_pagament': 'empresa',
      'estat_pagament': 'PENDENT_TRANSFERENCIA',
      'estat_servei': 'pendent_assignar',

      // CONTACTE DEL PASSATGER / CLIENT FINAL
      'client': nomClient,
      'email': mailClient,
      'telefon': _telClientController.text.trim(),
      'welcome_sign': sign,

      // EMPRESA
      'nom_empresa': _nomEmpresaController.text.trim(),
      'persona_contacte': _personaContacteController.text.trim(),
      'email_empresa': _emailEmpresaController.text.trim(),
      'telefon_empresa': _telefonEmpresaController.text.trim(),
      'referencia_empresa': _referenciaInternaController.text.trim(),
      'observacions_facturacio': _obsFacturacioController.text.trim(),

      // SERVEI
      'data': DateFormat('dd/MM/yyyy').format(_selectedDate),
      'hora': _selectedTime.format(context),
      'data_servei_ts': Timestamp.fromDate(dataServei),
      'origen': _origenController.text.trim(),
      'desti': _destiController.text.trim(),
      'ciutat': 'Barcelona',
      'pax': numPax.toString(),
      'maletes': numMaletes.toString(),
      'vol_tren': vol,
      'observacions': _obsController.text.trim(),
      'vehicle_tipus':
          (numPax >= 3 || numMaletes >= 3) ? "VAN Executive" : "Sedan Luxe",
      'import':
          (numPax >= 3 || numMaletes >= 3) ? "185.00" : "125.00",

      // OPERATIVA
      'conductor_id': '',
      'pagat_conductor': false,
      'data_pagament_conductor': null,
      'creat_el': FieldValue.serverTimestamp(),

      // LOGÍSTICA
      'log_1': {'fet': false, 'hora': '', 'lat': 0.0, 'lng': 0.0},
      'log_2': {'fet': false, 'hora': '', 'lat': 0.0, 'lng': 0.0},
      'log_3': {'fet': false, 'hora': '', 'lat': 0.0, 'lng': 0.0},
      'log_4': {'fet': false, 'hora': '', 'lat': 0.0, 'lng': 0.0},
      'log_5': {'fet': false, 'hora': '', 'lat': 0.0, 'lng': 0.0},
      'log_6': {'fet': false, 'hora': '', 'lat': 0.0, 'lng': 0.0},
    };

    await ReservaService.gravarReserva(dadesReserva: dadesReserva);

    if (!mounted) return;
    setState(() => _pasActual = 4);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorFonsBlanc,
      appBar: AppBar(
        title: const Text(
          'RESERVA CORPORATIVA',
          style: TextStyle(
            color: colorGrisNegre,
            letterSpacing: 2,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colorFonsBlanc,
        elevation: 0,
        centerTitle: true,
        leading: _pasActual > 0 && _pasActual < 4
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 18),
                onPressed: () => setState(() => _pasActual--),
              )
            : null,
      ),
      body: _construirPasActual(),
    );
  }

  Widget _construirPasActual() {
    switch (_pasActual) {
      case 0:
        return _pantallaSeleccio();
      case 1:
        return _pantallaDetalls();
      case 2:
        return _pantallaResum();
      case 3:
        return _pantallaIdentificacioEmpresa();
      case 4:
        return _pantallaGracies();
      default:
        return _pantallaSeleccio();
    }
  }

  Widget _pantallaSeleccio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.business, color: colorTaronjaVIP, size: 40),
          const Text(
            "CORPORATIU",
            style: TextStyle(fontSize: 10, color: colorTaronjaVIP),
          ),
          const SizedBox(height: 60),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: _botoAccio(
              "NOVA RESERVA CORPORATIVA",
              () => setState(() => _pasActual = 1),
            ),
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
          _campPredictiu(
            _origenController,
            "Recollida",
            Icons.location_on_outlined,
          ),
          const SizedBox(height: 15),
          _campPredictiu(
            _destiController,
            "Destinació",
            Icons.flag_outlined,
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _botoGris(
                  DateFormat('dd/MM/yy').format(_selectedDate),
                  Icons.calendar_today,
                  _triarData,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _botoGris(
                  _selectedTime.format(context),
                  Icons.access_time,
                  _triarHora,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          _campBlanc(
            _volController,
            "Número de Vol / Tren",
            Icons.flight_takeoff,
          ),
          const SizedBox(height: 15),
          _campBlanc(
            _welcomeSignController,
            "Cartell de benvinguda",
            Icons.assignment_ind_outlined,
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _campBlanc(
                  _paxController,
                  "Pax",
                  Icons.people_outline,
                  esNumber: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _campBlanc(
                  _maletesController,
                  "Maletes",
                  Icons.luggage_outlined,
                  esNumber: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          _campBlanc(
            _obsController,
            "Observacions operatives",
            Icons.chat_bubble_outline,
          ),
          const SizedBox(height: 30),
          _botoAccio(
            "CONTINUAR",
            () => setState(() => _pasActual = 2),
          ),
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
          const Text(
            "RESUM DE LA RESERVA",
            style: TextStyle(
              color: colorTaronjaVIP,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorGrisClarBackground,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                _filaResum(
                  Icons.location_on_outlined,
                  "Origen",
                  _origenController.text,
                ),
                const Divider(height: 30),
                _filaResum(
                  Icons.flag_outlined,
                  "Destí",
                  _destiController.text,
                ),
                const Divider(height: 30),
                _filaResum(
                  Icons.calendar_today,
                  "Data i Hora",
                  "${DateFormat('dd/MM/yy').format(_selectedDate)} - ${_selectedTime.format(context)}",
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          _botoAccio(
            "CONTINUAR",
            () => setState(() => _pasActual = 3),
          ),
        ],
      ),
    );
  }

  Widget _pantallaIdentificacioEmpresa() {
    final int numPax = int.tryParse(_paxController.text) ?? 1;
    final int numMaletes = int.tryParse(_maletesController.text) ?? 0;
    final String preuFinal =
        (numPax >= 3 || numMaletes >= 3) ? "185,00 €" : "125,00 €";

    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "DADES EMPRESA",
            style: TextStyle(
              color: colorTaronjaVIP,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 20),
          _campBlanc(
            _nomEmpresaController,
            "Nom empresa",
            Icons.business_outlined,
          ),
          const SizedBox(height: 10),
          _campBlanc(
            _personaContacteController,
            "Persona de contacte",
            Icons.person_outline,
          ),
          const SizedBox(height: 10),
          _campBlanc(
            _emailEmpresaController,
            "Correu empresa",
            Icons.alternate_email,
          ),
          const SizedBox(height: 10),
          _campBlanc(
            _telefonEmpresaController,
            "Telèfon empresa",
            Icons.phone_outlined,
          ),
          const SizedBox(height: 10),
          _campBlanc(
            _referenciaInternaController,
            "Referència empresa",
            Icons.badge_outlined,
          ),
          const SizedBox(height: 10),
          _campBlanc(
            _obsFacturacioController,
            "Observacions facturació",
            Icons.receipt_long_outlined,
          ),
          const SizedBox(height: 30),
          const Text(
            "DADES PASSATGER",
            style: TextStyle(
              color: colorTaronjaVIP,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 15),
          _campBlanc(
            _nomClientController,
            "Nom passatger / client final",
            Icons.person_pin_outlined,
          ),
          const SizedBox(height: 10),
          _campBlanc(
            _mailClientController,
            "Correu passatger",
            Icons.mail_outline,
          ),
          const SizedBox(height: 10),
          _campBlanc(
            _telClientController,
            "Telèfon passatger",
            Icons.phone_android_outlined,
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorGrisNegre,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "IMPORT ESTIMAT",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    Text(
                      preuFinal,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  "Pagament per transferència / acord empresa",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 20),
                _processant
                    ? const CircularProgressIndicator(color: colorTaronjaVIP)
                    : _botoAccio(
                        "SOL·LICITAR SERVEI",
                        _crearReservaCorporativa,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pantallaGracies() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: colorTaronjaVIP,
            size: 80,
          ),
          const SizedBox(height: 20),
          const Text(
            "SOL·LICITUD CORPORATIVA ENVIADA",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              "La reserva ha quedat registrada correctament i pendent de gestió administrativa.",
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 40),
          _botoGris(
            "TORNAR A L'INICI",
            Icons.home,
            () => setState(() => _pasActual = 0),
          ),
        ],
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
              Text(
                titol.toUpperCase(),
                style: const TextStyle(
                  fontSize: 9,
                  color: colorGrisFosc,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                valor.isEmpty ? "No indicat" : valor,
                style: const TextStyle(
                  fontSize: 13,
                  color: colorGrisNegre,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _campPredictiu(TextEditingController ctrl, String hint, IconData icon) {
    return TypeAheadField<String>(
      suggestionsCallback: (pattern) async {
        if (pattern.length < 3) return [];

        const String apiKey = "AIzaSyA3yvNuaRTFJgRcRK0m5eu8_1cMquTRKrM";
        final String url =
            "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$pattern&key=$apiKey&types=establishment|geocode&language=en";

        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['status'] == 'OK') {
            return (data['predictions'] as List)
                .map((p) => p['description'] as String)
                .toList();
          }
        }
        return [];
      },
      onSelected: (suggestion) => setState(() => ctrl.text = suggestion),
      itemBuilder: (context, suggestion) => ListTile(
        title: Text(
          suggestion,
          style: const TextStyle(fontSize: 12),
        ),
      ),
      builder: (context, controller, focusNode) {
        if (controller.text != ctrl.text) {
          controller.text = ctrl.text;
        }
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: _estilInput(hint, icon),
        );
      },
    );
  }

  Widget _campBlanc(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    bool esNumber = false,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: esNumber ? TextInputType.number : TextInputType.text,
      decoration: _estilInput(hint, icon),
    );
  }

  InputDecoration _estilInput(String hint, IconData icon) {
    return InputDecoration(
      filled: true,
      fillColor: colorGrisClarBackground,
      prefixIcon: Icon(icon, color: colorGrisFosc, size: 18),
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 15,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _botoGris(String text, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorGrisClarBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 8),
            Text(text, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _botoAccio(String text, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorTaronjaVIP,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _triarData() async {
    final DateTime? p = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (p != null) {
      setState(() => _selectedDate = p);
    }
  }

  void _triarHora() async {
    final TimeOfDay? p = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (p != null) {
      setState(() => _selectedTime = p);
    }
  }

  @override
  void dispose() {
    _origenController.dispose();
    _destiController.dispose();
    _volController.dispose();
    _paxController.dispose();
    _maletesController.dispose();
    _obsController.dispose();
    _welcomeSignController.dispose();

    _nomClientController.dispose();
    _mailClientController.dispose();
    _telClientController.dispose();

    _nomEmpresaController.dispose();
    _personaContacteController.dispose();
    _emailEmpresaController.dispose();
    _telefonEmpresaController.dispose();
    _referenciaInternaController.dispose();
    _obsFacturacioController.dispose();

    super.dispose();
  }
}
