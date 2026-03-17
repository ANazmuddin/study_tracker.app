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
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Statistik Mingguan",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                "Pantau seberapa konsisten kamu belajar minggu ini.",
                style: TextStyle(color: Colors.grey[400], fontSize: 16),
              ),
              const SizedBox(height: 40),

              // Mengambil data secara Real-time dari Firestore
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('study_logs')
                    .where('userId', isEqualTo: user?.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
                  }

                  // Array untuk menampung total jam dari Senin (0) sampai Minggu (6)
                  List<double> weeklyData = List.filled(7, 0.0);
                  double maxDuration = 10.0; // Nilai default tertinggi di grafik

                  if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                    // Menentukan awal minggu ini (Senin jam 00:00)
                    DateTime now = DateTime.now();
                    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
                    DateTime midnightStart = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

                    // Memproses setiap data log belajar
                    for (var doc in snapshot.data!.docs) {
                      var data = doc.data() as Map<String, dynamic>;

                      if (data['timestamp'] != null) {
                        DateTime logDate = (data['timestamp'] as Timestamp).toDate();

                        // Jika log terjadi di minggu ini
                        if (logDate.isAfter(midnightStart) || logDate.isAtSameMomentAs(midnightStart)) {
                          int dayIndex = logDate.weekday - 1; // Senin = 0, Minggu = 6
                          double duration = double.tryParse(data['duration'].toString()) ?? 0.0;

                          weeklyData[dayIndex] += duration; // Tambahkan ke hari yang sesuai
                        }
                      }
                    }

                    // Mencari nilai tertinggi untuk menyesuaikan tinggi grafik dinamis
                    for (var total in weeklyData) {
                      if (total > maxDuration) maxDuration = total + 2.0; // Tambah ruang kosong sedikit di atas
                    }
                  }

                  return Container(
                    height: 300,
                    padding: const EdgeInsets.only(top: 30, bottom: 20, left: 15, right: 15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: maxDuration, // Tinggi maksimal dinamis
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipColor: (group) => Colors.blueGrey.shade900,
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
                                const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
                                return Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: Text(
                                    days[value.toInt()],
                                    style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold, fontSize: 12),
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
                          _makeBarData(0, weeklyData[0]),
                          _makeBarData(1, weeklyData[1]),
                          _makeBarData(2, weeklyData[2]),
                          _makeBarData(3, weeklyData[3]),
                          _makeBarData(4, weeklyData[4]),
                          _makeBarData(5, weeklyData[5]),
                          _makeBarData(6, weeklyData[6]),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  BarChartGroupData _makeBarData(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: Colors.blueAccent,
          width: 22,
          borderRadius: BorderRadius.circular(8),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 10, // Bayangan latar belakang
            color: Colors.white.withOpacity(0.05),
          ),
        ),
      ],
    );
  }
}