import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'main.dart'; // Importat per fer servir t()

// Paleta OnlyTransfer
const Color colorFonsBlanc = Colors.white;
const Color colorGrisClar = Color(0xFFF5F5F7); 
const Color colorTaronjaVIP = Color(0xFFFF700A);
const Color colorGrisFosc = Color(0xFF2D3142);
const Color colorTextSecundari = Color(0xFF778591);

class ExperienciaClient extends StatefulWidget {
  const ExperienciaClient({super.key});
  @override
  State<ExperienciaClient> createState() => _ExperienciaClientState();
}

class _ExperienciaClientState extends State<ExperienciaClient> {
  int _pasActual = 0; 
  
  final _origenController = TextEditingController();
  final _destiController = TextEditingController();
  final _volController = TextEditingController();
  final _paxController = TextEditingController(text: '1');
  final _maletesController = TextEditingController(text: '0');
  final _observacionsController = TextEditingController();
  final _nomClientController = TextEditingController();
  final _mailClientController = TextEditingController();
  final _dniClientController = TextEditingController();

  // NOUS CONTROLADORS PER A DISPOSICIÓ I VIP (Sense tocar els anteriors)
  final _horesController = TextEditingController();
  final _telGuiaController = TextEditingController();
  final _importParkingController = TextEditingController();
  final _preuVipController = TextEditingController(); // Camp exclusiu per a amics

  bool _inclouDinar = false;
  bool _teParking = false;

  String _tipusServei = '';
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 12, minute: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorFonsBlanc,
      appBar: AppBar(
        title: Text(t('app_titol'), 
          style: const TextStyle(color: colorGrisFosc, letterSpacing: 2, fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: colorFonsBlanc,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: colorGrisFosc),
        leading: _pasActual > 0 ? IconButton(icon: const Icon(Icons.arrow_back_ios, size: 20), onPressed: () => setState(() => _pasActual--)) : null,
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

  Widget _pantallaSeleccio() {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _botoMenu(Icons.airplanemode_active, t('menu_transfer')),
          const SizedBox(height: 15),
          _botoMenu(Icons.star_border, t('menu_vip')), // EL TEU SERVEI VIP PER A AMICS
          const SizedBox(height: 15),
          _botoMenu(Icons.access_time, t('menu_disposicio')),
        ],
      ),
    );
  }

  Widget _botoMenu(IconData icona, String titol) {
    return InkWell(
      onTap: () => setState(() { _tipusServei = titol; _pasActual = 1; }),
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: colorFonsBlanc, borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Row(
          children: [
            Icon(icona, color: colorTaronjaVIP, size: 26),
            const SizedBox(width: 20),
            Text(titol, style: const TextStyle(color: colorGrisFosc, fontWeight: FontWeight.bold)),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, color: colorTextSecundari, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _pantallaDetalls() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_tipusServei, style: const TextStyle(color: colorTaronjaVIP, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          _campBlanc(_origenController, t('label_recollida'), Icons.location_on_outlined),
          const SizedBox(height: 15),
          _campBlanc(_destiController, t('label_desti'), Icons.flag_outlined),
          const SizedBox(height: 30),
          _selectorDataHora(),
          const SizedBox(height: 30),

          // BLOC ESPECÍFIC PER A DISPOSICIÓ
          if (_tipusServei == t('menu_disposicio')) ...[
            _campBlanc(_telGuiaController, t('label_guia_tel'), Icons.phone_android_outlined),
            const SizedBox(height: 15),
            _campBlanc(_horesController, t('label_hores'), Icons.timer_outlined, esNumber: true),
            const SizedBox(height: 15),
            CheckboxListTile(
              title: Text(t('label_dinar'), style: const TextStyle(fontSize: 14)),
              value: _inclouDinar,
              activeColor: colorTaronjaVIP,
              onChanged: (v) => setState(() => _inclouDinar = v!),
              contentPadding: EdgeInsets.zero,
            ),
          ],

          // BLOC ESPECÍFIC PER A VIP (Duplicat de Transfer amb el camp de preu)
          if (_tipusServei == t('menu_vip')) ...[
            _campBlanc(_preuVipController, "PREU ESPECIAL PACTAT (€)", Icons.euro_symbol, esNumber: true),
            const SizedBox(height: 15),
          ],

          // BLOC COMÚ (TRANSFER I VIP)
          if (_tipusServei != t('menu_disposicio')) ...[
            _campBlanc(_volController, t('label_vol'), Icons.flight_takeoff),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(child: _campBlanc(_paxController, t('label_pax'), Icons.people_outline, esNumber: true)),
                const SizedBox(width: 15),
                Expanded(child: _campBlanc(_maletesController, t('label_maletes'), Icons.luggage_outlined, esNumber: true)),
              ],
            ),
          ],

          const SizedBox(height: 15),
          CheckboxListTile(
            title: Text(t('label_parking'), style: const TextStyle(fontSize: 14)),
            value: _teParking,
            activeColor: colorTaronjaVIP,
            onChanged: (v) => setState(() => _teParking = v!),
            contentPadding: EdgeInsets.zero,
          ),
          if (_teParking) ...[
            _campBlanc(_importParkingController, t('label_import_euro'), Icons.euro, esNumber: true),
            const SizedBox(height: 15),
          ],
          
          const SizedBox(height: 15),
          _campBlanc(_observacionsController, t('label_obs'), Icons.notes, maxLines: 3),
          const SizedBox(height: 40),
          _botoAccio(t('btn_continuar'), () => setState(() => _pasActual = 2)),
        ],
      ),
    );
  }

  Widget _pantallaResum() {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(color: colorGrisClar, borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                Text(t('resum_titol'), style: const TextStyle(color: colorTaronjaVIP, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
                const SizedBox(height: 25),
                _filaResum(t('resum_de'), _origenController.text),
                _filaResum(t('resum_a'), _destiController.text),
                _filaResum(t('resum_data'), DateFormat('dd/MM/yyyy').format(_selectedDate)),
                _filaResum(t('resum_hora'), _selectedTime.format(context)),
                if (_tipusServei == t('menu_disposicio')) _filaResum(t('label_hores'), _horesController.text),
                if (_tipusServei == t('menu_vip')) _filaResum("Import Especial", "${_preuVipController.text} €"),
                if (_tipusServei != t('menu_disposicio')) _filaResum(t('resum_pax_maletes'), "${_paxController.text} / ${_maletesController.text}"),
              ],
            ),
          ),
          const Spacer(),
          _botoAccio(t('btn_identificar'), () => setState(() => _pasActual = 3)),
        ],
      ),
    );
  }

  Widget _pantallaIdentificacio() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          Text(t('identifica_titol'), style: const TextStyle(color: colorGrisFosc, fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 40),
          _campBlanc(_nomClientController, t('label_nom'), Icons.person_outline),
          const SizedBox(height: 15),
          _campBlanc(_mailClientController, t('label_mail'), Icons.alternate_email),
          const SizedBox(height: 15),
          _campBlanc(_dniClientController, t('label_dni'), Icons.badge_outlined),
          const SizedBox(height: 50),
          _botoAccio(t('btn_confirmar_final'), _finalitzarViatge),
        ],
      ),
    );
  }

  Widget _pantallaGracies() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, color: colorTaronjaVIP, size: 80),
          const SizedBox(height: 30),
          Text(t('gracies_titol'), style: const TextStyle(color: colorGrisFosc, fontWeight: FontWeight.bold, fontSize: 20)),
          const SizedBox(height: 10),
          Text(t('gracies_subtitol'), style: const TextStyle(color: colorTextSecundari)),
          const SizedBox(height: 60),
          TextButton(onPressed: () => Navigator.pop(context), child: Text(t('btn_inici'), style: const TextStyle(color: colorTaronjaVIP, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _campBlanc(TextEditingController ctrl, String hint, IconData icon, {bool esNumber = false, int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: esNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        filled: true, fillColor: colorGrisClar,
        prefixIcon: Icon(icon, color: colorGrisFosc, size: 20),
        hintText: hint, hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _botoAccio(String text, VoidCallback accio) {
    return SizedBox(
      width: double.infinity, height: 65,
      child: ElevatedButton(
        onPressed: accio,
        style: ElevatedButton.styleFrom(backgroundColor: colorTaronjaVIP, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
        child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _filaResum(String etiqueta, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Text(etiqueta, style: const TextStyle(color: colorTextSecundari)), 
        const Spacer(), 
        Text(valor, style: const TextStyle(color: colorGrisFosc, fontWeight: FontWeight.bold))
      ]),
    );
  }

  Widget _selectorDataHora() {
    return Row(
      children: [
        Expanded(child: _botoGris(DateFormat('dd/MM/yyyy').format(_selectedDate), Icons.calendar_today, _triarData)),
        const SizedBox(width: 15),
        Expanded(child: _botoGris(_selectedTime.format(context), Icons.access_time, _triarHora)),
      ],
    );
  }

  Widget _botoGris(String text, IconData icona, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: colorGrisClar, borderRadius: BorderRadius.circular(15)),
        child: Row(children: [Icon(icona, color: colorTaronjaVIP, size: 18), const SizedBox(width: 10), Text(text, style: const TextStyle(color: colorGrisFosc))]),
      ),
    );
  }

  void _triarData() async {
    DateTime? p = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime.now(), lastDate: DateTime(2030));
    if (p != null) setState(() => _selectedDate = p);
  }

 void _triarHora() async {
  TimeOfDay? p = await showTimePicker(
    context: context,
    initialTime: _selectedTime,
    builder: (BuildContext context, Widget? child) {
      // Forcem el format de 24 hores en el diàleg
      return MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      );
    },
  );
  if (p != null) setState(() => _selectedTime = p);
}
  Future<void> _finalitzarViatge() async {
    if (_nomClientController.text.isEmpty) return;
    showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator(color: colorTaronjaVIP)));
    try {
      await FirebaseFirestore.instance.collection('viatges').add({
        'CLIENT': _nomClientController.text,
        'MAIL': _mailClientController.text,
        'TAX_ID': _dniClientController.text,
        'O': _origenController.text,
        'D': _destiController.text,
        'DATA': DateFormat('dd/MM/yyyy').format(_selectedDate),
        'HORA': _selectedTime.format(context),
        'T': _tipusServei,
        'VOL': _volController.text,
        'PAX': _paxController.text,
        'MALETES': _maletesController.text,
        'NOTES': _observacionsController.text,
        'HORES_DISPO': _tipusServei == t('menu_disposicio') ? _horesController.text : '',
        'TEL_GUIA': _tipusServei == t('menu_disposicio') ? _telGuiaController.text : '',
        'DINAR': _inclouDinar,
        'PARKING_IMPORT': _teParking ? _importParkingController.text : '0',
        'PREU_VIP': _tipusServei == t('menu_vip') ? _preuVipController.text : '',
        'ESTAT_SERVEI': 'PENDENT',
        'UID_CONDUCTOR': '', 
        'creat_el': FieldValue.serverTimestamp(),
      });
      Navigator.pop(context);
      setState(() => _pasActual = 4);
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }
}
