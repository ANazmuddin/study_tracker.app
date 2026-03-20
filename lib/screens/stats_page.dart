import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView( // Tambahkan scroll view agar tidak mentok di layar kecil
          padding: const EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Weekly Overview",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                "Pantau konsistensi dan progres belajarmu minggu ini.",
                style: TextStyle(color: Colors.grey[400], fontSize: 16),
              ),
              const SizedBox(height: 30),

              // --- MENGAMBIL DATA DARI FIRESTORE ---
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('study_logs')
                    .where('userId', isEqualTo: user?.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: Padding(padding: EdgeInsets.all(50), child: CircularProgressIndicator(color: Colors.blueAccent)));
                  }

                  // Variabel untuk perhitungan
                  List<double> weeklyData = List.filled(7, 0.0);
                  double maxDuration = 8.0;
                  double totalWeeklyHours = 0.0;
                  int bestDayIndex = 0;
                  const daysName = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];

                  if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                    DateTime now = DateTime.now();
                    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
                    DateTime midnightStart = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

                    // 1. Memproses setiap data
                    for (var doc in snapshot.data!.docs) {
                      var data = doc.data() as Map<String, dynamic>;

                      if (data['timestamp'] != null) {
                        DateTime logDate = (data['timestamp'] as Timestamp).toDate();

                        if (logDate.isAfter(midnightStart) || logDate.isAtSameMomentAs(midnightStart)) {
                          int dayIndex = logDate.weekday - 1;
                          double duration = double.tryParse(data['duration'].toString()) ?? 0.0;

                          weeklyData[dayIndex] += duration;
                          totalWeeklyHours += duration; // Hitung total minggu ini
                        }
                      }
                    }

                    // 2. Mencari nilai tertinggi (Hari terbaik & batas grafik)
                    double highestHours = 0.0;
                    for (int i = 0; i < weeklyData.length; i++) {
                      if (weeklyData[i] > highestHours) {
                        highestHours = weeklyData[i];
                        bestDayIndex = i; // Simpan index hari terbaik
                      }
                      if (weeklyData[i] > maxDuration) {
                        maxDuration = weeklyData[i] + 2.0;
                      }
                    }
                  }

                  double averageDaily = totalWeeklyHours / 7;

                  return Column(
                    children: [
                      // --- SUMMARY CARDS (Info Tambahan) ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSummaryCard(
                              "Total Jam",
                              "${totalWeeklyHours.toStringAsFixed(1)}h",
                              Icons.timer_rounded,
                              Colors.indigoAccent
                          ),
                          _buildSummaryCard(
                              "Rata-rata",
                              "${averageDaily.toStringAsFixed(1)}h/hr",
                              Icons.analytics_rounded,
                              Colors.pinkAccent
                          ),
                          _buildSummaryCard(
                              "Terbaik",
                              totalWeeklyHours == 0 ? "-" : daysName[bestDayIndex].substring(0,3),
                              Icons.local_fire_department_rounded,
                              Colors.amberAccent
                          ),
                        ],
                      ),
                      const SizedBox(height: 35),

                      // --- GRAFIK BATANG (COLORFUL) ---
                      Container(
                        height: 320,
                        padding: const EdgeInsets.only(top: 35, bottom: 20, left: 15, right: 15),
                        decoration: BoxDecoration(
                            color: const Color(0xFF1E222D), // Warna background card yang elegan
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8))
                            ]
                        ),
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: maxDuration,
                            barTouchData: BarTouchData(
                              enabled: true,
                              touchTooltipData: BarTouchTooltipData(
                                getTooltipColor: (group) => Colors.indigoAccent.shade400,
                                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                  return BarTooltipItem(
                                    "${rod.toY.toStringAsFixed(1)} Jam",
                                    const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  );
                                },
                              ),
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S']; // Inisial Hari
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 12.0),
                                      child: Text(
                                        days[value.toInt()],
                                        style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            gridData: const FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                            barGroups: [
                              _makeBarData(0, weeklyData[0], maxDuration),
                              _makeBarData(1, weeklyData[1], maxDuration),
                              _makeBarData(2, weeklyData[2], maxDuration),
                              _makeBarData(3, weeklyData[3], maxDuration),
                              _makeBarData(4, weeklyData[4], maxDuration),
                              _makeBarData(5, weeklyData[5], maxDuration),
                              _makeBarData(6, weeklyData[6], maxDuration),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET SUMMARY CARD ---
  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(color: Colors.grey[400], fontSize: 11), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  // --- PEMBUAT BATANG GRAFIK BERWARNA ---
  BarChartGroupData _makeBarData(int x, double y, double maxDuration) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          width: 20,
          // Gunakan LinearGradient agar batangnya berwarna cerah
          gradient: const LinearGradient(
            colors: [Colors.purpleAccent, Colors.blueAccent],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          borderRadius: BorderRadius.circular(8),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: maxDuration, // Bayangan belakang otomatis setinggi batas maksimal
            color: Colors.white.withOpacity(0.05),
          ),
        ),
      ],
    );
  }
}