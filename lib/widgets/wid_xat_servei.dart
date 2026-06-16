import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WidXatServei extends StatefulWidget {
  final String reservaId;
  final String titolXat;

  const WidXatServei({
    super.key, 
    required this.reservaId, 
    required this.titolXat
  });

  @override
  State<WidXatServei> createState() => _WidXatServeiState();
}

class _WidXatServeiState extends State<WidXatServei> {
  final TextEditingController _controller = TextEditingController();

  void _enviarMissatge() {
    if (_controller.text.trim().isEmpty) return;
    
    FirebaseFirestore.instance
        .collection('reserves')
        .doc(widget.reservaId)
        .collection('xat')
        .add({
      'autor': 'client', // Des de la web de gestió posarem 'empresa'
      'missatge': _controller.text.trim(),
      'data': FieldValue.serverTimestamp(),
    });
    
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          color: const Color(0xFFF0F2F5),
          child: Center(
            child: Text(
              "XAT: ${widget.titolXat}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF2D3142)),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('reserves')
                .doc(widget.reservaId)
                .collection('xat')
                .orderBy('data', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              var docs = snapshot.data!.docs;
              return ListView.builder(
                reverse: true,
                padding: const EdgeInsets.all(20),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  var m = docs[index].data() as Map<String, dynamic>;
                  bool esClient = m['autor'] == 'client';
                  return Align(
                    alignment: esClient ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: esClient ? const Color(0xFFFF700A) : const Color(0xFF556677),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        m['missatge'] ?? '',
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: "Escriu a OnlyTransfer...",
                    filled: true,
                    fillColor: const Color(0xFFF0F2F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              CircleAvatar(
                backgroundColor: const Color(0xFFFF700A),
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white, size: 18),
                  onPressed: _enviarMissatge,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
