import 'package:flutter/material.dart';
import 'main.dart';

class PantallaConfirmacio extends StatelessWidget {
  final String nomClient;
  final String correuClient;
  final String resumServei;

  const PantallaConfirmacio({
    super.key,
    required this.nomClient,
    required this.correuClient,
    required this.resumServei,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, color: Color(0xFFFF700A), size: 100),
            const SizedBox(height: 30),
            Text("${t('confirma_gracies')}, $nomClient!", textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Text(t('confirma_rebut'), textAlign: TextAlign.center),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
              child: Text(t('confirma_boto_inici')),
            )
          ],
        ),
      ),
    );
  }
}
