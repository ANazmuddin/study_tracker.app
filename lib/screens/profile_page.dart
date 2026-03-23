import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.email?.split('@')[0] ?? "Ahnan";

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // --- FOTO PROFIL (Gradient Glowing Border) ---
              Center(
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Colors.purpleAccent, Colors.indigoAccent, Colors.pinkAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purpleAccent.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ]
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF0F172A), // Warna background scaffold agar terlihat berjarak
                    ),
                    child: const CircleAvatar(
                      radius: 50,
                      backgroundColor: Color(0xFF1E222D),
                      child: Icon(Icons.person, size: 50, color: Colors.indigoAccent),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // --- NAMA & ROLE ---
              Text(
                displayName.toUpperCase(),
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 1.2),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.indigoAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.indigoAccent.withOpacity(0.2)),
                ),
                child: const Text(
                  "Freelance Full Stack Web Developer",
                  style: TextStyle(color: Colors.indigoAccent, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 35),

              // --- KARTU TOTAL STATISTIK (Colorful Data) ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                    color: const Color(0xFF1E222D),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8))
                    ]
                ),
                child: Column(
                  children: [
                    const Text("LIFETIME ACHIVEMENT", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 12)),
                    const SizedBox(height: 20),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('study_logs')
                          .where('userId', isEqualTo: user?.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const CircularProgressIndicator(color: Colors.indigoAccent);

                        double totalHours = 0;
                        for (var doc in snapshot.data!.docs) {
                          totalHours += double.tryParse(doc['duration'].toString()) ?? 0.0;
                        }

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatItem("Total Sesi", "${snapshot.data!.docs.length}", Colors.pinkAccent),
                            Container(width: 1, height: 40, color: Colors.white10),
                            _buildStatItem("Total Jam", totalHours.toStringAsFixed(1), Colors.indigoAccent),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // --- MENU PENGATURAN (Colorful Icons) ---
              _buildMenuTile(Icons.settings_outlined, "Pengaturan Akun", Colors.blueAccent),
              _buildMenuTile(Icons.color_lens_outlined, "Tema Aplikasi", Colors.purpleAccent),
              _buildMenuTile(Icons.help_outline_rounded, "Bantuan & FAQ", Colors.tealAccent),

              const SizedBox(height: 30),

              // --- TOMBOL LOGOUT (Modern Red) ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent.withOpacity(0.1),
                    foregroundColor: Colors.redAccent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    side: BorderSide(color: Colors.redAccent.withOpacity(0.2)),
                  ),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      Navigator.of(context).pushReplacementNamed('/');
                    }
                  },
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text("Keluar", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET STATISTIK ITEM ---
  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 5),
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
      ],
    );
  }

  // --- WIDGET MENU TILE ---
  Widget _buildMenuTile(IconData icon, String title, Color iconColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E222D),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
        onTap: () {}, // Tempat menaruh fungsi navigasi nantinya
      ),
    );
  }
}