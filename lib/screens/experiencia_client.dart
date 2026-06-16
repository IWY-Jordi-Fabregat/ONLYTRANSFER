import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../services/stripe_service.dart';
import '../services/reserva_service.dart';
import '../services/configuracio_service.dart';

// --- COLORS CORPORATIUS ONLYTRANSFER ---
const Color colorFonsBlanc = Colors.white;
const Color colorTaronjaVIP = Color(0xFFFF700A);
const Color colorGrisClar = Color(0xFF778591);
const Color colorGrisFosc = Color(0xFF556677);
const Color colorGrisNegre = Color(0xFF2D3142);
const Color colorGrisClarBackground = Color(0xFFF0F2F5);

class ExperienciaClient extends StatefulWidget {
  const ExperienciaClient({super.key});

  @override
  State<ExperienciaClient> createState() => _ExperienciaClientState();
}

class _ExperienciaClientState extends State<ExperienciaClient> {
  int _pasActual = 0;
  bool _processant = false;
ConfiguracioEmpresa _config = const ConfiguracioEmpresa(
  preuSedan: 125,
  preuVan: 185,
  margeOnlyTransfer: 20,
  tempsEntreServeisMin: 120,
);

bool _carregantConfig = true;

  // CONTROLADORS
  final TextEditingController _origenController = TextEditingController();
  final TextEditingController _destiController = TextEditingController();
  final TextEditingController _volController = TextEditingController();
  final TextEditingController _paxController = TextEditingController(text: '1');
  final TextEditingController _maletesController = TextEditingController(text: '0');
  final TextEditingController _obsController = TextEditingController();
  final TextEditingController _welcomeSignController = TextEditingController();

  final TextEditingController _nomClientController = TextEditingController();
  final TextEditingController _dniClientController = TextEditingController();
  final TextEditingController _mailClientController = TextEditingController();
  final TextEditingController _telClientController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 12, minute: 0);

  String _generarCodiReservaNetejat() {
    const String alfabetNet = 'BCDFGHJKLMNPQRSTVWXYZ23456789';
    return List.generate(
      6,
      (index) => alfabetNet[Random().nextInt(alfabetNet.length)],
    ).join();
  }

  Future<void> _executarPagamentDirecte() async {
    if (_nomClientController.text.isEmpty || _mailClientController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Si us plau, omple el nom i el correu"),
          backgroundColor: colorTaronjaVIP,
        ),
      );
      return;
    }

    setState(() => _processant = true);

    try {
      await StripeService.executarPagamentDirecte(
        nomClient: _nomClientController.text,
      );

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
    int numPax = int.tryParse(_paxController.text) ?? 1;
    int numMaletes = int.tryParse(_maletesController.text) ?? 0;
    String codiUnic = _generarCodiReservaNetejat();

    String mailClient = _mailClientController.text.trim();
    String nomClient = _nomClientController.text.isEmpty
        ? "Client VIP"
        : _nomClientController.text;
    String vol = _volController.text.isEmpty ? "No indicat" : _volController.text;
    String sign = _welcomeSignController.text.isEmpty
        ? nomClient
        : _welcomeSignController.text;

final dadesReserva = {
  // CLIENT
  'client': nomClient,
  'dni': _dniClientController.text,
  'email': mailClient,
  'telefon': _telClientController.text,

  // SERVEI
  'codi_reserva': codiUnic,
  'data': DateFormat('dd/MM/yyyy').format(_selectedDate),
  'hora': _selectedTime.format(context),
  'data_servei_ts': Timestamp.fromDate(_selectedDate),
  'origen': _origenController.text,
  'desti': _destiController.text,
  'ciutat': 'Barcelona',

  // OPERATIVA
  'pax': numPax.toString(),
  'maletes': numMaletes.toString(),
  'vehicle_tipus': (numPax >= 3 || numMaletes >= 3)
      ? "VAN Executive"
      : "Sedan Luxe",

  // ECONÒMIC
  'import': _preuActual().toStringAsFixed(2),
  'estat_pagament': 'PAGAT',

  // SERVEI
  'estat_servei': 'pendent_assignar',
  'conductor_id': '',

  // PAGAMENT CONDUCTOR
  'pagat_conductor': false,
  'data_pagament_conductor': null,

  // CONTROL
  'tipus_client': 'particular',
  'creat_el': FieldValue.serverTimestamp(),

  // LOGS
  'log_1': {'fet': false, 'hora': '', 'lat': 0.0, 'lng': 0.0},
  'log_2': {'fet': false, 'hora': '', 'lat': 0.0, 'lng': 0.0},
  'log_3': {'fet': false, 'hora': '', 'lat': 0.0, 'lng': 0.0},
  'log_4': {'fet': false, 'hora': '', 'lat': 0.0, 'lng': 0.0},
  'log_5': {'fet': false, 'hora': '', 'lat': 0.0, 'lng': 0.0},
  'log_6': {'fet': false, 'hora': '', 'lat': 0.0, 'lng': 0.0},

  'tipus_client': 'particular',
  'tipus_pagament': 'instantani',
  'estat_pagament': 'PAGAT',
  'dni': _dniClientController.text,
  'welcome_sign': sign,

  // EMAIL
  'to': mailClient,
  'message': {
    'subject': 'Confirmació Reserva OnlyTransfer: $codiUnic',
        'html': '''
        <div style="font-family: sans-serif; padding: 20px; border: 1px solid #f0f0f0; border-radius: 10px; max-width: 600px; margin: auto;">
          <h1 style="color: #FF700A; text-align: center; letter-spacing: 2px;">ONLY TRANSFER</h1>
          <p>Hola <b>$nomClient</b>,</p>
          <p>La teva reserva ha estat confirmada correctament.</p>
          <div style="background: #F0F2F5; padding: 20px; border-radius: 10px; text-align: center; margin: 20px 0;">
            <p style="margin:0; font-size: 10px; color: #778591; text-transform: uppercase;">Codi</p>
            <h2 style="margin:5px 0; color: #FF700A; letter-spacing: 8px; font-size: 32px;">$codiUnic</h2>
          </div>
          <p style="font-size: 14px; color: #2D3142;">
            <b>📍 Recollida:</b> ${_origenController.text}<br>
            <b>🏁 Destí:</b> ${_destiController.text}<br>
            <b>📅 Data:</b> ${DateFormat('dd/MM/yyyy').format(_selectedDate)} a les ${_selectedTime.format(context)}
          </p>
          <hr style="border: none; border-top: 1px solid #eee; margin: 20px 0;">
          <p style="font-size: 11px; color: #778591; text-align: center;">© 2026 OnlyTransfer Luxury Transport.</p>
        </div>
      ''',
      }
    };

    try {
      await ReservaService.gravarReserva(
        dadesReserva: dadesReserva,
      );

      if (!mounted) return;
      setState(() => _pasActual = 4);
    } catch (error) {
      debugPrint("🚨 Error Firebase: $error");
      rethrow;
    }
  }

@override
Widget build(BuildContext context) {
  if (_carregantConfig) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(color: colorTaronjaVIP),
      ),
    );
  }    return Scaffold(
      backgroundColor: colorFonsBlanc,
      appBar: AppBar(
        title: const Text(
          'ONLY TRANSFER',
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
        return _pantallaIdentificacio();
      case 4:
        return _pantallaGracies();
      default:
        return _pantallaSeleccio();
    }
  }

  // --- PANTALLES ---

  Widget _pantallaSeleccio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.airplanemode_active, color: colorTaronjaVIP, size: 40),
          const Text(
            "TRANSFER",
            style: TextStyle(fontSize: 10, color: colorTaronjaVIP),
          ),
          const SizedBox(height: 60),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: _botoAccio(
              "NOVA RESERVA",
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
          _campPredictiu(_origenController, "Recollida", Icons.location_on_outlined),
          const SizedBox(height: 15),
          _campPredictiu(_destiController, "Destinació", Icons.flag_outlined),
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
          _campBlanc(_volController, "Número de Vol / Tren", Icons.flight_takeoff),
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
          _campBlanc(_obsController, "Observacions VIP", Icons.chat_bubble_outline),
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
                _filaResum(Icons.location_on_outlined, "Origen", _origenController.text),
                const Divider(height: 30),
                _filaResum(Icons.flag_outlined, "Destí", _destiController.text),
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
            "CONFIRMAR I IDENTIFICAR-ME",
            () => setState(() => _pasActual = 3),
          ),
        ],
      ),
    );
  }

  Widget _pantallaIdentificacio() {
   String preuFinal =
    "${_preuActual().toStringAsFixed(2).replaceAll('.', ',')} €";
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "DADES DE FACTURACIÓ",
            style: TextStyle(
              color: colorTaronjaVIP,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 20),
          _campBlanc(_nomClientController, "Nom Complet / Empresa", Icons.person_outline),
          const SizedBox(height: 10),
          _campBlanc(_mailClientController, "Correu per rebre el tiquet", Icons.alternate_email),
          const SizedBox(height: 10),
          _campBlanc(
            _telClientController,
            "Telèfon",
            Icons.phone_android_outlined,
            esNumber: true,
          ),
          const SizedBox(height: 30),
          const Text(
            "PAGAMENT SEGUR",
            style: TextStyle(
              color: colorTaronjaVIP,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: colorGrisClarBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: CardFormField(
              style: CardFormStyle(fontSize: 14),
            ),
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
                      "IMPORT TOTAL",
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
                const SizedBox(height: 20),
                _processant
                    ? const CircularProgressIndicator(color: colorTaronjaVIP)
                    : _botoAccio("PAGAR ARA", _executarPagamentDirecte),
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
          const Icon(Icons.check_circle_outline, color: colorTaronjaVIP, size: 80),
          const SizedBox(height: 20),
          const Text(
            "PAGAMENT COMPLETAT",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          _botoGris("TORNAR A L'INICI", Icons.home, () => setState(() => _pasActual = 0)),
        ],
      ),
    );
  }

  // --- COMPONENTS ---

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
        final url =
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
      itemBuilder: (context, suggestion) {
        return ListTile(
          title: Text(
            suggestion,
            style: const TextStyle(fontSize: 12),
          ),
        );
      },
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
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
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
    DateTime? p = await showDatePicker(
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
    TimeOfDay? p = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (p != null) {
      setState(() => _selectedTime = p);
    }
  }
 @override
 void initState() {
  super.initState();
  _carregarConfiguracio();
 }
double _preuActual() {
  final int numPax = int.tryParse(_paxController.text) ?? 1;
  final int numMaletes = int.tryParse(_maletesController.text) ?? 0;

  return (numPax >= 3 || numMaletes >= 3)
      ? _config.preuVan
      : _config.preuSedan;
}
 Future<void> _carregarConfiguracio() async {
  try {
    final cfg = await ConfiguracioService.obtenirConfiguracio();
    if (!mounted) return;
    setState(() {
      _config = cfg;
      _carregantConfig = false;
    });
  } catch (e) {
    if (!mounted) return;
    setState(() {
      _carregantConfig = false;
    });
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
    _dniClientController.dispose();
    _mailClientController.dispose();
    _telClientController.dispose();
    super.dispose();
  }
}
