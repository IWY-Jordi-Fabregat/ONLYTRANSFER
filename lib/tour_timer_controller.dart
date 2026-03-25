import 'dart:async';
import 'package:flutter/material.dart';

class TourTimer extends StatefulWidget {
  @override
  _TourTimerState createState() => _TourTimerState();
}

class _TourTimerState extends State<TourTimer> {
  Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  
  // LA TEVA TARIFA VIP (Exemple: 90€/hora)
  final double preuPerHora = 90.0;

  void _iniciarOAturar() {
    setState(() {
      if (_stopwatch.isRunning) {
        _stopwatch.stop();
        _timer?.cancel();
      } else {
        _stopwatch.start();
        _timer = Timer.periodic(Duration(seconds: 1), (timer) {
          setState(() {});
        });
      }
    });
  }

  String _formatTemps(Duration duration) {
    String dosDigits(int n) => n.toString().padLeft(2, "0");
    return "${dosDigits(duration.inHours)}:${dosDigits(duration.inMinutes.remainder(60))}:${dosDigits(duration.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    // Càlcul del preu segons el temps passat
    double horesPassades = _stopwatch.elapsed.inSeconds / 3600;
    double preuAcumulat = horesPassades * preuPerHora;

    return Scaffold(
      backgroundColor: Color(0xFF2D3142),
      appBar: AppBar(
        title: Text("TOUR VIP EN CURS", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("TEMPS DE TOUR", style: TextStyle(color: Colors.white38, fontSize: 16)),
            Text(
              _formatTemps(_stopwatch.elapsed),
              style: TextStyle(color: Colors.white, fontSize: 70, fontWeight: FontWeight.bold, fontFamily: 'Courier'),
            ),
            SizedBox(height: 40),
            
            // EL COMPTADOR DE DINERS (El que va cap a Dubai)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Color(0xFFFF700A), width: 2),
              ),
              child: Column(
                children: [
                  Text("FACTURACIÓ ESTIMADA", style: TextStyle(color: Colors.white70, fontSize: 14)),
                  Text(
                    "${preuAcumulat.toStringAsFixed(2)} €",
                    style: TextStyle(color: Color(0xFFFF700A), fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 60),
            
            // BOTÓ DE CONTROL
            GestureDetector(
              onTap: _iniciarOAturar,
              child: CircleAvatar(
                radius: 40,
                backgroundColor: _stopwatch.isRunning ? Colors.redAccent : Color(0xFFFF700A),
                child: Icon(
                  _stopwatch.isRunning ? Icons.pause : Icons.play_arrow,
                  color: Colors.white, size: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
