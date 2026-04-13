import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PantallaConductor extends StatefulWidget {
  final String uidXofer;
  const PantallaConductor({super.key, required this.uidXofer});

  @override
  State<PantallaConductor> createState() => _PantallaConductorState();
}

class _PantallaConductorState extends State<PantallaConductor> {
  final Color taronja = const Color(0xFFFF700A);
  final Color grisNegre = const Color(0xFF2D3142);
  final Color grisClar = const Color(0xFF778591);

  // --- 1. TARGETA INTEGRADA AMB CODI DE RESERVA ---
  Widget _targetaViatge(Map<String, dynamic> d, String idDoc) {
    String client = (d['client'] ?? "").toString();
    String origen = (d['origen'] ?? "").toString();
    String desti = (d['desti'] ?? "").toString();
    String hora = (d['hora'] ?? "--:--").toString();
    String pax = (d['pax'] ?? "0").toString();
    String maletes = (d['maletes'] ?? "0").toString();
    String tipus = (d['tipus'] ?? "TRANSFER").toString();
    // Camp clau per "tancar el cercle"
    String codiReserva = (d['codi_reserva'] ?? "---").toString();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: grisClar.withOpacity(0.1)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: InkWell(
        onTap: () => _obrirMenuOperatiu(d, idDoc),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Text(hora, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(client.toUpperCase(), 
                          style: TextStyle(color: grisNegre, fontWeight: FontWeight.w900, fontSize: 14)),
                        // MOSTRAR CODI ALS DOS COSTATS
                        Text("CODI: $codiReserva", 
                          style: TextStyle(color: taronja, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1)),
                      ],
                    ),
                  ),
                  Text(tipus, style: TextStyle(fontSize: 10, color: grisClar, fontWeight: FontWeight.bold)),
                ],
              ),
              const Divider(height: 24),
              _filaRuta(Icons.login, Colors.green, origen),
              const SizedBox(height: 8),
              _filaRuta(Icons.logout, Colors.red, desti),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person, size: 18, color: Color(0xFF778591)),
                      const SizedBox(width: 5),
                      Text(pax, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 25),
                      const Icon(Icons.luggage, size: 18, color: Color(0xFF778591)),
                      const SizedBox(width: 5),
                      Text(maletes, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  // Botó ràpid de xat amb indicador de missatges si calgués
                  IconButton(
                    icon: Icon(Icons.forum_outlined, color: taronja),
                    onPressed: () => _obrirXatTraductor(context, d, idDoc),
                  )
                ],
              ),
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
    String clientV = (d['client'] ?? "SENSE NOM").toString();
    String destiV = (d['desti'] ?? "No definit").toString();
    String horaV = (d['hora'] ?? "--:--").toString();
    String codiV = (d['codi_reserva'] ?? "---").toString();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              Text(clientV.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF2D3142))),
              Text("RESERVA: $codiV", style: TextStyle(color: taronja, fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 30),
              ListTile(
                leading: const CircleAvatar(backgroundColor: Color(0xFFE8F5E9), child: Icon(Icons.play_arrow, color: Colors.green)),
                title: const Text("INICIAR SERVEI", style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  FirebaseFirestore.instance.collection('reserves').doc(idDoc).update({'estat_servei': 'en_cami'});
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              ListTile(
                leading: CircleAvatar(backgroundColor: taronja.withOpacity(0.1), child: Icon(Icons.forum, color: taronja)),
                title: const Text("OBRIR XAT TRADUCTOR"),
                onTap: () {
                  Navigator.pop(context);
                  _obrirXatTraductor(context, d, idDoc);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // --- 3. XAT TRADUCTOR (Sincronitzat amb col·lecció 'reserves') ---
  void _obrirXatTraductor(BuildContext context, Map<String, dynamic> d, String idDoc) async {
    TextEditingController controllerMsg = TextEditingController();

    // Marcar com llegit
    var missatgesNoLlegits = await FirebaseFirestore.instance
        .collection('reserves').doc(idDoc).collection('xat')
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
                    Text("XAT AMB ${d['client']}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: grisNegre)),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('reserves').doc(idDoc).collection('xat').orderBy('creat_el', descending: true).snapshots(),
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
                            await FirebaseFirestore.instance.collection('reserves').doc(idDoc).collection('xat').add({
                              'autor': 'CONDUCTOR',
                              'text_cat': controllerMsg.text,
                              'text_traduit': '', 
                              'creat_el': FieldValue.serverTimestamp(),
                              'llegit': false,
                              'idioma_desti': d['idioma_client'] ?? 'EN',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("ONLYTRANSFER", style: TextStyle(color: Color(0xFF2D3142), fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reserves')
            .where('UID_xofer', isEqualTo: widget.uidXofer)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text("Error de connexió"));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Color(0xFFFF700A)));
          
          var docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text("No hi ha reserves assignades"));

          return ListView.builder(
            padding: const EdgeInsets.only(top: 10, bottom: 30),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              return _targetaViatge(docs[i].data() as Map<String, dynamic>, docs[i].id);
            },
          );
        },
      ),
    );
  }
}
