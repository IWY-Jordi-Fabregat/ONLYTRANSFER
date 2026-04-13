import 'package:flutter/material.dart';
import '../services/configuracio_service.dart';

const Color colorFonsBlanc = Colors.white;
const Color colorTaronjaVIP = Color(0xFFFF700A);
const Color colorGrisClar = Color(0xFF778591);
const Color colorGrisFosc = Color(0xFF556677);
const Color colorGrisNegre = Color(0xFF2D3142);
const Color colorGrisClarBackground = Color(0xFFF0F2F5);

class PantallaConfiguracioEmpresarial extends StatefulWidget {
  const PantallaConfiguracioEmpresarial({super.key});

  @override
  State<PantallaConfiguracioEmpresarial> createState() =>
      _PantallaConfiguracioEmpresarialState();
}

class _PantallaConfiguracioEmpresarialState
    extends State<PantallaConfiguracioEmpresarial> {
  final TextEditingController _preuSedanController = TextEditingController();
  final TextEditingController _preuVanController = TextEditingController();
  final TextEditingController _margeOnlyTransferController =
      TextEditingController();
  final TextEditingController _tempsEntreServeisController =
      TextEditingController();

  bool _carregant = true;
  bool _guardant = false;

  @override
  void initState() {
    super.initState();
    _carregarConfiguracio();
  }

  Future<void> _carregarConfiguracio() async {
    try {
      final cfg = await ConfiguracioService.obtenirConfiguracio();

      _preuSedanController.text = (cfg['preu_sedan'] ?? 125).toString();
      _preuVanController.text = (cfg['preu_van'] ?? 185).toString();
      _margeOnlyTransferController.text =
          (cfg['marge_onlytransfer'] ?? 20).toString();
      _tempsEntreServeisController.text =
          (cfg['temps_entre_serveis_min'] ?? 120).toString();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error carregant configuració: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _carregant = false);
      }
    }
  }

  Future<void> _guardarConfiguracio() async {
    final double? preuSedan = double.tryParse(
      _preuSedanController.text.trim().replaceAll(',', '.'),
    );
    final double? preuVan = double.tryParse(
      _preuVanController.text.trim().replaceAll(',', '.'),
    );
    final double? marge = double.tryParse(
      _margeOnlyTransferController.text.trim().replaceAll(',', '.'),
    );
    final int? temps = int.tryParse(
      _tempsEntreServeisController.text.trim(),
    );

    if (preuSedan == null || preuVan == null || marge == null || temps == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Revisa els valors numèrics'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _guardant = true);

    try {
      await ConfiguracioService.guardarConfiguracio(
        preuSedan: preuSedan,
        preuVan: preuVan,
        margeOnlyTransfer: marge,
        tempsEntreServeisMin: temps,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Configuració guardada correctament'),
          backgroundColor: colorTaronjaVIP,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error guardant configuració: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _guardant = false);
      }
    }
  }

  @override
  void dispose() {
    _preuSedanController.dispose();
    _preuVanController.dispose();
    _margeOnlyTransferController.dispose();
    _tempsEntreServeisController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorFonsBlanc,
      appBar: AppBar(
        title: const Text(
          'CONFIGURACIÓ EMPRESARIAL',
          style: TextStyle(
            color: colorGrisNegre,
            letterSpacing: 1.5,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colorFonsBlanc,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: colorGrisNegre),
      ),
      body: _carregant
          ? const Center(
              child: CircularProgressIndicator(color: colorTaronjaVIP),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PREUS I CONDICIONS BASE',
                    style: TextStyle(
                      color: colorTaronjaVIP,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _campBlanc(
                    _preuSedanController,
                    'Preu Sedan (€)',
                    Icons.directions_car_outlined,
                  ),
                  const SizedBox(height: 12),
                  _campBlanc(
                    _preuVanController,
                    'Preu VAN (€)',
                    Icons.airport_shuttle_outlined,
                  ),
                  const SizedBox(height: 12),
                  _campBlanc(
                    _margeOnlyTransferController,
                    'Marge OnlyTransfer (%)',
                    Icons.percent_outlined,
                  ),
                  const SizedBox(height: 12),
                  _campBlanc(
                    _tempsEntreServeisController,
                    'Temps entre serveis (min)',
                    Icons.schedule_outlined,
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _guardant ? null : _guardarConfiguracio,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorTaronjaVIP,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _guardant
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'GUARDAR CONFIGURACIÓ',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _campBlanc(
    TextEditingController ctrl,
    String hint,
    IconData icon,
  ) {
    return TextField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        filled: true,
        fillColor: colorGrisClarBackground,
        prefixIcon: Icon(icon, color: colorGrisFosc, size: 18),
        hintText: hint,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
