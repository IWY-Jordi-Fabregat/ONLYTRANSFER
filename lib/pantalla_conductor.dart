import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PantallaConductor extends StatefulWidget {
  final String uidConductor;
  const PantallaConductor({super.key, required this.uidConductor});

  @override
  State<PantallaConductor> createState() => _PantallaConductorState();
}

class _PantallaConductorState extends State<PantallaConductor> {
  final Color taronja = const Color(0xFFFF700A);
  final Color grisNegre = const Color(0xFF2D3142);
  final Color grisClar = const Color(0xFF778591);

  // --- 1. TARGETA ESTIL IWY (CORREGIDA PER EVITAR OVERFLOW) ---
  Widget _targetaViatge(Map<String, dynamic> d, String idDoc) {
    if (d['VOL'] != null && d['VOL'] != "" && d['ULTIMA_CONSULTA_VOL'] == null) {
      _consultarAPIvols(idDoc, d['VOL']);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
decoration: BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(16), // Cantons arrodonits estil iOS
  border: Border.all(
    color: const Color(0xFF778591).withOpacity(0.2), // El teu Gris Clar, molt suau
    width: 1,
  ),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.05), // Ombra gairebé invisible però real
      blurRadius: 10,
      offset: const Offset(0, 4), // L'ombra cau una mica cap avall
    ),
  ],
),      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () => _obrirMenuOperatiu(d, idDoc),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // HORA FIXA (Format 24h depèn de com ho posis a Firebase, aquí li donem l'espai)
                  SizedBox(
                    width: 60,
                    child: Text(
                      "${d['HORA']}", 
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 18, 
                        color: (d['RETARD'] == true) ? taronja : grisNegre
                      )
                    ),
                  ),
                  const SizedBox(width: 10),
                  // NOM CLIENT AMB LIMITACIÓ DE CARÀCTERS
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            d['CLIENT']?.toString().toUpperCase() ?? "",
                            style: TextStyle(color: taronja, fontWeight: FontWeight.bold, fontSize: 15),
                            overflow: TextOverflow.ellipsis, // Posa els ... si és massa llarg
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('viatges')
                              .doc(idDoc)
                              .collection('xat')
                              .where('autor', isEqualTo: 'CLIENT')
                              .where('llegit', isEqualTo: false)
                              .snapshots(),
                          builder: (context, snap) {
                            if (snap.hasData && snap.data!.docs.isNotEmpty) {
                              return Container(
                                width: 8, height: 8,
                                decoration: BoxDecoration(color: taronja, shape: BoxShape.circle),
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                      ],
                    ),
                  ),
                  // INFO VOL
                  if (d['VOL'] != null && d['VOL'] != "") ...[
                    const SizedBox(width: 5),
                    Icon(Icons.flight_land, size: 14, color: (d['RETARD'] == true) ? taronja : grisClar),
                    const SizedBox(width: 4),
                    Text("${d['VOL']}", style: TextStyle(fontSize: 10, color: grisClar)),
                  ],
                ],
              ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(height: 1, color: Color(0xFFF0F0F0))),
              _filaRuta(Icons.login, Colors.green, d['O'] ?? ""),
              const SizedBox(height: 6),
              _filaRuta(Icons.logout, Colors.red, d['D'] ?? ""),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filaRuta(IconData icona, Color color, String text) {
    return Row(
      children: [
        Icon(icona, size: 16, color: color),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: Color(0xFF556677)), overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  // --- 2. MENÚ OPERATIU ---
  void _obrirMenuOperatiu(Map<String, dynamic> d, String idDoc) {
    int pasActual = d['PAS_OPERATIU'] ?? 0;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(25),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(d['CLIENT'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: grisNegre)),
                  const SizedBox(height: 5),
                  Text("Idioma: ${d['IDIOMA_CLIENT'] ?? 'Detectant...'}", style: TextStyle(color: grisClar, fontSize: 12)),
                  const Divider(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                     _botoEina(Icons.map_outlined, "MAPA", Colors.blue, () async {
  final url = Uri.parse("google.navigation:q=${Uri.encodeComponent(d['O'])}");
  await launchUrl(url);
}),
                      _botoEina(Icons.chat_bubble_outline, "XAT DEEPL", taronja, () {
                        Navigator.pop(context);
                        _obrirXatTraductor(context, d, idDoc);
                      }),
                    ],
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 70,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: pasActual == 4 ? Colors.green : (pasActual == 0 ? Colors.blue : grisNegre),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        String ara = DateFormat('HH:mm').format(DateTime.now());
                        pasActual++;
                        await FirebaseFirestore.instance.collection('viatges').doc(idDoc).update({
                          'PAS_OPERATIU': pasActual,
                          'HORA_PAS_$pasActual': ara,
                        });
                        if (pasActual > 5) {
                          await FirebaseFirestore.instance.collection('viatges').doc(idDoc).update({'ESTAT_SERVEI': 'FINALITZAT'});
                          Navigator.pop(context);
                        }
                        setModalState(() {});
                      },
                      child: Text(_textBoto(pasActual), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- 3. XAT TRADUCTOR ---
  void _obrirXatTraductor(BuildContext context, Map<String, dynamic> d, String idDoc) async {
    TextEditingController controllerMsg = TextEditingController();

    var missatgesNoLlegits = await FirebaseFirestore.instance
        .collection('viatges').doc(idDoc).collection('xat')
        .where('autor', isEqualTo: 'CLIENT')
        .where('llegit', isEqualTo: false).get();
    
    for (var doc in missatgesNoLlegits.docs) {
      doc.reference.update({'llegit': true});
    }

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.85,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("XAT AMB ${d['CLIENT']}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: grisNegre)),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('viatges').doc(idDoc).collection('xat').orderBy('creat_el', descending: true).snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                      var msgs = snapshot.data!.docs;
                      return ListView.builder(
                        reverse: true,
                        itemCount: msgs.length,
                        itemBuilder: (context, i) {
                          var m = msgs[i].data() as Map<String, dynamic>;
                          bool socJo = m['autor'] == 'CONDUCTOR';
                          return Align(
                            alignment: socJo ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: socJo ? taronja : const Color(0xFFF2F2F7),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                crossAxisAlignment: socJo ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                children: [
                                  Text(m['text_cat'] ?? "", style: TextStyle(color: socJo ? Colors.white : Colors.black, fontSize: 15)),
                                  if (m['text_traduit'] != null && m['text_traduit'] != "")
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(m['text_traduit'], style: TextStyle(fontSize: 12, color: socJo ? Colors.white70 : Colors.black54, fontStyle: FontStyle.italic)),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controllerMsg,
                          decoration: InputDecoration(
                            hintText: "Escriu en català...",
                            filled: true,
                            fillColor: const Color(0xFFF2F2F7),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      CircleAvatar(
                        backgroundColor: taronja,
                        radius: 25,
                        child: IconButton(
                          onPressed: () async {
                            if (controllerMsg.text.isEmpty) return;
                            await FirebaseFirestore.instance.collection('viatges').doc(idDoc).collection('xat').add({
                              'autor': 'CONDUCTOR',
                              'text_cat': controllerMsg.text,
                              'text_traduit': '', 
                              'creat_el': FieldValue.serverTimestamp(),
                              'llegit': false,
                              'idioma_desti': d['IDIOMA_CLIENT'] ?? 'EN',
                            });
                            controllerMsg.clear();
                          },
                          icon: const Icon(Icons.send, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- 4. API AVIATION ---
  Future<void> _consultarAPIvols(String idDoc, String volNum) async {
    const String apiKey = "a9579a6e6c1d23b11609042190aabb5a";
    try {
      final response = await http.get(Uri.parse("http://api.aviationstack.com/v1/flights?access_key=$apiKey&flight_iata=$volNum"));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null && data['data'].isNotEmpty) {
          var f = data['data'][0];
          var depDelay = f['departure']['delay']; 
          await FirebaseFirestore.instance.collection('viatges').doc(idDoc).update({
            'RETARD': (depDelay != null && depDelay > 15),
            'ULTIMA_CONSULTA_VOL': DateTime.now().toIso8601String(),
          });
        }
      }
    } catch (e) {
      debugPrint("Error vol: $e");
    }
  }

  // --- FUNCIONS SUPORT ---
  Widget _botoEina(IconData icona, String text, Color color, VoidCallback accio) {
    return Column(
      children: [
        IconButton(onPressed: accio, icon: Icon(icona, color: color, size: 28), style: IconButton.styleFrom(backgroundColor: color.withOpacity(0.1), padding: const EdgeInsets.all(15))),
        const SizedBox(height: 8),
        Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  String _textBoto(int pas) {
    switch (pas) {
      case 0: return "SALGO DE LA BASE";
      case 1: return "LLEGO AL PUNTO DE RECOGIDA";
      case 2: return "APARECE EL CLIENTE";
      case 3: return "ARRANCAMOS";
      case 4: return "CLIENTE EN DESTINO";
      default: return "FINALIZAR SERVEI";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text("ONLYTRANSFER", style: TextStyle(color: grisNegre, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('viatges').where('UID_CONDUCTOR', isEqualTo: widget.uidConductor).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Color(0xFFFF700A)));
          var docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text("No hi ha viatges avui."));
          return ListView.builder(
            padding: const EdgeInsets.only(top: 10, bottom: 30),
            itemCount: docs.length,
            itemBuilder: (context, i) => _targetaViatge(docs[i].data() as Map<String, dynamic>, docs[i].id),
          );
        },
      ),
    );
  }
}
