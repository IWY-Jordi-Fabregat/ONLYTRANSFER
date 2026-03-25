import 'package:flutter/material.dart';

class KitVipValidator extends StatefulWidget {
  @override
  _KitVipValidatorState createState() => _KitVipValidatorState();
}

class _KitVipValidatorState extends State<KitVipValidator> {
  // Els 4 pilars de la teva qualitat
  bool aiguaNatural = false;
  bool ferreroTancats = false;
  bool caramelsMelLlimona = false;
  bool tovallolesHumides = false;

  @override
  Widget build(BuildContext context) {
    bool totLlest = aiguaNatural && ferreroTancats && caramelsMelLlimona && tovallolesHumides;

    return Scaffold(
      backgroundColor: Color(0 suicide2D3142), // Gris Negre
      appBar: AppBar(
        title: Text("PROTOCOL DE SORTIDA", style: TextStyle(color: Colors.white, fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("VERIFICACIÓ KIT ONLYTRANSFER", 
              style: TextStyle(color: Color(0xFFFF700A), fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 30),
            
            _itemCheck("💧 Aigua Natural (Ambient)", aiguaNatural, (v) => setState(() => aiguaNatural = v!)),
            _itemCheck("🍫 Ferrero Rocher (Precintats)", ferreroTancats, (v) => setState(() => ferreroTancats = v!)),
            _itemCheck("🍬 Caramels Mel i Llimona", caramelsMelLlimona, (v) => setState(() => caramelsMelLlimona = v!)),
            _itemCheck("🧼 Tovalloles humides", tovallolesHumides, (v) => setState(() => tovallolesHumides = v!)),
            
            Spacer(),
            
            // EL BOTÓ DE SORTIDA (Només s'activa si tot és OK)
            SizedBox(
              width: double.infinity,
              height: 70,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: totLlest ? Color(0xFFFF700A) : Colors.white10,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: totLlest ? () => print("🚀 RUMB A LA T1 - TOT PERFECTE") : null,
                child: Text(
                  totLlest ? "INICIAR SERVEI" : "REVISA EL KIT",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemCheck(String titol, bool valor, Function(bool?) onToggle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: CheckboxListTile(
        title: Text(titol, style: TextStyle(color: Colors.white, fontSize: 18)),
        value: valor,
        onChanged: onToggle,
        activeColor: Color(0xFFFF700A),
        checkColor: Colors.white,
        tileColor: Colors.white.withOpacity(0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
