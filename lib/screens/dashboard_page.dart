import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    // Mengambil nama dari email, jika null kita sapa dengan nama panggilanmu
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
                      Text("Selamat Datang,", style: TextStyle(color: Colors.grey[400])),
                      Text(
                        displayName,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      if (context.mounted) {
                        Navigator.of(context).pushReplacementNamed('/');
                      }
                    },
                    icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // --- PROGRES CARD (GLASSMORPHISM) ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: LinearGradient(
                    colors: [Colors.blueAccent, Colors.blueAccent.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: const Column(
                  children: [
                    Text("Total Belajar Hari Ini", style: TextStyle(color: Colors.white70)),
                    SizedBox(height: 10),
                    Text("04:30", style: TextStyle(fontSize: 45, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text("Jam : Menit", style: TextStyle(color: Colors.white60, fontSize: 12)),
                  ],
                ),
              ),

              const SizedBox(height: 35),
              const Text("Aktivitas Terakhir", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),

              // --- LIST REAL-TIME DARI FIRESTORE ---
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('study_logs')
                    .where('userId', isEqualTo: user?.uid)
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  // 1. Tangkap Error Index Firebase di sini
                  if (snapshot.hasError) {
                    return Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                      ),
                      child: const Text(
                        "Data gagal dimuat. Cek Console Android Studio untuk klik link pembuatan Index Firebase!",
                        style: TextStyle(color: Colors.redAccent),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  // 2. Tampilkan Loading
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(color: Colors.blueAccent),
                      ),
                    );
                  }

                  // 3. Tampilkan Pesan Kosong Jika Belum Ada Data
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text("Belum ada data belajar.", style: TextStyle(color: Colors.grey[500])),
                      ),
                    );
                  }

                  // 4. Tampilkan List Aktivitas
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var doc = snapshot.data!.docs[index];
                      // Fallback jika data lama belum punya field 'category'
                      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                      String category = data.containsKey('category') ? data['category'] : 'Lainnya';

                      return _buildStudyTile(data['activity'], data['duration'], category);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),

      // --- TOMBOL TAMBAH LOG ---
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context),
        label: const Text("Log Sesi", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }

  // --- WIDGET ITEM LIST ---
  Widget _buildStudyTile(String title, String duration, String category) {
    IconData getIcon() {
      switch (category) {
        case 'Coding': return Icons.code_rounded;
        case 'Design': return Icons.brush_rounded;
        case 'Business': return Icons.business_center_rounded;
        case 'Language': return Icons.language_rounded;
        default: return Icons.book_rounded;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(getIcon(), color: Colors.blueAccent, size: 24),
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
                      Text(category, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text("$duration Jam", style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // --- BOTTOM SHEET TAMBAH LOG ---
  void _showAddDialog(BuildContext context) {
    final activityController = TextEditingController();
    final durationController = TextEditingController();

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

                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: categories.map((cat) {
                        bool isSelected = selectedCategory == cat;
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
                              color: isSelected ? Colors.blueAccent : Colors.white.withOpacity(0.05),
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
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                        ),
                        onPressed: () {
                          if (activityController.text.isEmpty || durationController.text.isEmpty) return;

                          FirebaseFirestore.instance.collection('study_logs').add({
                            'activity': activityController.text.trim(),
                            'duration': durationController.text.trim(),
                            'category': selectedCategory,
                            'userId': FirebaseAuth.instance.currentUser?.uid,
                            'timestamp': FieldValue.serverTimestamp(),
                          });
                          Navigator.pop(context); // Tutup bottom sheet
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