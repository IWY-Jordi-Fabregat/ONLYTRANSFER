import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PantallaClientWeb extends StatefulWidget {
  final String idViatge; // El codi que va a la URL: FjTVcs0HHPRl04exDFa1
  const PantallaClientWeb({super.key, required this.idViatge});

  @override
  State<PantallaClientWeb> createState() => _PantallaClientWebState();
}

class _PantallaClientWebState extends State<PantallaClientWeb> {
  final Color taronja = const Color(0xFFFF700A);
  final Color grisFosc = const Color(0xFF2D3142);
  final TextEditingController _controllerMsg = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Image.network('https://your-logo-url.com/logo.png', height: 30), // El teu logo OnlyTransfer
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('viatges').doc(widget.idViatge).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          var d = snapshot.data!.data() as Map<String, dynamic>;

          return Column(
            children: [
              // 1. EL MAPA (Simulat ara, on el client veu on ets)
              Container(
                height: 250,
                width: double.infinity,
                color: Colors.grey[100],
                child: const Center(child: Icon(Icons.map, size: 50, color: Colors.grey)),
              ),

              // 2. INFO DEL CONDUCTOR (TU)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const CircleAvatar(radius: 25, backgroundColor: Color(0xFFEEEEEE), child: Icon(Icons.person, color: Colors.grey)),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("EL TEU CONDUCTOR", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                        Text("JORDI F.", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: grisFosc)),
                      ],
                    ),
                  ],
                ),
              ),

              const Divider(),

              // 3. EL XAT INTEL·LIGENT (ON ELL REP EL JAPONÈS)
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('viatges')
                      .doc(widget.idViatge)
                      .collection('xat')
                      .orderBy('creat_el', descending: true)
                      .snapshots(),
                  builder: (context, chatSnapshot) {
                    if (!chatSnapshot.hasData) return const SizedBox();
                    var msgs = chatSnapshot.data!.docs;

                    return ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: msgs.length,
                      itemBuilder: (context, i) {
                        var m = msgs[i].data() as Map<String, dynamic>;
                        bool esConductor = m['autor'] == 'CONDUCTOR';

                        return Align(
                          alignment: esConductor ? Alignment.centerLeft : Alignment.centerRight,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: esConductor ? Colors.grey[100] : taronja,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              crossAxisAlignment: esConductor ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                              children: [
                                // El client veu el text traduït (si existeix) o el català
                                Text(
                                  m['text_traduit'] != null && m['text_traduit'] != "" 
                                      ? m['text_traduit'] 
                                      : m['text_cat'],
                                  style: TextStyle(color: esConductor ? Colors.black : Colors.white),
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

              // BARRA D'ESCRIURE DEL CLIENT
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controllerMsg,
                          decoration: InputDecoration(
                            hintText: "Escriu al conductor...",
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      CircleAvatar(
                        backgroundColor: taronja,
                        child: IconButton(
                          onPressed: () async {
                            if (_controllerMsg.text.isEmpty) return;
                            await FirebaseFirestore.instance
                                .collection('viatges')
                                .doc(widget.idViatge)
                                .collection('xat')
                                .add({
                              'autor': 'CLIENT',
                              'text_cat': '', // Aquí DeepL traduirà del seu idioma al teu
                              'text_traduit': _controllerMsg.text,
                              'creat_el': FieldValue.serverTimestamp(),
                            });
                            _controllerMsg.clear();
                          },
                          icon: const Icon(Icons.send, color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
