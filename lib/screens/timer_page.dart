import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:percent_indicator/percent_indicator.dart';

class CategoryStyle {
  final IconData icon;
  final Color color;
  const CategoryStyle({required this.icon, required this.color});
}

CategoryStyle _getCategoryStyle(String category) {
  switch (category) {
    case 'Coding': return const CategoryStyle(icon: Icons.code_rounded, color: Colors.indigoAccent);
    case 'Design': return const CategoryStyle(icon: Icons.brush_rounded, color: Colors.pinkAccent);
    case 'Business': return const CategoryStyle(icon: Icons.business_center_rounded, color: Colors.amberAccent);
    case 'Language': return const CategoryStyle(icon: Icons.language_rounded, color: Colors.tealAccent);
    default: return const CategoryStyle(icon: Icons.book_rounded, color: Colors.cyanAccent);
  }
}

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  final _activityController = TextEditingController();
  String _selectedCategory = 'Coding';
  final List<String> _categories = ['Coding', 'Design', 'Business', 'Language'];

  int _selectedMinutes = 25;
  int _remainingSeconds = 25 * 60;
  Timer? _timer;
  bool _isRunning = false;

  void _startTimer() {
    if (_activityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Isi nama aktivitas (Topic) dulu ya!")));
      return;
    }

    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _stopAndSaveTimer();
        }
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _stopAndSaveTimer() async {
    _timer?.cancel();
    setState(() => _isRunning = false);

    int totalSeconds = _selectedMinutes * 60;
    int elapsedSeconds = totalSeconds - _remainingSeconds;

    if (elapsedSeconds < 60) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Belajar kurang dari 1 menit tidak disimpan.")));
      _resetTimer();
      return;
    }

    double hoursToSave = elapsedSeconds / 3600.0;

    await FirebaseFirestore.instance.collection('study_logs').add({
      'activity': _activityController.text.trim(),
      'duration': double.parse(hoursToSave.toStringAsFixed(2)),
      'category': _selectedCategory,
      'userId': FirebaseAuth.instance.currentUser?.uid,
      'timestamp': FieldValue.serverTimestamp(),
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Sesi selesai! Progres berhasil disimpan.", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
      ));
    }
    _resetTimer();
    _activityController.clear();
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _remainingSeconds = _selectedMinutes * 60;
    });
  }

  void _setMinutes(int mins) {
    if (_isRunning) return;
    setState(() {
      _selectedMinutes = mins;
      _remainingSeconds = mins * 60;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _activityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String minutesStr = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    String secondsStr = (_remainingSeconds % 60).toString().padLeft(2, '0');
    double percent = _remainingSeconds / (_selectedMinutes * 60);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Focus Timer", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text("Tetapkan target waktu dan mulai fokus.", style: TextStyle(color: Colors.grey[400], fontSize: 16)),
              const SizedBox(height: 30),

              if (!_isRunning) ...[
                TextField(
                  controller: _activityController,
                  decoration: InputDecoration(
                      hintText: "Apa yang ingin dipelajari?",
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)
                  ),
                ),
                const SizedBox(height: 15),
                Wrap(
                  spacing: 10, runSpacing: 10,
                  children: _categories.map((cat) {
                    bool isSelected = _selectedCategory == cat;
                    Color catColor = _getCategoryStyle(cat).color;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? catColor : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(cat, style: TextStyle(color: isSelected ? Colors.white : Colors.grey[400], fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 30),

                const Text("TARGET WAKTU (MENIT)", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [15, 25, 45, 60].map((mins) {
                    bool isSelected = _selectedMinutes == mins;
                    return GestureDetector(
                      onTap: () => _setMinutes(mins),
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.indigoAccent.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                          border: Border.all(color: isSelected ? Colors.indigoAccent : Colors.transparent),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text("$mins", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isSelected ? Colors.indigoAccent : Colors.grey)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 40),
              ],

              Center(
                child: CircularPercentIndicator(
                  radius: 130.0,
                  lineWidth: 15.0,
                  percent: percent,
                  circularStrokeCap: CircularStrokeCap.round,
                  backgroundColor: Colors.white.withOpacity(0.05),
                  progressColor: _getCategoryStyle(_selectedCategory).color,
                  center: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "$minutesStr:$secondsStr",
                        style: const TextStyle(fontSize: 55, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      if (_isRunning)
                        Text("Tetap Fokus!", style: TextStyle(color: _getCategoryStyle(_selectedCategory).color, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 50),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isRunning || _remainingSeconds < (_selectedMinutes * 60))
                    FloatingActionButton(
                      heroTag: "btnReset",
                      backgroundColor: Colors.redAccent.withOpacity(0.2),
                      elevation: 0,
                      onPressed: () {
                        if (_isRunning) {
                          _stopAndSaveTimer(); 
                        } else {
                          _resetTimer();
                        }
                      },
                      child: const Icon(Icons.stop_rounded, color: Colors.redAccent, size: 30),
                    ),

                  if (_isRunning || _remainingSeconds < (_selectedMinutes * 60))
                    const SizedBox(width: 30),

                  SizedBox(
                    width: 80, height: 80,
                    child: FloatingActionButton(
                      heroTag: "btnPlay",
                      backgroundColor: _getCategoryStyle(_selectedCategory).color,
                      onPressed: _isRunning ? _pauseTimer : _startTimer,
                      child: Icon(_isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 45),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}