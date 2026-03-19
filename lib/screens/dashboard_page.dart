import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:percent_indicator/percent_indicator.dart';

// --- HELPER UNTUK STYLE KATEGORI ---
// Agar warna dan ikon terpusat dan konsisten
class CategoryStyle {
  final IconData icon;
  final Color color;

  const CategoryStyle({required this.icon, required this.color});
}

// Fungsi global untuk mendapatkan style berdasarkan nama kategori
CategoryStyle _getCategoryStyle(String category) {
  switch (category) {
    case 'Coding':
    // Ungu/Indigo cerah sesuai contoh 'Log Session'
      return const CategoryStyle(icon: Icons.code_rounded, color: Colors.indigoAccent);
    case 'Design':
    // Pink/Merah cerah cerah
      return const CategoryStyle(icon: Icons.brush_rounded, color: Colors.pinkAccent);
    case 'Business':
    // Kuning/Oranye cerah
      return const CategoryStyle(icon: Icons.business_center_rounded, color: Colors.amberAccent);
    case 'Language':
    // Hijau/Teal cerah
      return const CategoryStyle(icon: Icons.language_rounded, color: Colors.tealAccent);
    default:
    // Warna default jika kategori lain
      return const CategoryStyle(icon: Icons.book_rounded, color: Colors.cyanAccent);
  }
}

// --- MAIN DASHBOARD PAGE ---
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.email?.split('@')[0] ?? "Ahnan";

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Good Morning,", style: TextStyle(color: Colors.grey[400], fontSize: 16)),
                      Text(
                        displayName,
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.white10),
                        borderRadius: BorderRadius.circular(15)
                    ),
                    child: const CircleAvatar(
                      radius: 25,
                      backgroundColor: Color(0xFF1E222D),
                      child: Icon(Icons.person, color: Colors.blueAccent),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 35),

              // --- KESELURUHAN KONTEN (STREAM BUILDER) ---
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('study_logs')
                    .where('userId', isEqualTo: user?.uid)
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text("Terjadi kesalahan load data."));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
                  }

                  // Logika Menghitung Total Belajar "Hari Ini"
                  double todayHours = 0.0;
                  double targetHours = 6.0;
                  List<QueryDocumentSnapshot> docs = snapshot.data?.docs ?? [];

                  DateTime now = DateTime.now();
                  DateTime startOfDay = DateTime(now.year, now.month, now.day);

                  for (var doc in docs) {
                    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                    if (data['timestamp'] != null) {
                      DateTime logTime = (data['timestamp'] as Timestamp).toDate();
                      if (logTime.isAfter(startOfDay) || logTime.isAtSameMomentAs(startOfDay)) {
                        todayHours += double.tryParse(data['duration'].toString()) ?? 0.0;
                      }
                    }
                  }

                  double percent = todayHours / targetHours;
                  if (percent > 1.0) percent = 1.0;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- CIRCULAR PROGRESS CARD (COLORFUL SPECTRUM) ---
                      Center(
                        child: CircularPercentIndicator(
                          radius: 110.0,
                          lineWidth: 18.0,
                          animation: true,
                          percent: percent,
                          circularStrokeCap: CircularStrokeCap.round,
                          backgroundColor: Colors.white.withOpacity(0.05),
                          // Ganti warna solid blue dengan gradien warna-warni seperti contoh UI
                          linearGradient: const LinearGradient(
                            colors: [
                              Colors.purpleAccent,
                              Colors.indigoAccent,
                              Colors.pinkAccent,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          center: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("GOAL", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 12)),
                              const SizedBox(height: 5),
                              Text(
                                "${(percent * 100).toInt()}%",
                                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              const SizedBox(height: 5),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                decoration: BoxDecoration(
                                    color: Colors.blueAccent.withOpacity(0.1), // Sedikit warna background biru
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.blueAccent.withOpacity(0.2))
                                ),
                                child: Text(
                                  "${todayHours.toStringAsFixed(1)} / ${targetHours.toInt()} hrs",
                                  style: const TextStyle(color: Colors.blueAccent, fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 45),
                      const Text("Recent Activity", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 15),

                      // --- LIST AKTIVITAS DENGAN IKON BERWARNA ---
                      docs.isEmpty
                          ? const Center(child: Padding(padding: EdgeInsets.all(30), child: Text("No activity today.", style: TextStyle(color: Colors.grey))))
                          : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          var data = docs[index].data() as Map<String, dynamic>;
                          // Tentukan kategori, default 'Lainnya' jika null
                          String category = data.containsKey('category') ? data['category'] : 'Lainnya';

                          return _buildStudyTile(
                              data['activity'],
                              data['duration'].toString(),
                              category
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),

      // --- TOMBOL TAMBAH LOG (Modern Minimalist) ---
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        backgroundColor: Colors.indigoAccent, // Warna FAB yang lebih modern
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 35),
      ),
    );
  }

  // --- WIDGET ITEM LIST (COLORFUL ICON) ---
  Widget _buildStudyTile(String title, String duration, String category) {
    // Ambil style kategori (ikon & warna) berdasarkan nama kategori
    CategoryStyle style = _getCategoryStyle(category);

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E222D),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                // Container Ikon dengan Warna Kategori Spesifik
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    // Latar belakang ikon transparan sesuai warna kategori
                    color: style.color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(style.icon, color: style.color, size: 24), // Ikon berwarna cerah
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text("$category • Completed", style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text("${duration}h", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  // --- BOTTOM SHEET TAMBAH LOG (COLORFUL CHIPS) ---
  void _showAddDialog(BuildContext context) {
    final activityController = TextEditingController();
    final durationController = TextEditingController();

    // Default kategori
    String selectedCategory = 'Coding';
    final List<String> categories = ['Coding', 'Design', 'Business', 'Language'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                    left: 25, right: 25, top: 30
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Log Session", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 25),

                    const Text("TOPIC", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    const SizedBox(height: 10),
                    TextField(
                      controller: activityController,
                      decoration: InputDecoration(
                          hintText: "What did you learn today?",
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text("CATEGORY", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    const SizedBox(height: 10),

                    // Membuat tombol chip (Coding, Design, dll) dengan Warna Kategori Spesifik saat dipilih
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: categories.map((cat) {
                        bool isSelected = selectedCategory == cat;
                        // Ambil warna spesifik kategori ini
                        Color catColor = _getCategoryStyle(cat).color;

                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              selectedCategory = cat;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              // Ganti warna selected blue dengan warna spesifik kategori
                              color: isSelected ? catColor : Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                                cat,
                                style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.grey[400],
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                                )
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 25),
                    const Text("DURATION (HOURS)", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    const SizedBox(height: 10),
                    TextField(
                      controller: durationController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                          hintText: "Contoh: 1.5",
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)
                      ),
                    ),

                    const SizedBox(height: 35),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigoAccent, // Warna tombol save baru
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                        ),
                        onPressed: () {
                          if (activityController.text.isEmpty || durationController.text.isEmpty) return;

                          FirebaseFirestore.instance.collection('study_logs').add({
                            'activity': activityController.text.trim(),
                            // Simpan sebagai double agar mudah dihitung
                            'duration': double.tryParse(durationController.text.trim()) ?? 0.0,
                            'category': selectedCategory,
                            'userId': FirebaseAuth.instance.currentUser?.uid,
                            'timestamp': FieldValue.serverTimestamp(),
                          });
                          Navigator.pop(context);
                        },
                        child: const Text("Save Entry", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              );
            }
        );
      },
    );
  }
}