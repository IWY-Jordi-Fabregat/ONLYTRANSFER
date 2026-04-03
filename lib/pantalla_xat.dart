import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PantallaXat extends StatefulWidget {
  final String idViatge;
  final String nomClient;

  const PantallaXat({super.key, required this.idViatge, required this.nomClient});

  @override
  State<PantallaXat> createState() => _PantallaXatState();
}

class _PantallaXatState extends State<PantallaXat> {
  final TextEditingController _controller = TextEditingController();
  final Color taronja = const Color(0xFFFF700A);

  void _enviarMissatge() async {
    if (_controller.text.isEmpty) return;

    String textOriginal = _controller.text;
    _controller.clear();

    // Aquí és on el cercle es tanca: Enviem a Firebase
    // La funció de Cloud (que farem després) usarà la API de DeepL per traduir
    await FirebaseFirestore.instance
        .collection('viatges')
        .doc(widget.idViatge)
        .collection('xat')
        .add({
      'autor': 'CONDUCTOR',
      'text_cat': textOriginal,
      'text_traduit': '', // DeepL ho omplirà sol
      'creat_el': FieldValue.serverTimestamp(),
      'tipus': 'text',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("XAT: ${widget.nomClient}", style: const TextStyle(color: Colors.black, fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // LLISTA DE MISSATGES
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('viatges')
                  .doc(widget.idViatge)
                  .collection('xat')
                  .orderBy('creat_el', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                var missatges = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: missatges.length,
                  itemBuilder: (context, i) {
                    var m = missatges[i].data() as Map<String, dynamic>;
                    bool esMio = m['autor'] == 'CONDUCTOR';

                    return Align(
                      alignment: esMio ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: esMio ? taronja : Colors.grey[200],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment: esMio ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Text(m['text_cat'] ?? "", style: TextStyle(color: esMio ? Colors.white : Colors.black, fontSize: 15)),
                            if (m['text_traduit'] != "") 
                              Text(m['text_traduit'], style: TextStyle(color: esMio ? Colors.white70 : Colors.black54, fontSize: 12, fontStyle: FontStyle.italic)),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // BARRA D'ESCRIURE ESTIL APPLE
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  IconButton(onPressed: () {}, icon: const Icon(Icons.image_outlined, color: Colors.grey)),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Escriu en català...",
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: taronja,
                    child: IconButton(onPressed: _enviarMissatge, icon: const Icon(Icons.send, color: Colors.white, size: 20)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
