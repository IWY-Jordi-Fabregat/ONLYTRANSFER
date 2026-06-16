import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PantallaTreballDiari extends StatefulWidget {
  const PantallaTreballDiari({super.key});

  @override
  State<PantallaTreballDiari> createState() => _PantallaTreballDiariState();
}

class _PantallaTreballDiariState extends State<PantallaTreballDiari> {
  final Color taronja = const Color(0xFFFF700A);
  final Color grisNegre = const Color(0xFF2D3142);
  final Color grisClar = const Color(0xFF778591);

  bool _accesAutoritzat = false;
  final TextEditingController _pinAdminController = TextEditingController();

  // --- DATA VIP: dl, 6 d'abril ---
  String formatarDataVip(String? dataStr) {
    if (dataStr == null || dataStr.isEmpty) return "";
    try {
      List<String> parts = dataStr.split('/');
      DateTime data = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
      List<String> dies = ["dl", "dt", "dm", "dj", "dv", "ds", "dg"];
      List<String> mesos = ["gen", "feb", "mar", "abr", "mai", "jun", "jul", "ago", "set", "oct", "nov", "des"];
      String diaNom = dies[data.weekday - 1];
      String mesNom = mesos[data.month - 1];
      String connector = (mesNom.startsWith('a') || mesNom.startsWith('o')) ? " d'" : " de ";
      return "$diaNom, ${data.day}$connector$mesNom";
    } catch (e) { return dataStr; }
  }

  void _obrirAssignador(Map<String, dynamic> d, String idDoc) {
    TextEditingController preuCtrl = TextEditingController(text: d['PREU']?.toString() ?? "");
    TextEditingController notesAdminCtrl = TextEditingController(text: d['NOTES_ADMIN'] ?? "");
    String? conductorTriat = (d['UID_CONDUCTOR'] == null || d['UID_CONDUCTOR'] == "") ? null : d['UID_CONDUCTOR'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text("GESTIÓ: ${d['CLIENT']}", style: TextStyle(color: grisNegre, fontWeight: FontWeight.bold, fontSize: 18)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('xofers').snapshots(),
                  builder: (context, snap) {
                    if (!snap.hasData) return const LinearProgressIndicator();
                    return DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: "TRIA CONDUCTOR", border: OutlineInputBorder()),
                      value: conductorTriat,
                      items: snap.data!.docs.map((docX) => DropdownMenuItem(value: docX.id, child: Text(docX['nom'] ?? ""))).toList(),
                      onChanged: (val) => setDialogState(() => conductorTriat = val),
                    );
                  },
                ),
                const SizedBox(height: 15),
                TextField(controller: preuCtrl, decoration: const InputDecoration(labelText: "PREU (€)", border: OutlineInputBorder())),
                const SizedBox(height: 15),
                TextField(controller: notesAdminCtrl, decoration: const InputDecoration(labelText: "NOTES CONDUCTOR", border: OutlineInputBorder()), maxLines: 2),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("CANCEL·LAR", style: TextStyle(color: grisClar))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: taronja),
              onPressed: () async {
                await FirebaseFirestore.instance.collection('viatges').doc(idDoc).update({
                  'UID_CONDUCTOR': conductorTriat ?? "",
                  'PREU': preuCtrl.text,
                  'NOTES_ADMIN': notesAdminCtrl.text,
                  'ESTAT_SERVEI': conductorTriat != null ? 'ASSIGNAT' : 'PENDENT',
                });
                Navigator.pop(context);
              },
              child: const Text("ENVIAR", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_accesAutoritzat) {
      return Scaffold(
        body: Center(
          child: SizedBox(
            width: 280,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("ONLYTRANSFER", style: TextStyle(color: taronja, fontWeight: FontWeight.bold, letterSpacing: 2)),
                const SizedBox(height: 20),
                TextField(
                  controller: _pinAdminController,
                  obscureText: true,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(hintText: "PIN ACCÉS", border: OutlineInputBorder()),
                  onSubmitted: (v) { if(v == "1962") setState(() => _accesAutoritzat = true); },
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: grisNegre, minimumSize: const Size(double.infinity, 45)),
                  onPressed: () { if(_pinAdminController.text == "1962") setState(() => _accesAutoritzat = true); },
                  child: const Text("ENTRAR", style: TextStyle(color: Colors.white)),
                )
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("PANEL DE GESTIÓ - ONLYTRANSFER", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        backgroundColor: grisNegre,
        centerTitle: true,
        toolbarHeight: 40,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('viatges').orderBy('creat_el', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var idDoc = docs[index].id;
              var d = docs[index].data() as Map<String, dynamic>;
              bool senseConductor = d['UID_CONDUCTOR'] == null || d['UID_CONDUCTOR'] == "";

              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 4),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                    side: BorderSide(color: senseConductor ? taronja : Colors.grey.shade200, width: 1),
                  ),
                  child: InkWell(
                    onTap: () => _obrirAssignador(d, idDoc),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Row(
                        children: [
                          // 1. DATA I HORA
                          SizedBox(
                            width: 140,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(formatarDataVip(d['DATA']), style: TextStyle(color: taronja, fontWeight: FontWeight.bold, fontSize: 11)),
                                Text("${d['HORA']}h", style: TextStyle(color: grisNegre, fontSize: 13, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          // 2. CLIENT
                          SizedBox(
                            width: 160,
                            child: Text(
                              d['CLIENT']?.toString().toUpperCase() ?? "",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          // --- COLUMNA: PAGAT (RODONETA VERDA) ---
                          SizedBox(
                            width: 50,
                            child: Center(
                              child: (d['estat_pagament'] == 'PAGAT' || d['estat_pagament'] == 'COBRAT (1€ Prova)')
                                  ? Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                                      child: const Icon(Icons.check, color: Colors.white, size: 10),
                                    )
                                  : Icon(Icons.circle_outlined, color: Colors.grey.shade300, size: 18),
                            ),
                          ),

                          // --- COLUMNA: PERSONES I MALETES ---
                          SizedBox(
                            width: 100,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.person_outline, size: 14, color: grisClar),
                                const SizedBox(width: 4),
                                Text("${d['PAX'] ?? '1'}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 12),
                                Icon(Icons.luggage_outlined, size: 14, color: grisClar),
                                const SizedBox(width: 4),
                                Text("${d['MALETES'] ?? '0'}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),

                          // 3. RUTA
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("> ${d['O']}", style: const TextStyle(fontSize: 11, color: Colors.green), overflow: TextOverflow.ellipsis),
                                Text("< ${d['D']}", style: const TextStyle(fontSize: 11, color: Colors.red), overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                          // 4. VOL / TREN
                          SizedBox(
                            width: 90,
                            child: Text(d['VOL'] ?? "---", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                          ),
                          // 6. OBSERVACIONS
                          Expanded(
                            flex: 2,
                            child: Text(
                              d['NOTES'] ?? "",
                              style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                          // 7. PREU
                          SizedBox(
                            width: 80,
                            child: Text(
                              "${d['PREU'] ?? '--'} €",
                              textAlign: TextAlign.right,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: senseConductor ? taronja : Colors.green),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Icon(Icons.arrow_forward_ios, size: 10, color: Colors.grey.shade300),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
